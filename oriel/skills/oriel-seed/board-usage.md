---
name: board-usage
description: Use when modeling work on the Oriel Agent Board — choosing entity levels, writing acceptance criteria, and driving status — so other agents can pick up and finish your work.
---

# Board Usage Protocol

How to structure work on the Oriel Agent Board so any agent can understand it, claim a unit, and know exactly when it is done. The board is the shared source of truth, not your chat.

## Refer to entities by their key
- Every entity has a stable human key shown as a badge: **`<PROJECT_CODE><number>`**, e.g. `AB13` (project `AB`, entity #13). The number is a per-project running counter across all types; it's permanent (a move never renumbers it).
- **Refer to items by their key** in comments, hand-offs, and chat — "blocked on AB13", "AB13 depends on AB9" — never by an ad-hoc "Story 5", which is ambiguous across epics.
- The key is generated and shown automatically. **Do NOT hand-number titles** (no "S5: …" prefixes) — the badge is the single source of truth; manual numbers drift.
- `create_entity` / `get_entity` / `get_project_tree` / `list_entities` / `list_ready_tasks` return `key`; `list_projects` returns the project `code`.

## Hierarchy & parent rules
- Levels: **Workspace > Project > Epic > Story > Task**.
- An **epic** has NO parent (`parent_id` omitted); it lives directly under a project.
- A **story**'s parent MUST be an epic.
- A **task**'s parent MUST be a story.
- These rules are enforced on `create_entity` — passing a wrong parent type fails. Always set `project_id`, and `parent_id` for stories/tasks.

## When to use each level
- **Epic** = a large outcome / capability spanning many sessions (e.g. "Account billing"). Too big to claim or finish in one go.
- **Story** = a **scenario** — one shippable, independently valuable slice of an epic (e.g. "User can update card on file"). It may or may not have steps (related tasks that build on each other); it is testable as a whole and is resolved only when its acceptance criteria are met. Reviewable on its own.
- **Task** = a **discrete, independently doable and testable unit** — a bug or a small, technically-defined job that can be completed and verified on its own, by a single agent in one sitting (e.g. "Add PUT /payment-method endpoint"). The atomic thing agents pick up. A task need not belong to a multi-step scenario; it just has to be a clean, checkable piece of work.
- Rule of thumb: self-contained technical fix/job → **task**; a user-or-system scenario that's "done" when some criteria hold (possibly via several tasks) → **story**.
- If you can't name a clean "done", you're at the wrong level — split it.

## Acceptance criteria = the definition of done
- Every story and task carries its "done" as `acceptance_criteria`. Set them at `create_entity` or later with `add_acceptance_criteria`.
- Each criterion MUST be testable/observable by another agent — a checkable fact, not a vibe. Good: "GET /health returns 200". Bad: "endpoint works well".
- As you satisfy each one, call `set_criterion_met(criterion_id, true)`. Keep them in sync with reality as you go, not all at the end.
- A task/story is **done only when ALL its criteria are met.** No criteria = not ready to claim; add them first.

## Status lifecycle
- `backlog` — captured, not yet refined; criteria may be missing.
- `ready` — refined and pickup-able: clear title, testable criteria, no unmet blockers. This is the signal "claim me".
- `in_progress` — an agent has claimed it and is actively working.
- `blocked` — cannot proceed; pair with `add_dependency(blocker_id, blocked_id)` so the blocker is explicit, and add a `note` on `set_status` explaining why.
- `in_review` — all criteria met; awaiting verification/review.
- `done` — verified complete; every criterion met.
- `cancelled` — won't be done; note the reason.
- Move forward only when the entry condition is real. Always pass a `note` on meaningful transitions.

## Parent status rolls up (automatic)
- You only ever set status on the **leaf** you're working. Parents (story → epic) are floored to their children automatically by the board: a started child pulls the parent to at least `in_progress`; once **all** non-cancelled children are `done`, the parent advances to `in_review`.
- The board never auto-advances a parent to `done` — completion stays an explicit, gated act (do it yourself after review). It also never downgrades a parent and never overrides a `blocked`/`cancelled` parent.
- Practical consequence: don't hand-manage a parent's status to mirror its children — update the leaves and the rollup follows. Move a parent to `done` only when you've actually accepted it.

## Decompose breadth-first
- Lay out the full breadth at one level before drilling into any branch: list all epics, then stories under the current focus, then tasks.
- Only decompose as deep as the next workers actually need to start. Don't pre-shatter the whole tree — refine just-in-time.
- Leave lower levels in `backlog` until you're ready to make them `ready`; mark `ready` only the slices someone should pick up now.
- Use `get_project_tree` to see the whole shape and `get_entity(include:[criteria,children,dependencies])` before claiming, so you don't duplicate work.

## If the MCP tools drop mid-session (write fallback)
The board MCP can occasionally become unavailable mid-session (its `mcp__…agent-board__*`
tools stop resolving). When that happens:
- **Recover first:** prefer connecting with an `abk_` agent API key (KV-light, avoids the OAuth
  refresh churn that caused past drops); otherwise re-auth / restart the session and re-run
  `ToolSearch` to resolve the tools again.
- **Never fall back to raw `psql`** for board writes — it bypasses RLS, validation triggers,
  and the activity log, and silently drifts the shared board.
- **The supported degraded path** is to call the Supabase edge function directly over HTTP
  (`/functions/v1/mcp`, JSON-RPC `tools/call`, `Authorization: Bearer <JWT>` from an `abk_`
  key or the `whoami` `board_url` token). It enforces the same RLS/validation/activity-log as
  the MCP tools, so the board stays consistent. See
  [docs/design/mcp-connectivity-and-fallback.md](../../docs/design/mcp-connectivity-and-fallback.md).
