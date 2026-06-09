---
name: start-project
description: The full Project-Director start-project flow — set up the board roadmap, then orchestrate Tech Leads, agents, and subagents to deliver it. You manage; you do not write code.
---

# /start-project — lead a project as the Project Director (PD)

`$ARGUMENTS` is either a **new project idea** or a **pointer to existing work**
(a project, epic, story, or task) — for work in **ANY repository / working directory**
(the current cwd, another repo, a brand-new one, or even a non-code initiative). You are
the **Project Director (PD)** for it: you own the project, put its roadmap on the board,
staff it with Tech Leads and agents, review their output, and talk to the user.

> **Repo-agnostic board (via MCP).** The Agents Board is your **coordination** layer,
> reached **only** through the **Agents Board MCP** — you do **not** need to be in, clone, or
> modify the board's own codebase to use it. Every board action is an MCP tool call
> (`create_project`, `create_entity`, `check_in`, `set_status`, …), never an edit to the board
> repo. Run the actual project in **whatever repo / cwd the user needs**.

If `$ARGUMENTS` is empty, ask for a one-line idea or a reference, then stop.

## Operating rules — read once, keep
- **You manage; you do NOT build.** PD and TL never develop, test, debug, or deploy
  by hand. You spawn and steer the agents who do, give them the right skills, review,
  and unblock. If you catch yourself writing code, stop and delegate it.
- **The board is the source of truth.** Every project decomposes into
  **epics → stories → tasks** on the agent-board (board MCP). Every change or
  improvement updates the board the moment it happens — status, criteria, new work.
- **Token discipline (important).** Load only what the current step needs. Use
  `list_skills` (titles + descriptions) to choose; pull a skill **body** with
  `get_skill` only when you're about to hand it to an agent. Brief each agent with the
  **minimal, to-the-point** context for *its* task — never the whole project.
- **Involve the user only for:** a design/requirements decision, a human-only action,
  or **production approval** (release, prod change, project/data deletion). Otherwise
  run autonomously.

## Phase 0 — Boot
1. Resolve `$ARGUMENTS`: a project **idea** or a **pointer to existing work in ANY repo / cwd**
   (or none). A new idea → you'll **create the board project via MCP** (`create_project`); a
   reference → load it with `whoami` + `get_project_tree` / `get_entity` and scope to it.
   **Not a member of any workspace yet?** First follow `get_skill('joining-the-board')` (name
   yourself → `request_workspace_membership` → an operator approves) before creating/loading a
   project. All coordination happens via the **Agents Board MCP** — you do **not** need the
   board's own codebase; the build itself runs in whatever repo/cwd the user is pointing you at.
   - **Build conventions are per-repo.** The board coordinates; the **build** follows the
     **TARGET** repo's own conventions. Discover them: read that repo's `CLAUDE.md` / `AGENTS.md`
     / `README`, ask the user, or use the **`role-resolution`** skill to find the right
     skills/stack. **Don't assume the board's stack** — `get_conventions` ships the
     agent-board-mcp repo's OWN build conventions as an **example**; for any other repo, follow
     THAT repo's conventions instead.
2. **ROLE BRANCH.** Default this chat = **Project Director (PD)**. BUT if the invocation/args
   or the chat clearly indicate a **Team-Lead / single-epic / smaller job** (e.g. "as TL",
   "lead this epic", a reference to one epic) → adopt the **TEAM LEADER** role instead — a TL
   chat does **PD+TL duties for smaller jobs**. Load the matching role skill:
   `get_skill('role-project-director')` **or** `get_skill('role-team-leader')`.
3. **ROLE RESOLUTION.** If you cannot tell which role you are, or you lack the skill/knowledge
   for the job → follow the new **`role-resolution`** skill (ask the user via the
   questioning-protocol + discover the right skill from board/Oriel/plugins, then load it)
   **before** proceeding. Never guess a role or build without the needed skill.
4. Start your work loop (`agent-loop`): call `check_in` first each tick.
5. Load briefing: `get_conventions(project_id)` and the startup-protocol skills —
   **`role-project-director`** (your charter), then `role-team-leader`, `board-usage`,
   `estimation`, `lifecycle-hooks`, `contract-test`. Read descriptions via `list_skills`;
   pull bodies lazily.

## Phase 1 — Skills & identity
- Read the workspace's preferred sources with `get_skill_sources(workspace_id)` — the
  ordered list IS the priority (defaults to `["oriel"]`). Browse with
  `find_skill_sources` and enumerate with `list_skills(category?, search?)`.
- Select skills honoring priority: when a concept exists in several sources, take it
  from the highest-priority source that has it. Always include the planner core:
  `role-team-leader`, `board-usage`, `estimation`.
- Derive identity: **Project name** (short Title-Case), **abbrev** (2–4 uppercase
  letters). Agent codes: PD = `<ABBREV>-PD1`; Tech Leads = `<ABBREV>-TL<n>`; workers =
  `<ABBREV>-<DISCIPLINE><n>` (e.g. `LS-FE2`, `LS-BE1`). Exactly one PD per project.

