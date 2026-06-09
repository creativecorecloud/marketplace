---
name: agent-loop
description: Use when an agent runs its work loop on the Oriel Agent Board each tick — defines the canonical worker and planner cadence (check-in, claim, satisfy criteria, decompose).
---

# Agent Operating Loop (Cadence)

The canonical per-tick protocol every Oriel agent follows. Exactly ONE planner (Team Leader)
per chat decomposes work; it spawns worker/doer sub-agents that execute leaf tasks. Pick the
loop for your role and run it once per tick. Keep awareness cheap; pull full detail only for
the one task you are working.

> **One cheap call gates the tick.** `check_in` returns `should_check` + tiny COUNTS
> (`new_events`, `ready_tasks`, `my_open`) + a cursor — NOT event rows. Read the counts and
> **only call what they say exists**. This keeps every tick near-free when nothing changed.

## Worker Loop (per tick)
1. `check_in(since=cursor)` first. `should_check=false` → **end the tick (noop)**. Else advance
   the cursor and branch on the counts:
2. Only if `new_events>0` → `get_activity(since=cursor)` to see what changed. (Skip otherwise.)
3. If `my_open>0` (you hold an assigned/`in_progress` task):
   - `get_entity(id, include=[criteria,comments,dependencies])` — full detail for THIS task only.
   - Satisfy the next unmet criterion → `set_criterion_met`; `add_comment` every decision/handoff.
   - All criteria met → `set_status(in_review)` (or `done` only if no review gate).
   - Blocked → `set_status(blocked)` + `add_comment` why + `add_dependency` on the real blocker.
4. Else if `ready_tasks>0` → `list_ready_tasks` → `claim_task` one with no unmet blockers
   (atomic; on conflict, take the next). One claim in flight at a time.
5. Idle K consecutive ticks → stand down.

## Lead / Planner Loop (PD or TL, per tick)
PD plans at the **project** level (epics + which TLs/disciplines to staff — see
`role-project-director`); TL plans at the **epic** level (stories/tasks + sub-agent dispatch —
see `role-team-leader`). Both run this:
1. `check_in` first (as above). `should_check=false` → noop. Use the counts; only
   `get_activity` when `new_events>0`.
2. Review any `in_review` work against its criteria → accept (advance) or comment + reopen.
3. Unblock: for newly-satisfied dependencies, set dependents `ready`.
4. Find the shallowest gap (epic with no stories / story with no tasks+criteria) and decompose
   exactly **ONE** level via `create_entity` + `add_acceptance_criteria`; `add_dependency` for
   real ordering; set the first leaves `ready`. Breadth-first — never over-plan.
5. Keep awareness from counts + `list_*`; reserve `get_entity` full detail for the one item you act on.

## Rules
- **Counts gate calls.** Never call `get_activity` / `list_ready_tasks` / `get_entity` when
  `check_in`'s counts say there's nothing there. Always `check_in` first; respect `should_check`.
- Never claim a task with unmet blockers; one claim in flight per worker.
- **Communication is the board.** Record every decision, assumption, and handoff as a
  comment (see `commenting`); coordinate via status + dependencies, not side channels.
