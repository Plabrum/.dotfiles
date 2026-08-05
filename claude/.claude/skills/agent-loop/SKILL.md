---
name: agent-loop
description: >
  Run agent-loop — a tool that spawns repeating headless Claude Code sessions against a
  tt, Linear or GitHub Issues backlog. Use when the user asks to kick off a background
  agent loop, run Claude autonomously on a backlog, set up agent-loop for a project, or
  dry-run ticket selection. Trigger on phrases like "start the agent loop", "run agent
  loop", "agent on my backlog", "work my tt backlog", "agent-loop init", or "which ticket
  would it pick".
---

# agent-loop

`agent-loop` lives at `~/.local/bin/agent-loop`. It spawns repeating headless `claude -p`
sessions, pre-picks a ticket from a tt project, Linear project or GitHub Issues backlog,
substitutes it into the prompt at `{{TICKET}}`, and stops when the backlog is empty or a
deadline is reached.

The ticket drives the task — the body should contain what to do, how to verify, and how to
close. The prompt just provides headless context, orient steps, and safety rails.

## Subcommands

| Subcommand | What it does |
|---|---|
| `agent-loop init` | Asks 3 questions, prints the `agent-loop run` command to use |
| `agent-loop run` (or just `agent-loop`) | Run the loop |

## Key flags

### Prompt

```
--prompt PATH          Path to a prompt .md file. REQUIRED.
```

`--prompt` is not optional — `agent-loop run` without it exits 2, and a bare `agent-loop`
without it just prints help. The prompt must contain `{{TICKET}}` whenever a backlog source
is configured. With no backlog source the loop runs the prompt as-is each iteration (a
QA-style loop) and `{{TICKET}}` is not required.

All sessions run with `--dangerously-skip-permissions`.

### Backlog source (mutually exclusive)

```
--tt-project [SLUG]            Pick from a tt project. Bare (no value) resolves the project
                               from the cwd via the path stored on the tt project.
--linear-project NAME          Pick from a Linear project (needs LINEAR_API_KEY env var)
--linear-state STATE           Which state = "ready" (default: Backlog)
--github-repo OWNER/REPO       Pick from GitHub Issues
--label LABEL                  GitHub label filter (optional)
--milestone NAME               GitHub milestone filter (optional)
```

### Ticket selection

```
--skip-label LABEL             Drop tickets with this label (default: epic,tracker). Repeatable or comma-separated.
--prioritize-label LABEL       Float tickets with this label to the top (default: bug). Repeatable or comma-separated.
--skip-deps                    Skip tickets whose body says "blocked by #N" / "depends on ENG-N" if N is still open.
```

**These three do nothing for `--tt-project`** — tt has no labels and no dependency edges.
The loop says so in its startup summary if you pass them anyway. tt selection is fixed:
status `todo`, `high` priority first, then lowest id. The `Epic:` title guard still applies.

### Close mode

```
--close-mode commit            (default) Commit + push on current branch, close the issue.
--close-mode pr                Cut a feature branch, push, open a PR. Issue closes on merge.
--pr-base BRANCH               Base branch for --close-mode=pr (default: repo's default branch).
--branch-pattern TMPL          Branch name template (default: agent/{kind}-{id}-{slug}).
                               Vars: {kind}=gh|tt|lin, {id}=issue number/Linear identifier, {slug}=title kebab.
```

### Scheduling / looping

```
--stop-at HH:MM                Hard deadline at a wall-clock time (wraps to tomorrow if past).
--stop-after DURATION          Hard deadline from now: 6h, 90m, 30s.
--check-interval DURATION      Sleep this long between sessions and when backlog is empty.
                               Requires --stop-at or --stop-after. Without it, loop stops on empty backlog.
```

### Debugging

```
--print-ticket                 Dry-run: pick a ticket, print the rendered {{TICKET}} block, exit.
                               Requires a backlog source. Does not claim the ticket or spawn Claude.
--model MODEL                  Claude model (default: opus).
--log-dir DIR                  Session log directory (default: ~/logs/agent-loop/<name>/).
--name NAME                    Name used in log filenames (default: prompt filename stem).
```

## Working with a tt backlog

