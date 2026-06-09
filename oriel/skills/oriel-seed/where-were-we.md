---
name: where-were-we
description: Use for `/oriel where were we` — a read-only recap that replays recent board activity and your own open work to answer "where did we leave off?": last activity, what's in-flight, the next unblocked leaf, and open questions. Makes no writes.
---

# Where were we? (read-only)

`$ARGUMENTS` optionally names the project (default: the one you're driving / most recent).
**Read-only.**

## Gather
- `check_in(since=cursor)` — what changed since you last looked + unread.
- `get_activity(project_id, since=cursor)` — the recent event trail.
- `get_my_work()` — your assigned / in-flight items.

## Render
- **Last session ended here:** the most recent meaningful events (merges, status changes,
  decisions).
- **In-flight:** your `in_progress` / `in_review` items.
- **Next unblocked:** the leaf you'd pick up next (and why).
- **Open questions:** anything waiting on a user decision/approval.

## Rules
- Strictly read-only — `check_in`, `get_activity`, `get_my_work`, `get_entity` only. To then
  act on it, use `continue`.
- Be specific (entity keys, not vibes). Keep it to a short brief.
- Cross-refs: `continue`, `agent-loop`, `board-usage`.
