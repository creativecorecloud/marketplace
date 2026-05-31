---
name: commenting
description: Use when posting on a shared Agent Board — structured comment markers so agents coordinate decisions, handoffs, and blockers without losing the thread.
---

# Commenting & Handoff Protocol

Comments are the durable record of decisions and handoffs between agents and from the human. Use `add_comment(entity_id, body)` to write; `get_entity(include:[comments])` and `get_activity` to read. Comment to coordinate — not to narrate. No play-by-play.

## Markers (one per comment)
Start every comment with exactly one marker so others can scan and route fast.

- `DECISION:` — a locked choice plus a 1-line rationale. Prevents others relitigating. Example: `DECISION: use cursor pagination, not offset — stable under concurrent writes.`
- `AC:` — clarifying or adding an acceptance criterion in discussion. Reference the criterion or entity it refines.
- `BLOCKED:` — why work stopped and exactly what's needed to unblock. Always pair with `set_status(blocked)` and `add_dependency` on the blocking entity.
- `HANDOFF:` — the state at the moment you pass work on (see below).
- `[report]` — a user-directed request originating from the report artifact. Treat as a priority instruction from the human; act on it before lower-priority self-directed work.

## Writing rules
- One marker per comment. Split unrelated points into separate comments.
- Keep each comment self-contained — readable without scrollback or external context.
- Reference entity ids and criteria when relevant (e.g. "blocks STORY-12", "satisfies AC #2").
- Record decisions, handoffs, and blockers. Skip status pings, "starting now", and intermediate progress.

## HANDOFF contents
Before standing down, a worker MUST post a `HANDOFF:` capturing:
- Done — what is complete and verified.
- Left — what remains, with the next concrete step.
- Where to look — files, ids, branches, or comments the next agent needs.
- Gotchas — traps, assumptions, or fragile spots discovered.

## Roles
- Workers: post `HANDOFF:` before standing down; post `BLOCKED:` (with status + dependency) the moment work stops.
- Planners (Team Leader): read comments via `get_entity(include:[comments])` before re-decomposing or reassigning — honor existing `DECISION:` and `[report]` markers rather than re-deriving them.
