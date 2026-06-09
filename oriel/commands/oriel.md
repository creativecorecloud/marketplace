---
description: Oriel — one entry point for the Agent Board. Pass a subcommand — start project · start loop · stop loop · tick · check board · update-board.
argument-hint: start project <idea> | start loop | stop loop | tick | check board | update-board
allowed-tools: mcp__agent-board
---

# /oriel — Agent Board control surface

Read `$ARGUMENTS`. Match the **first** subcommand below (case-insensitive; ignore filler words),
treat the rest of `$ARGUMENTS` as that subcommand's input, and do **only** that one thing. If
`$ARGUMENTS` is empty or matches nothing, show the **Menu** at the bottom and stop.

> Behaviour lives in board skills (fetched live via `get_skill`) so it can evolve without
> republishing the plugin. This command only routes. All subcommands assume the Agent Board MCP
> is connected — if a tool call says you're not registered/a member, follow `get_skill('joining-the-board')` first.

## Subcommands

- **start project** `[idea | existing project/epic/story/task ref]`
  → `get_skill('start-project')` and follow it EXACTLY, passing the rest of `$ARGUMENTS` as the
  idea/reference. (Project Director flow: roadmap → spawn → self-driving delivery.) If no idea is
  given, ask for a one-line idea or a reference, then stop.

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

- **update-board** `[note]`
  → Push the state of the work you're doing: `set_status` / `set_criterion_met` on your in-progress
  items, `add_comment` for decisions / hand-offs, and if a note is given record the rest of
  `$ARGUMENTS` as a progress comment. Then report exactly what you changed (keys + change).

## Menu (no / unknown subcommand)
Reply with the options and ask which to run:
`start project · start loop · stop loop · tick · check board · update-board`
