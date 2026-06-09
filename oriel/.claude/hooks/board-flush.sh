#!/bin/sh
# board-flush.sh — Claude Code Stop / SessionEnd hook (Oriel Agent Board).
#
# Job: emit a short reminder telling the agent to run the pre-sleep BOARD FLUSH
# before it winds down. The hook does NOT call MCP or the network itself — the
# agent performs the actual MCP calls. See skills/oriel-seed/lifecycle-hooks.md.
#
# SAFETY / graceful degradation: this script only prints text and always exits
# 0. It makes no network calls, touches no DB, and requires no creds or tools —
# so it can never error or block a session, even when the board MCP or its
# credentials are absent. The flush itself is idempotent: if check_in reports
# should_check=false / nothing changed, the agent stops (near no-op).
set -u

cat <<'EOF'
[oriel-board] Stop/SessionEnd — BOARD FLUSH reminder (pre-sleep)

Before you sleep / end the chat, run the board flush (idempotent — if nothing
changed and check_in says should_check=false, stop). Skip silently if the
agent-board MCP tools or creds are unavailable.

A. Push MY progress (only if something changed):
   - set_status on each entity you moved (respect Done = all criteria met/disabled).
   - set_criterion_met for any acceptance criterion you newly satisfied.
   - add_comment(HANDOFF: ...) on in-flight work so the next agent resumes cold.
   - If stuck: set_status(blocked) + create & link the fix item.

B. Make sure nobody is stuck behind me:
   - check_in(since=cursor) then get_activity(since=cursor).
   - Answer anything waiting on you (questions, dependencies you block, reviews).
   - Advance your activity cursor so the next session starts clean.

This is a reminder only. No board state is changed by this hook.
EOF

exit 0
