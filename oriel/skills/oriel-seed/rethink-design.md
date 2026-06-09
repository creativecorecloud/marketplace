---
name: rethink-design
description: Use for `/oriel rethink design` — re-open the design of an existing project/epic/story, run a fresh design pass, then produce a revised plan plus a DIFF against the current board and PROPOSE the edits. Never silently rewrites the board.
---

# Rethink design — re-open, diff, propose

`$ARGUMENTS` points at the existing item (project / epic / story) whose design is being
reconsidered.

## 1 — Load the current design
`get_entity` / `get_project_tree` + read its `DECISION:` comments and acceptance criteria — the
design as it stands today.

## 2 — Re-open the design
Run `design-interview` (or `analyze` first if the problem is unclear) to rethink it: what changed,
what was wrong, what's the better shape. One question at a time (`questioning-protocol`); record
new decisions.

## 3 — Produce a revised plan + DIFF
Lay the new shape against the current board:
- **Keep** — items unchanged.
- **Change** — items whose title / criteria / scope move (show old → new).
- **Add** — new epics / stories / criteria.
- **Drop** — items to cancel (with a reason).

## 4 — Propose, don't apply
Present the diff and **ask for approval** before mutating the board. On approval, apply via
`create_entity` / `update_entity` / `rename` / `set_status(cancelled)` / criteria edits, recording
a `DECISION:` comment for each material change. Mark the flow-map stale (don't auto-regenerate).

## Rules
- **Never silently rewrite** a settled plan — surface the diff and get a yes first (changing a
  locked plan can be costly/irreversible).
- Reuse existing items; don't recreate what only needs editing (no-duplication).
- Cross-refs: `design-interview`, `analyze`, `questioning-protocol`, `role-designer`,
  `board-usage`, `mermaid`.
