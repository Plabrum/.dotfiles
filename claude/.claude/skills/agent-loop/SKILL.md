---
name: agent-loop
description: >
  Run agent-loop — a tool that spawns repeating headless Claude Code sessions against a
  Linear or GitHub Issues backlog. Use when the user asks to kick off a background agent
  loop, run Claude autonomously on a backlog, set up agent-loop for a project, or dry-run
  ticket selection. Trigger on phrases like "start the agent loop", "run agent loop",
  "agent on my backlog", "agent-loop init", or "which ticket would it pick".
---

# agent-loop

`agent-loop` lives at `~/.local/bin/agent-loop`. It spawns repeating headless `claude -p`
sessions, pre-picks a ticket from a Linear project or GitHub Issues backlog, substitutes it
into the prompt at `{{TICKET}}`, and stops when the backlog is empty or a deadline is reached.

The ticket drives the task — the body should contain what to do, how to verify, and how to
close. The built-in prompt just provides headless context, orient steps, and safety rails.

## Subcommands

| Subcommand | What it does |
|---|---|
| `agent-loop init` | Asks 3 questions, prints the `agent-loop run` command to use |
| `agent-loop run` (or just `agent-loop`) | Run the loop |

## Key flags

### Prompt

```
--prompt PATH          Path to a custom prompt .md file. Defaults to the built-in prompt.
```

All sessions run with `--dangerously-skip-permissions`. The built-in prompt is used unless `--prompt` overrides it.

### Backlog source (mutually exclusive)

```
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

### Close mode

```
--close-mode commit            (default) Commit + push on current branch, close the issue.
--close-mode pr                Cut a feature branch, push, open a PR with Closes #N. Issue closes on merge.
--pr-base BRANCH               Base branch for --close-mode=pr (default: repo's default branch).
--branch-pattern TMPL          Branch name template (default: agent/{kind}-{id}-{slug}).
                               Vars: {kind}=gh|lin, {id}=issue number/Linear identifier, {slug}=title kebab.
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
--model MODEL                  Claude model (default: opus).
--log-dir DIR                  Session log directory (default: ~/logs/agent-loop/<name>/).
--name NAME                    Name used in log filenames (default: prompt filename stem or role).
```

## Environment variables

```
LINEAR_API_KEY    Required for --linear-project. Personal API key from linear.app/settings/api.
```

## Common invocations

### Loop against a Linear project
```bash
agent-loop \
  --linear-project "Pear" \
  --linear-state "Todo" \
  --close-mode pr \
  --stop-after 6h \
  --check-interval 15m
```

### Loop against GitHub Issues
```bash
agent-loop \
  --github-repo owner/repo \
  --label "agent-ready" \
  --close-mode pr \
  --skip-deps \
  --stop-at 18:00
```

### Dry-run ticket selection
```bash
agent-loop --print-ticket \
  --linear-project "Pear" \
  --linear-state "Backlog"
```

### Get the right command for a project
```bash
cd /path/to/project
agent-loop init
```

## Session lifecycle

1. Picks a ticket from the backlog (or skips if no backlog source configured).
2. Renders the `{{TICKET}}` block into the prompt.
3. Spawns `claude -p <rendered-prompt> --model <model> --dangerously-skip-permissions`.
4. Logs stdout+stderr to `~/logs/agent-loop/<name>/<name>_<timestamp>_<sha>.log`.
5. Clean exit + new commit → success. Prints commits landed.
6. On failure (non-zero exit or no commit landed) → spawns a child unblock session.
7. Unblock session diagnoses the issue and fixes it if possible, then exits 0 to continue or runs `exit 1` to stop the loop.
8. Unblock log written alongside the session log as `<name>.unblock.log`.
9. Repeats until deadline, empty backlog (with no `--check-interval`), or unblock session exits 1.

## Safety notes

- All sessions run with `--dangerously-skip-permissions`.
- The loop only stops on unrecoverable failures — the unblock session decides what's unrecoverable.
