---
name: milestones
description: Use when planning, tracking, or reporting milestones on the Oriel Agent Board — represents milestones as a convention over existing entities (no dedicated type).
---

# Milestones Protocol

The board has no dedicated milestone entity. A milestone is a CONVENTION layered on the existing
hierarchy (Workspace > Project > Epic > Story > Task). Treat a milestone as a coherent, releasable
outcome and represent it as an **epic** (or, for small scopes, a designated **story**) flagged via
metadata. Its child stories/tasks are the work; dependencies express ordering between milestones.

## Declaring a milestone
- Create an epic under the project that names the releasable outcome (e.g. "Milestone: Beta Auth").
- Set `metadata.milestone = true` so it is machine-discoverable.
- Set `metadata.target` to a short label or date string passed in by the planner
  (e.g. `"2026-Q3"`, `"v0.2"`, `"2026-07-15"`). Keep it human-readable; it is informational, not enforced.
- Optionally set `priority` and tag it (via metadata tags) so it surfaces in filtered views.
- Add the real work as child stories/tasks of that epic, each with acceptance criteria. Do NOT
  create a separate "tracking" entity — the epic IS the milestone.

## When is a milestone reached
- A milestone is **done when all its child stories/tasks are done**. There is no separate "complete"
  switch beyond rolling up children.
- Roll-up: collapse the epic's subtree; if every descendant story/task has status done, the milestone
  is reached. Mark the epic itself done at that point for a clean signal.
- Partial progress = (done children / total children). Report this fraction, do not invent a status.

## Sequencing milestones
- Order milestones with `add_dependency(blocker_id, blocked_id)` between the **milestone epics**:
  the earlier milestone is the blocker, the later one is blocked.
- Example: `add_dependency(<M1 epic id>, <M2 epic id>)` means M2 cannot start until M1 ships.
- Keep dependencies at the milestone (epic) level for the release order; keep task-level
  dependencies inside a milestone for intra-milestone ordering. Avoid cross-wiring the two.

## Reviewing & reporting progress (planner)
- Discover milestones: `list_entities` filtered to type=epic where `metadata.milestone = true`,
  or scan `get_project_tree` for flagged epics.
- For each milestone epic: read its subtree from `get_project_tree`, compute done/total children,
  and read `metadata.target` for the intended label/date.
- Read milestone-to-milestone dependencies to present them in shipping order, and flag any whose
  blocker is not yet done as "blocked".
- Report per milestone: name, target, progress fraction, status (not started / in progress / done /
  blocked), and the next unblocked work item.

## Note
This is a CONVENTION over existing entities, not a schema feature. `metadata.milestone` and
`metadata.target` are the only contract. If a first-class milestone entity type is added later,
this skill is where that behavior gets documented and the convention deprecated.
