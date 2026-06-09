---
name: stop-project
description: Use for `/oriel stop project` — gracefully stop a project's self-driving loop and/or close the project or epic. Stops the wakeup, sets status, reports exactly what stopped and how to resume. Never deletes.
---

# Stop project — halt the loop and/or close it

`$ARGUMENTS` names the project/epic (or defaults to the one you're driving). "Stop" means two
distinct things — **pause the loop** vs **close the project**. Do the one the user means; if
ambiguous, ask once (`questioning-protocol`).

## 1 — Identify
`check_in` / `whoami` → resolve the target project (or epic) by name / key / ref.

## 2 — Stop the loop (the default for "stop")
- Do **NOT** re-arm the `ScheduleWakeup`; let the schedule lapse (`oriel-loop` → stop).
- Leave work statuses as-is — stopping the loop pauses *driving*, it does not change the plan.
- Report: which loop stopped, what work remains open, how to resume (`/oriel start loop` or
  `/oriel continue`).

## 3 — Close the project / epic (only if that's what's meant)
- **Project** → `set_project_status(archived)` once the user confirms (closing a project is
  user-led).
- **Epic done** → `set_status(done)` only when every child criterion is met-or-disabled
  (`board-usage`).
- **Abandoning partway** → `set_status(cancelled)` + a reason comment; never silently.

## Rules
- **Never delete.** Removing data (`delete_project`, hard cancel) needs an explicit, confirmed
  "delete" + user approval — "stop" never deletes.
- Stopping is reversible — always say exactly how to resume.
- Record a status / `DECISION:` comment so the next agent knows why it stopped.
- Cross-refs: `oriel-loop`, `board-usage`, `questioning-protocol`.
