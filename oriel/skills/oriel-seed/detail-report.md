---
name: detail-report
description: Use for `/oriel detail report` — a full, read-only render of a project: epic→story→task with statuses, acceptance criteria met/total, recent activity, and open questions, plus a deep board link. Makes no writes.
---

# Detail report (read-only)

`$ARGUMENTS` names the project (default: current). **Read-only — no writes.**

## Gather
- `get_project_tree(project_id)` — full hierarchy + statuses.
- `get_activity(project_id, since=…)` — recent events for the "what changed" section.
- `render_report(project_id, …)` when available, for a formatted artifact + its link.

## Render
- **Per epic:** key + title + status + rollup % criteria met. Then its stories, then tasks — each
  with status, assignee, and **ACs met/total**.
- **Recent activity:** the last N meaningful events (status changes, merges, decisions).
- **Open questions / blockers:** every `blocked` item + unresolved `DECISION:` / question
  comments, each tagged with its item key.
- **Link:** `render_report`'s link, else `get_board_link(project, view:'tree')`.

## Rules
- Read-only — never mutate the board.
- Group by epic; don't flatten. Surface ACs as met/total so progress is concrete.
- For a one-screen summary use `quick report`; for only-remaining use `remaining report`.
- Cross-refs: `quick-report`, `remaining-report`, `milestones`, `mermaid`.
