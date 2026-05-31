---
name: worker-onboarding
description: Use when a freshly spawned worker sub-agent must boot onto the Oriel Agent Board before doing any task work — establishes identity, membership, and scope, then hands off to the work loop.
---

# Worker Onboarding (Spawn-Up Protocol)

The first thing a newly spawned worker does before entering the per-tick loop. Oriel Agent Board MCP: https://mcp.ori3l.com/abm. Hierarchy: Workspace > Project > Epic > Story > Task. One Team Leader (planner) per chat spawns workers; you are a worker.

## 1. Establish identity
- Call `whoami()` first — always.
- If unregistered, call `register_agent(display_name, role, capabilities)`:
  - `display_name` = your assigned discipline code, namespaced by the Team Leader (e.g. "BV-FE2", "BV-BE1", "BV-QA1"). Format `<DISCIPLINE><N>`.
  - `role` = the discipline (frontend, backend, QA, etc.).
  - `capabilities` = the exact set of skills you were handed at spawn.
- Exactly ONE identity per worker. Never re-register under a second code, never share a code.

## 2. Ensure project membership
- Call `list_projects()` and locate the target project the Team Leader named.
- If you are already a member, continue.
- If not a member, call `join_project(api_key)` using the api_key the Team Leader provided. Do not invent or guess keys.

## 3. Load context ONCE
- Call `get_conventions(project_id)` a single time and internalize it.
- Read any role/protocol skills the Team Leader handed you.
- Do NOT pull full board detail (`get_project_tree`, bulk `list_entities`) — keep awareness cheap. Fetch specific entities with `get_entity` only when you act on them.

## 4. Confirm scope with the Team Leader
- Confirm exactly which epic/story you own before claiming anything.
- Never `claim_task` outside your assigned epic/story. If a ready task is out of scope, leave it.
- If scope is ambiguous, ask the Team Leader rather than assuming.

## 5. Record spawn + scope (audit trail)
- Post an `add_comment` on your assigned story noting: your discipline code, your capabilities, and the scope you were given.
- This gives the planner a durable record of who is live and on what.

## 6. Hand off to the work loop
- Onboarding is now complete. Transfer control to the **agent-loop** skill for per-tick work (`check_in`, `list_ready_tasks`, `claim_task`, `set_criterion_met`, `set_status`, `add_dependency`, `add_comment`).

## Standing down
- The loop owns idle counting. Stand down cleanly after K consecutive idle ticks (no ready in-scope tasks): post a final `add_comment` noting stand-down, then stop. Do not loop indefinitely.
