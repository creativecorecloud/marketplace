---
name: lifecycle-hooks
description: Use when a primary/Team-Leader agent starts working a project — installs a pre-sleep board-sync hook and starts the work loop, so progress is always flushed and no teammate is left waiting before the agent sleeps.
---

# Lifecycle Hooks (start the loop, flush before sleep)

A primary agent's board state must never go stale just because the chat went quiet. This protocol is the bookend around the work loop (see `agent-loop`): set up at the start, sync at the end. Do it once at project/team start; the Stop hook then fires automatically on every wind-down.

## At project/team start (the lead — PD or TL)
Right after onboarding (`role-project-director` / `role-team-leader` / `worker-onboarding`) and reading `get_conventions`:
1. **Start the work loop.** Begin the lead/worker loop from `agent-loop` — `check_in` first each tick, and let its counts gate every further call.
2. **Install the pre-sleep hook.** Write a `Stop` (and `SessionEnd`) hook into `.claude/settings.json` that runs the **Board flush** below. This makes the flush deterministic — it fires even if the agent forgets. If a hook is already present, leave it; don't duplicate.
   - The hook's job is only to trigger the flush steps; the agent performs the actual MCP calls.
3. Record setup with an `add_comment` on the project's lead entity so the team has an audit trail ("primary agent up; loop started; pre-sleep hook installed").

## Board flush — runs before the agent sleeps / ends the chat
Two halves, both required. Keep it cheap; skip work that didn't change.

### A. Push MY progress (only if something changed)
- For each entity you claimed or touched this session whose state moved: `set_status` to reflect reality (`in_progress`/`in_review`/`blocked`/`done` — respecting the rule that Done needs all criteria met or disabled).
- `set_criterion_met` for any acceptance criterion you newly satisfied.
- `add_comment(HANDOFF: …)` on your in-flight item: what's done, what's next, where the artifact/spec is — so the next agent can resume cold.
- If you're stuck, follow `handoff`: `set_status(blocked)` + create & link the fix item. Never sleep on a silent block.

### B. Make sure nobody is stuck behind me
- `check_in(since=cursor)` then `get_activity(since=cursor)` to pull what changed while you worked.
- Answer anything waiting on you before you leave: a comment that asks you a question, a dependency where you're the blocker, a review assigned to you. Resolve or explicitly hand it off with a comment — don't leave a teammate blocked on your silence.
- Advance your activity cursor so the next session starts clean.

## Rules
- The flush is idempotent — running it when nothing changed is a near-noop (check_in says `should_check:false` → stop).
- Own-progress first (A), then unblock-others (B): update reality before you check who's waiting on it.
- This protocol is mandatory for the primary/Team-Leader agent; spawned workers run at least half A on stand-down.

## Lifecycle hooks — what's wired (epic AB25)
The bookends above are now wired as Claude Code lifecycle hooks in
`.claude/settings.json`, backed by two dependency-free POSIX `sh` scripts in
`.claude/hooks/`. **The hooks never perform board work themselves** — each only
prints a reminder; the agent performs the actual MCP calls. Both scripts always
`exit 0`, make no network calls, and need no creds, so they can never error or
block a session (graceful degradation, AB18).

| Lifecycle event | Hook script | What it reminds the agent to do |
| --- | --- | --- |
| `SessionStart` | `board-startup-load.sh` | Run the **startup load**: `whoami` → `/start-project` (new) or load existing → `get_conventions()` → load your role skill (`role-project-director`/`role-team-leader`/`worker-onboarding`) + protocols → begin the loop (`check_in` first; counts gate calls). |
| `Stop` | `board-flush.sh` | Run the **board flush** (part A push my progress, part B unblock others) before winding down. |
| `SessionEnd` | `board-flush.sh` | Same flush, on full session teardown. |

**How an agent should respond to each hook:**
- *On the SessionStart reminder* — if you are the primary/Team-Leader agent,
  perform the startup load described above. If the agent-board MCP tools or
  creds are unavailable, skip silently; do not treat it as an error.
- *On the Stop / SessionEnd reminder* — run the Board flush (sections A then B).
  It is idempotent: if `check_in` returns `should_check:false`, stop. Skip
  silently if the board MCP is unavailable.

Spawned (non-primary) workers see the same reminders and should at minimum run
flush part A (push their own changed progress) on stand-down.

If `.claude/settings.json` already exists when wiring this, **merge** the
`SessionStart`/`Stop`/`SessionEnd` entries in rather than clobbering — and don't
duplicate a hook that's already present.