tt is a local SQLite tracker (`tt issue ls`, `tt issue show N`, `tt issue action N edit …`).
Three of its properties shape how the loop behaves:

**`edit` is a whole-object write, not a patch.** Every editable field (`title`, `body`,
`status`, `priority`) is required and anything omitted is cleared. The loop re-reads the
issue immediately before each transition so a change made in the TUI between pick and claim
is not clobbered. If you hand-write a close command, read first.

**Status is only `todo` / `doing` / `done`.** There is no `review` state, so
`--close-mode pr` leaves the issue in `doing` and instructs the session *not* to mark it
done — the human marks it done on merge. `doing` is enough to keep the picker off it.

**There is no `shelved` status and no labels**, so a repeatedly-failing ticket has nowhere
durable to record "stop picking me". The loop counts attempts in-process and drops a ticket
after 2 no-progress sessions. **That memory does not survive a restart** — restart the loop
and it will try the ticket again. To park one permanently, move it out of `todo` by hand.

Lifecycle mapping:

| Loop step | tt write |
|---|---|
| claim | `status` → `doing` |
| no progress → release | `status` → `todo` |
| close (commit mode) | session runs the pre-rendered `tt issue action N edit '…'` |
| close (pr mode) | none — stays `doing` until merge |

Tickets are referenced as `tt#N` in commits and PR bodies, prefixed so they can't auto-link
to a GitHub issue of the same number. After a commit lands in `commit` mode the loop
re-reads the issue and warns if it is still `doing` — that means the session skipped its
close step and the issue is stranded outside the picker's view.

## Environment variables

```
LINEAR_API_KEY    Required for --linear-project. Personal API key from linear.app/settings/api.
```

`--tt-project` and `--github-repo` need no key — tt is a local database, `gh` carries its
own auth.

## Common invocations

### Loop against the tt project for the current repo
```bash
cd /path/to/project
agent-loop run \
  --prompt scripts/agent-prompt.md \
  --tt-project \
  --stop-after 6h \
  --check-interval 15m
```

### Loop against a named tt project
```bash
agent-loop run \
  --prompt scripts/agent-prompt.md \
  --tt-project snacks \
  --close-mode pr \
  --stop-at 18:00
```

### Loop against a Linear project
```bash
agent-loop run \
  --prompt scripts/agent-prompt.md \
  --linear-project "Pear" \
  --linear-state "Todo" \
  --close-mode pr \
  --stop-after 6h \
  --check-interval 15m
```

### Loop against GitHub Issues
```bash
agent-loop run \
  --prompt scripts/agent-prompt.md \
  --github-repo owner/repo \
  --label "agent-ready" \
  --close-mode pr \
  --skip-deps \
  --stop-at 18:00
```

### Dry-run ticket selection
```bash
agent-loop run --prompt scripts/agent-prompt.md --tt-project --print-ticket
```

### Get the right command for a project
```bash
cd /path/to/project
agent-loop init
```

## Session lifecycle

1. Picks a ticket from the backlog (or skips if no backlog source configured).
2. Claims it — tt → `doing`, Linear → its in-progress state. GitHub has no claim step.
3. Renders the `{{TICKET}}` block into the prompt.
4. Spawns `claude -p <rendered-prompt> --model <model> --dangerously-skip-permissions`.
5. Logs stdout+stderr to `~/logs/agent-loop/<name>/<name>_<timestamp>_<sha>.log`.
6. Clean exit + new commit → success. Prints commits landed, then checks whether the ticket
   actually got closed and warns if not.
7. On failure (non-zero exit or no commit landed) → releases the claim back to `todo`/Backlog,
   then spawns a child unblock session.
8. Unblock session diagnoses the issue and fixes it if possible, then exits 0 to continue or
   runs `exit 1` to stop the loop.
9. Unblock log written alongside the session log as `<name>.unblock.log`.
10. Repeats until deadline, empty backlog (with no `--check-interval`), or unblock exits 1.

## Safety notes

- All sessions run with `--dangerously-skip-permissions`.
- The loop only stops on unrecoverable failures — the unblock session decides what's unrecoverable.
- Success is measured by "did HEAD move". A session that closes a ticket without committing
  counts as no progress.
