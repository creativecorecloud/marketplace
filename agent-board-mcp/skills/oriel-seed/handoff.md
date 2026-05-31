---
name: handoff
description: Use when parallel agents pass work between each other — declaring task ordering with dependencies and handing off finished or blocked work safely.
---

# Handoff & Dependencies

How parallel agents (Team Leader + discipline workers `<DISCIPLINE><N>`) pass work without colliding or starting on unmet prerequisites.

> Always identify entities by their **key** (e.g. `AB13`) in hand-off comments and references — see `board-usage`. Never by ad-hoc "Story 5".

## Declare ordering before claiming
- When task B must wait on task A, call `add_dependency(blocker_id=A, blocked_id=B)`. B stays non-claimable until A is `done`.
- A blocked task never appears in `list_ready_tasks` while it has an unmet blocker — the filter is automatic, so trust it instead of eyeballing the board.
- When an edge no longer applies (scope changed, blocker dropped), call `remove_dependency(blocker_id, blocked_id)` so the blocked task can become ready.

## Never claim against unmet blockers
- Pick work only from `list_ready_tasks`. It returns tasks that are `ready` AND have zero unmet blockers.
- Do not hand-claim a task you found via the tree or search if it isn't in `list_ready_tasks` — that means a blocker is still open.
- Keep exactly one claim in flight per agent. Finish or release before claiming the next.

## Finishing: the handoff ritual
- Before changing status, `add_comment(HANDOFF: …)` stating: what is done, where the artifact/spec/PR lives, and the concrete next action for whoever picks it up.
- Name the receiving discipline in the comment for cross-discipline handoffs (e.g. "HANDOFF: design tokens finalized in Figma link X — FRONTEND to implement", "backend RPC merged — QA to verify").
- Then `set_status(in_review)` if it needs review, or `set_status(done)` if it's complete. Marking the blocker `done` auto-unblocks anything depending on it.

## Receiving a handoff
- Call `get_entity` once with comments and dependencies included to absorb full context before touching the work.
- Read the `DECISION` comments first — do not re-litigate settled choices; build on them.
- Confirm the upstream artifact/spec referenced in the `HANDOFF` comment actually exists before starting.

## When you're blocked — always create the fix and plan it
Blocking is not the end of the work; it spawns the work that unblocks it. Never leave a `blocked` item with no path forward.
1. `set_status(blocked)`, then `add_comment(BLOCKED: …)` explaining exactly what's missing.
2. **Create a fix item in the SAME epic** that resolves the blocker:
   - A **task** if the blocker is a discrete, independently-testable fix (a bug or a small, technically-defined job). Give it testable acceptance criteria.
   - A **story** if resolving it is a scenario with several related steps/criteria — decompose it into tasks under that story.
   - Put it under the blocked item's epic (same epic), not orphaned elsewhere.
3. **Plan it**: write its acceptance criteria (the "done" that clears the blocker) and set it `ready` (or decompose a story until its leaf tasks are `ready`).
4. **Link it so the unblock is automatic**: `add_dependency(blocker_id=<the fix item>, blocked_id=<this task>)`. When the fix reaches `done`, this task auto-returns to ready — no manual nudge. Cross-reference both ways in a comment.
- Net: every `blocked` item points at a planned, claimable fix in its epic, and clears itself the moment that fix is done.

## Avoid duplicate or conflicting work
- Before picking up a shared-surface task (same file/component/spec another agent may touch), run `get_activity` to see recent claims and comments.
- If another agent already claimed or commented an in-progress handoff on it, defer or coordinate via a comment rather than double-claiming.
