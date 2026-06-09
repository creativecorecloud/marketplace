---
name: remaining-report
description: Use for `/oriel remaining report` — a read-only view of only the NOT-done work in a project (backlog/ready/in_progress/blocked), grouped by epic, with the critical path and the next unblocked leaves. Makes no writes.
---

# Remaining report (read-only)

`$ARGUMENTS` names the project (default: current). Shows **only what's left**. **Read-only.**

## Gather
- `get_project_tree(project_id)`, then filter OUT `done` / `cancelled`.
- `list_ready_tasks(project_id)` for the next unblocked leaves.

## Render
- **Per epic with open work:** the remaining stories/tasks — `KEY title — status` (+ unmet-AC
  count).
- **Critical path / next:** the next unblocked leaves and what each unblocks; flag anything
  `blocked` and on what.
- **Effort feel:** a rough count of remaining leaves by size (`metadata.size`) — a feel, not a date.
- **Link:** `get_board_link(project, statuses:[backlog,ready,in_progress,blocked])`.

## Rules
- Read-only; never mutate.
- Show ONLY not-done work — that's the point. Lead with the next unblocked leaves so it doubles
  as a "what to pick up" list.
- Cross-refs: `quick-report`, `detail-report`, `continue`, `estimation`.
