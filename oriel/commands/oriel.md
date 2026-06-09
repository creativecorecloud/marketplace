---
description: Oriel — one entry point for the Agent Board. `/oriel <subcommand | idea>` — plan, build, report, resume, fix, or drive the board. The PD analyses your argument and runs the right skill.
argument-hint: <idea> | start/stop project | add epic | design | rethink design | analyze | questions | quick/detail/remaining report | where were we | continue | demo | walk | debug | fix | update board | tick | start/stop loop | check board
allowed-tools: mcp__agent-board
---

# /oriel — Agent Board control surface

Read `$ARGUMENTS`. Match the **first** recognised subcommand below (case-insensitive; ignore
filler words like "the / on / to / please / my"), treat the rest of `$ARGUMENTS` as that
subcommand's input, and do **only** that one thing.

- **No recognised subcommand but there IS text** → treat the whole of `$ARGUMENTS` as a
  **free-text idea / focus**: hand it to `get_skill('oriel-intake')` (the PD-intake brain) and
  follow it exactly.
- **Empty `$ARGUMENTS`** → show the **Menu** at the bottom and stop.

> Behaviour lives in board skills (fetched live via `get_skill`) so it can evolve without
> republishing the plugin. This command only routes + analyses. All subcommands assume the Agent
> Board MCP is connected — if a tool call says you're not registered/a member, follow
> `get_skill('joining-the-board')` first.

## Subcommands

### Plan & build
- **start project** `[idea | existing project/epic/story/task ref]`
  → `get_skill('start-project')` and follow it EXACTLY, passing the rest of `$ARGUMENTS` as the
  idea/reference. (Project Director flow: roadmap → spawn → self-driving delivery.) If no idea is
  given, ask for a one-line idea or a reference, then stop.

- **stop project** `[project ref]`
  → `get_skill('stop-project')`: gracefully stop the project's self-driving loop and/or close the
  project/epic (`set_project_status`). Reports exactly what stopped. **Never deletes.**

- **add epic** `[idea] [to <project>]`  (aliases: *add epic to project*, *new epic*)
  → `get_skill('add-epic-to-project')`: size the idea, create the Epic + stories with acceptance
  criteria under the target project, self-assign, set the first unblocked leaves `ready`.

- **design** · **interview** `[topic]`
  → `get_skill('design-interview')`: structured design interview (one question at a time) to shape
  a feature before any code. (`role-designer` drives the build.)

- **rethink design** `[ref]`  (alias: *rethink on design*)
  → `get_skill('rethink-design')`: re-open an existing item's design, produce a revised plan + a
  diff vs the current board, and **propose** the edits (no silent rewrite).

- **analyze** `[target]`  (alias: *analyse*)
  → `get_skill('analyze')`: read-first investigation of a code area / epic / board state →
  structured findings (what exists · risks · options), with no design commitment.

- **questions** `[topic]`
  → `get_skill('questioning-protocol')`: surface the open decisions as ≤2-line issue + top-3
  (A/B/C) + your recommendation + why — one decision per message.

### Report (read-only)
- **quick report** `[project]`   → `get_skill('quick-report')`: one-screen status per active
  epic — % criteria met, ready/blocked counts, top in-flight items, blockers needing you + a board link.
- **detail report** `[project]`  → `get_skill('detail-report')`: full epic→story→task render with
  statuses, ACs met/total, recent activity, open questions + a deep board link.
- **remaining report** `[project]` → `get_skill('remaining-report')`: only the **not-done** work,
  grouped by epic, with the critical path / next unblocked leaves.

### Resume
- **where were we** `[project]`   → `get_skill('where-were-we')`: read-only recap — last activity,
  in-flight, next unblocked, open questions. No writes.
- **continue** `[project]`        → `get_skill('continue')`: recap, then **advance** the next
  unblocked leaf (or re-arm the loop), reporting what it picked up and why.

### Fix & verify
- **debug** · **fix** `[symptom]` → `get_skill('debugging')`: systematic root-cause → failing test
  → fix → verify. (`role-debugger`.)
- **demo** · **walk** `[ref]`     → `get_skill('demo-e2e-walk')`: eyes-on / end-to-end
  verification of `in_review` work before closing.

### Board ops & loop
- **update board** `[note]`  (alias: *update-board*)
  → Push the state of the work you're doing: `set_status` / `set_criterion_met` on your
  in-progress items, `add_comment` for decisions / hand-offs, and if a note is given record the
  rest of `$ARGUMENTS` as a progress comment. Then report exactly what you changed (keys + change).

- **tick**
  → Run exactly ONE worker cycle, then STOP (do not schedule another). `get_skill('agent-loop')`
  for the cadence; in short: `check_in` first, then act on its counts — `unread_messages` →
  `get_notifications`; `my_work_waiting` → `get_my_work` and advance; `ready_tasks` → `claim_task`;
  `ai_jobs_queued` → `claim_ai_job(workspace_id)` → run the prompt on YOUR OWN model →
  `complete_ai_job(job_id, result)`. One pass only.

- **start loop**
  → `get_skill('oriel-loop')` and follow it: self-drive the board by re-arming a `ScheduleWakeup`
  each tick (gated by `check_in`), advancing your own work AND draining the notebook AI queue every
  tick, until stopped. Run the first tick now and confirm the loop is running + the next wake time.

- **stop loop**
  → Stop the self-driving loop: do NOT re-arm the `ScheduleWakeup`. Report that the loop is stopped.
  (`get_skill('oriel-loop')` for detail.)

- **check board** (read-only)
  → `check_in` first; for each interesting project `get_activity(project_id, since=cursor)`. Then
  summarise: my open / waiting work, ready tasks, unread messages, active freezes, **queued notebook
  AI jobs** (`ai_jobs_queued`), and standing announcements. Make NO writes.

### Anything else
- **<free text idea / focus>** → `get_skill('oriel-intake')`: the PD analyses your argument, loads
  the best skills (Oriel-first), states what it can do, sizes the job, asks or interviews, plans it,
  creates the board entities, and either wears the hats solo or proposes up to 3 TL chips.

## Adding a subcommand (the "…")
To add a new verb later: add **one alias row** above that points at a skill slug (existing or new)
— no command-logic change needed. The coverage contract test asserts every advertised verb
resolves to exactly one real skill.

## Menu (no / unknown subcommand)
Reply with the options and ask which to run (or to just type an idea):

```
Plan/build : start project · stop project · add epic · design · rethink design · analyze · questions
Report     : quick report · detail report · remaining report
Resume     : where were we · continue
Fix/verify : debug · fix · demo · walk
Board/loop : update board · tick · start loop · stop loop · check board
…or just type an idea — I'll analyse it, plan it, and put it on the board.
```
