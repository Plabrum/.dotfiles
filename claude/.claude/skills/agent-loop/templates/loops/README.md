# Autonomous buildout loops (template)

A pattern for building a project out of its backlog with **cooperating headless Claude
loops**, all running on `agent-loop`. Battle-tested on a real buildout; generalized here
as a starting point — copy this `loops/` folder into a repo (e.g. `scripts/loops/`),
then fill in the placeholders below.

> **Placeholders to replace** (grep the folder for `<...>`):
> - `<PROJECT>` — the backlog project (tt slug / Linear project / GitHub repo)
> - `<REPO>` — the repo/project name
> - `<DESIGN_DOC>` — path to the design doc a loop should read before planning (e.g. `DESIGN.md`)
> - `<REFERENCE_REPOS>` — sibling repos to reuse code from, if any (else delete those lines)
> - `<LINT_CHECK>` / `<TYPECHECK>` — the verify commands a session must pass before committing
> - `<EPIC_ORDER>` — the intended build order of your epics (in `planner.md`)
> - `<REPO_SKILLS>` — any repo-specific skills/conventions a builder must follow

## The idea

Several Claude loops build `<REPO>` from the `<PROJECT>` backlog. They share **no state
except the tracker** (issue status / deps / tags / comments) **+ git history** — so any
loop can be killed and restarted and it re-derives what to do. No loop holds durable
in-memory state that matters.

| Loop       | Job                                              | Writes code? | Cadence |
|------------|--------------------------------------------------|--------------|---------|
| Operator   | Launch, watch, and unwedge the other loops       | no           | supervises |
| Planner    | Decompose epics → well-ordered tickets           | no (tracker) | ~45m, guarded |
| Builder    | Pop a ticket, implement, verify, commit          | **yes — sole writer** | continuous |
| UI tester  | Drive the real app, file bug tickets             | no (tracker) | ~30m (phase 2) |

**One builder only.** Two code-writers in one working tree corrupt each other's git
state. The Operator enforces this.

The Builder is a **backlog** loop (ticket-driven, `{{TICKET}}` in its prompt). The Planner
and UI tester are **no-backlog** loops — `agent-loop` runs their prompt as-is every
`--check-interval`. Because they make no commits, `agent-loop` logs "no progress" each
cycle even when they did real tracker work — that's expected for a no-backlog loop.

> If you order tickets with dependencies, your `agent-loop` must skip dependency-blocked
> ("waiting") tickets so a ticket is only pulled once its prerequisites are done. Without
> that, build ordering is not enforced.

## Phase 1 — Planner + Builder (start here)

Planner (seeds empty epics, then tops up when the backlog runs thin):

```sh
agent-loop run --prompt scripts/loops/planner.md \
  --check-interval 45m --stop-after 8h --name <PROJECT>-planner
```

Builder (pops one unblocked ticket per session, commits, marks done):

```sh
agent-loop run --tt-project --prompt scripts/loops/builder.md \
  --close-mode commit --check-interval 15m --stop-after 8h --name <PROJECT>-builder
```

Dry-run selection without spawning Claude: add `--print-ticket`.

## Phase 2 — add the UI tester

Only once the app actually runs and has a launchable UI. Bring the app up in its own
terminal first (dev servers), then:

```sh
agent-loop run --prompt scripts/loops/ui-tester.md \
  --check-interval 30m --stop-after 8h --name <PROJECT>-ui-tester
```

## Watching it

```sh
watch -n 10 'tt issue ls --project <PROJECT>'   # live backlog (adapt to your tracker)
tail -f ~/logs/agent-loop/<PROJECT>-builder/*.log
```

## Stopping

Ctrl-C each terminal. Because everything is derived from the tracker + git, a mid-flight
kill is safe: worst case a half-done ticket is left in-progress — reset it by hand.
