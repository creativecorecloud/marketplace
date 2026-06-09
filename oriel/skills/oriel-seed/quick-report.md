---
name: quick-report
description: Use for `/oriel quick report` — a one-screen, read-only status of a project: per active epic show % criteria met, ready/blocked counts, top in-flight items, and the blockers that need the user. Ends with a board link. Makes no writes.
---

# Quick report (read-only)

`$ARGUMENTS` names the project (default: the one you're driving / most recent). **Read-only — no
writes.**

## Gather
- `check_in` for the per-project counts (ready / open / waiting / unread).
- `get_project_tree(project_id)` for epic/story/task statuses + criteria rollups.

## Render (one screen)
- **Headline:** project name + overall % of acceptance criteria met + open/total counts.
- **Per active epic** (skip done/cancelled): one line — `KEY title — N% criteria · R ready · B
  blocked · status`.
- **In-flight now:** the `in_progress` / `in_review` leaves (top ~5).
- **Needs you:** blockers waiting on a user decision/approval (from `blocked` items + open
  `DECISION:` comments).
- **Link:** `get_board_link(project)` so the user can open the board.

## Rules
- Strictly read-only — `check_in`, `get_project_tree`, `get_activity`, `get_board_link` only;
  never `set_status` / `create_entity` / `update_entity`.
- Fit one screen; lead with what needs the user. For the full tree use `detail report`; for
  only-remaining use `remaining report`.
- Cross-refs: `detail-report`, `remaining-report`, `milestones`.
