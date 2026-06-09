#!/bin/sh
# board-startup-load.sh — Claude Code SessionStart hook (Oriel Agent Board).
#
# Job: emit a short reminder telling a primary/Team-Leader agent to run the
# board STARTUP LOAD. The hook does NOT call MCP or the network itself — the
# agent performs the actual MCP calls. See skills/oriel-seed/lifecycle-hooks.md.
#
# SAFETY / graceful degradation (AB18): this script prints the reminder, then
# self-installs the local pre-push green-gate hook (rule 18) — a single, local,
# idempotent `git config core.hooksPath .githooks`. It makes no network calls,
# touches no DB, and requires no creds — only local git config — and ALWAYS exits
# 0, so it can never error or block a session, even when git or the board MCP is
# absent. The agent decides at runtime whether the board tools are reachable.
set -u

cat <<'EOF'
[oriel-board] SessionStart — STARTUP LOAD reminder

If you lead or work a project here, onboard now (skip silently if the agent-board
MCP tools or creds are unavailable; load skill BODIES lazily — only when needed):
  1. whoami. New project -> run /start-project <idea>. Existing -> load it
     (get_project_tree / get_entity). Not a member of any workspace yet?
     get_skill('joining-the-board') — name yourself + request workspace
     membership (any operator approves), then use your own project.
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
  7. FLOW CHART — regenerate ON REQUEST, not on every change. Changing an EPIC
     (status, or add/remove/rename) marks the project's flow map STALE; surfacing
     that to the user is the mandatory part — regenerating is NOT. Tell the user
     it's stale and let THEM decide, then regenerate only when they ask:
     get_skill('mermaid') + set_project_flowchart(project_id, mermaid). Do NOT
     auto-regenerate inline.
The pre-sleep flush hook is already wired in .claude/settings.json.

This is a reminder only. No board state is changed by this hook.
EOF

# --- Self-install the pre-push green-gate hook (rule 18; idempotent, local) ----
# develop must stay compilable because every agent forks its worktree from it.
# Ensure THIS repo routes git hooks at the tracked .githooks/ so a push to
# develop is type-checked locally. Relative path => every worktree inherits it.
#
# This same script is bundled in the packaged plugin (hooks/hooks.json points at
# ${CLAUDE_PLUGIN_ROOT}/.claude/hooks/board-startup-load.sh), so on SessionStart it
# can run inside ANY repo the plugin is installed in. It must therefore touch git
# config ONLY when the project IS the agent-board-mcp repo — never an external
# user's repo. Identity is proved by BOTH our tracked .githooks/pre-push AND a
# .claude-plugin/plugin.json named "agent-board-mcp". Quiet + idempotent: acts
# only when not already wired. Never errors (always exit 0 below).
ab_dir="${CLAUDE_PROJECT_DIR:-}"
if command -v git >/dev/null 2>&1 && [ -n "$ab_dir" ] \
   && [ -f "$ab_dir/.githooks/pre-push" ] \
   && [ -f "$ab_dir/.claude-plugin/plugin.json" ] \
   && grep -q '"name"[[:space:]]*:[[:space:]]*"agent-board-mcp"' "$ab_dir/.claude-plugin/plugin.json" 2>/dev/null; then
  current=$(git -C "$ab_dir" config --get core.hooksPath 2>/dev/null || true)
  if [ "$current" != ".githooks" ]; then
    if git -C "$ab_dir" config core.hooksPath .githooks 2>/dev/null; then
      echo "[oriel-board] installed local pre-push green-gate (core.hooksPath=.githooks; rule 18)."
    fi
  fi
fi

exit 0
