---
name: estimation
description: Use when sizing and ordering work on the Agent Board — turns a rough backlog into right-sized leaf tasks with a defensible priority ordering.
---

# Estimation & Prioritization

How to size work and order the ready queue so workers always pull the highest-leverage, truly-actionable task next. Sizing and ordering only — the planner loop and milestone skills cover the rest.

## Sizing in T-shirts
- Use relative sizes, not hours: **S / M / L**. Record on the entity as `metadata.size` via `update_entity`.
- S = one worker, one focused sitting. M = a long sitting but still one worker, one PR. L = too big — it must be split.
- If you cannot confidently size something as S or M, that is the signal to **decompose**, not to invent a number. Split an L into child tasks via `create_entity` until every leaf is S or M.
- A guess that papers over uncertainty is worse than an honest split.

## What "well-sized" means
- A leaf task has clear, testable acceptance criteria (`add_acceptance_criteria`) and no hidden unknowns.
- If there is an unknown — unfamiliar API, unproven approach, unclear data shape — carve it out as a **spike** task first (timeboxed, output = a decision or proof, not shippable code). Size the real work only after the spike resolves.
- Re-read the criteria: if you cannot tell from them when the task is done, it is not ready to size.

## Prioritizing
- **Bugs outrank roadmap features.** A confirmed bug — especially one a user hit — is pulled ahead of new feature work. Drain the bug list before advancing the roadmap, unless the user says otherwise. (Order the bug list itself by value × risk ÷ effort like anything else.)
- Order by **value × risk ÷ effort**. High value, high risk (if wrong), low effort floats to the top.
- Do de-risking and unblocking work early — anything other tasks depend on, anything that could invalidate the plan.
- Convention: **lower integer `priority` = higher priority** (1 before 5). Be consistent across the project. Set it with `update_entity` so `list_ready_tasks` and the board reflect your ordering.
- Leave gaps (10, 20, 30) so you can insert later without renumbering everything.

## Sequencing the ready queue
- Use `add_dependency` to encode real ordering, so a task is *ready* only when it is truly actionable. Priority orders the ready set; dependencies decide what is in it.
- Keep the ready queue small and unambiguous — a worker should be able to claim the top item and start immediately.
- A perpetually blocked high-priority task is a planning smell: split it or resolve the blocker.

## Keep estimates honest
- Re-estimate when scope changes — new criteria, a spike that surprised you, a split. Update `metadata.size` and `priority` to match reality.
- Record the *why* with `add_comment`: the size rationale, the value/risk/effort call, what a re-estimate changed. This keeps ordering auditable.
- Avoid false precision. Estimates guide ordering and decomposition; they are not contracts. If two tasks feel equal, pick one and move on.

## Progress rolls up (rule)
- **Whenever you change a node's progress — its `status` or `metadata.size` — every ancestor's progress changes with it.** A parent's bar is the size-weighted rollup of its descendants, so moving one task to `done` (or resizing it) recalculates its story, epic and project automatically.
- Progress is **derived, never stored**: it is recomputed from the live tree, so parents can never drift from their children. Never hand-set or cache a parent's progress — fix the leaf and the rollup follows.
- Practical consequence for the pre-sleep flush: update each leaf you touched (status + size) and the parents are already correct — you don't (and shouldn't) separately "update the epic's progress".
