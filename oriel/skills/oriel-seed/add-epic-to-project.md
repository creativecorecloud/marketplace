---
name: add-epic-to-project
description: Use for `/oriel add epic [idea] to [project]` — size an idea into ONE epic with stories + acceptance criteria under a target project, self-assign, and set the first unblocked leaves ready. The single-epic slice of the PD-intake flow.
---

# Add epic to a project

`$ARGUMENTS` = an idea + optionally a target project ("… to <project>"). Adds **one** epic (with
its stories) to an existing project — the bounded slice of `oriel-intake`.

## 1 — Resolve the target project
Parse "to <project>" → match by name / slug / key (`list_projects`). If absent or ambiguous, ask
once (`questioning-protocol`). If you're already driving a project, default to it.

## 2 — Size & shape (light intake)
Run `oriel-intake` steps 1–6 at **epic scope**: classify size, load the skills the epic needs
(Oriel-first), and — only if there's a real open design question — ask via `questioning-protocol`
(or `design-interview` if genuinely ambiguous). Emit the plan as bullet titles (epic → stories)
**first**, before creating anything.

## 3 — Create it
`create_entity(type:'epic', project_id, …)` → stories under it (tasks only as deep as the first
worker needs). Every story/task gets **observable acceptance criteria** (include a contract-test
criterion) and is **self-assigned** (or assigned + `notify`'d). Wire `add_dependency`; set the
first unblocked leaves `ready`. Surface a `get_board_link`.

## 4 — Flag the flow-map stale
Adding an epic marks the project's flow chart STALE. Tell the user; regenerate only on request
(`mermaid` + `set_project_flowchart`) — never auto-regenerate inline.

## Rules
- One epic per invocation; for a whole new initiative use `/oriel start project`.
- No orphan tasks — assign everything. Acceptance criteria are observable facts, not vibes.
- Cross-refs: `oriel-intake`, `board-usage`, `estimation`, `questioning-protocol`, `mermaid`.
