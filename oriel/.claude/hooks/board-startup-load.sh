#!/bin/sh
# board-startup-load.sh — Claude Code SessionStart hook (Oriel Agent Board).
#
# Job: emit a short reminder telling a primary/Team-Leader agent to run the
# board STARTUP LOAD. The hook does NOT call MCP or the network itself — the
# agent performs the actual MCP calls. See skills/oriel-seed/lifecycle-hooks.md.
#
# SAFETY / graceful degradation (AB18): this script only prints text and always
# exits 0. It makes no network calls, touches no DB, and requires no creds or
# tools — so it can never error or block a session, even when the board MCP or
# its credentials are absent. The agent decides at runtime whether the board
# tools are reachable and silently skips the load if they are not.
set -u

cat <<'EOF'
[oriel-board] SessionStart — STARTUP LOAD reminder

If you lead or work a project here, onboard now (skip silently if the agent-board
MCP tools or creds are unavailable; load skill BODIES lazily — only when needed):
  1. whoami. New project -> run /start-project <idea>. Existing -> load it
     (get_project_tree / get_entity).
  2. get_conventions() — the operating loop.
  3. Load your role skill + protocols: role-project-director (PD) OR
     role-team-leader (TL) OR worker-onboarding (worker); plus agent-loop,
     lifecycle-hooks, board-usage, contract-test.
  4. Begin the work loop — check_in FIRST each tick; let its counts
     (new_events / ready_tasks / my_open) gate every further call, so quiet
     ticks stay near-free.
  5. Coordinate ONLY through the board (comments / status / dependencies); hand
     the agent-board MCP skill to any sub-agent that must talk to other agents.
  6. CLOSE EPICS ASAP — a key goal. Each tick, find epics/stories whose children
     are all done (criteria all met-or-disabled) and close them now. Don't leave
     an epic in_review behind finished children; resolve the blocker (validate +
     tick a criterion when evidence exists; only disable with a documented reason).
The pre-sleep flush hook is already wired in .claude/settings.json.

This is a reminder only. No board state is changed by this hook.
EOF

exit 0