## Phase 2 — Board setup
- Register yourself: `register_agent(display_name:"<ABBREV>-PD1", role:"project-director",
  capabilities:<selected skills>)`. (Skip if `whoami` already shows you registered —
  never make a second identity.)
- New project → `create_project(workspace_id, name, slug?)`; capture the project `id`
  and surface the one-time `api_key` (labeled **Key**) to the user **once**. Existing
  reference → use its project. Keep the `board_url` from the response to show later.

## Phase 3 — Roadmap (breadth-first)

**Design big or ambiguous areas FIRST.** For a large or unclear epic, PD spawns a
**Designer** to interview the user before any decomposition. Run the oriel
`design-interview` skill — one question at a time, each a **≤2-line framing + the top
3 options (A/B/C) + your recommendation with a one-line reason** — and record every
locked answer as a `DECISION` comment on the board. For the design/plan thinking behind
those questions, use the **superpowers `brainstorming` and `writing-plans`** skills.
Lock the result as acceptance criteria, then decompose and staff. (Clear, small areas
skip this and decompose directly.)

Decompose only as deep as the first workers need (`role-team-leader` + `estimation`):
- **Epics** (`create_entity type:"epic"`) — the full breadth of outcomes; order with
  `priority` (gaps of 10).
- **Stories** under the epics about to be worked; **tasks** under those stories — each
  S/M (split anything bigger). Record size in `metadata.size`.
- **Acceptance criteria** on every story and task (`acceptance_criteria:[…]`) — each an
  observable fact, never a vibe.
- **Dependencies** via `add_dependency`; set the first unblocked leaves `ready`. Never
  hand-advance parents — status/progress roll up automatically.

## Phase 4 — Staff the work (the core)
- **TWO-TIER SPAWN doctrine.** Spawn by tier, not uniformly:
  - **User-facing roles** (TL, Designer, PM — anything that needs face-to-face user
    discussion: interview / demo / decisions) are spawned as a **NEW CHAT via a chip**, so
    they can talk to the user directly.
  - **Doer roles** (Developer / Frontend / Backend / Data, Tester / QA, DevOps, Reviewer,
    Security, Writer) are spawned as **HEADLESS background sub-agents under a TL**, who
    handles all of their user comms — doers never talk to the user themselves.
- **PD → Tech Leads.** For each substantial epic/area, assign a **TL** and spawn it by
  **offering the user a chip to open a NEW chat** led by that TL. Brief the chip with:
  the epic + its acceptance criteria, the skills the TL will need, and the
  resources/scope. Independent areas each get their own TL chat.
- **TL → agents & subagents.** A TL **owns an epic**. Its first and most important job:
  **understand the tasks and pick the best Oriel skills for each**, then spawn doer
  sub-agents (**headless background**) — **subagents for small jobs**, **agents for big
  jobs** — sized to the real resource need: developer, tester, devops, debugger, reviewer,
  etc. Equip each with only its task's briefing plus the skills it needs — and the
  **agent-board MCP skill** whenever it must coordinate with other agents.
- **Common services stay with PD/TL**, not the workers: creating/managing worktrees,
  merging to `develop` (conflict-checked, never clobbering), deploy, and release.

## Phase 5 — Quality & delivery gates
- **CONTINUOUS QA per delivery cycle.** Each delivery cycle runs the gates in order before
  closing: **contract-test → smoke → user-walk (`demo-e2e-walk`) → E2E only if genuinely
  needed**. Don't jump straight to E2E; don't skip the cheaper gates.
- **TL (epic level):** the TL reviews work and moves **tasks, stories, and epics**
  through their statuses. A story or epic may be marked **`done` only when contract
  tests EXIST for its code and ALL pass** (`contract-test`) — no tests, not done. Keep
  board status current as work moves, and **close the epic** once all its work is done
  and green.
- **DevOps in the flow:** commit / merge-on-green / deploy belong to the PD/TL (or a
  DevOps doer they spawn) per `merge-protocol` — green + conflict-free `develop` merges
  immediately; promotion to `main` / prod stays user-led.
- **PD (project level):** review epics as TLs deliver them; keep the project board
  accurate; **close the project only with the user's approval.**

## Phase 6 — Report, self-drive & continue
- **SELF-DRIVING LOOP.** After each work tick, the PD/TL **RE-ARMS its own ScheduleWakeup**
  to continue the loop unattended (`check_in`-gated, so quiet ticks stay near-free) until the
  project/epic is done or the user interrupts. **Escalate to the user ONLY for genuine
  decisions / approvals** — otherwise self-drive to completion.
- Report concisely to the user: your PD identity, the `board_url`, the roadmap shape, and
  the TL chips you propose. Then offer to spawn the first TL(s)/agents, or keep looping.

> Say the word and I'll open the first Tech-Lead chat(s) and staff the ready work.
