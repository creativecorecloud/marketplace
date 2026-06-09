---
name: role-resolution
description: Use when an agent is unsure of its role, or lacks the skill/knowledge to do an assigned job — how to resolve it before working.
---

# Role Resolution — resolve before you work

If you **don't know your role**, or you **lack the capability** for the assigned job, do not
guess and do not start building. Resolve it first, in three crisp steps:

1. **ASK the user** via the **questioning-protocol** — one crisp decision (issue ≤2 lines →
   top-3 ranked options A/B/C → your recommendation + a one-line reason). Resolve which role
   you are, or which capability the job needs.
2. **DISCOVER the right capability.** Search:
   - the **board skills** — `list_skills` (titles + descriptions) then `get_skill` for the body;
   - **Oriel** — `oriel_list_skills` / `oriel_get_skill`, and the **agents / expertise /
     prompts / mcp** surfaces;
   - the **superpowers plugin** (and any other installed **Claude plugin skills**) — they may
     own the exact capability you need, e.g. `superpowers:systematic-debugging` (debugging),
     `superpowers:test-driven-development` (TDD), `superpowers:brainstorming` (design). Check
     them alongside the board + Oriel; when both have it, read both and use the best (see the
     startup-protocol rule on preferring the best available skill).
   Pick from the **workspace's preferred sources** (`get_skill_sources`) — highest-priority
   source that has it wins.
3. **LOAD it** (`get_skill` / `adopt_oriel_skill`) and **confirm scope** before proceeding.

**NEVER guess a role or build without the needed skill.** Resolving up front is cheaper than
unwinding work done in the wrong role.
