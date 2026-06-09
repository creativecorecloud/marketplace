---
name: agent-briefing
description: Use when standing up multi-agent coordination on the Oriel Agent Board, or adapting a legacy FILE-BASED agent methodology (AGENT_BRIEFINGS.md / docs/inbox / state-file + signal-file style) onto it — the briefing doctrine for WHICH coordination is board-native and which legacy artifacts you must NOT rebuild as files, docs, or comments.
---

# Agent Briefing — the board IS the operating manual

Load this on spawn next to `startup-protocol`. It owns ONE thing the other skills assume but never
state: **the board is the coordination substrate, and it replaced the old file-based machinery whole
— you don't port that machinery onto the board, you delete it.** Everything else (roles, cadence,
modeling, merge, asking the user) is owned elsewhere — this skill routes you there, it does not repeat it.

A legacy "agent briefing" (committed YAML state, signal files, message files, cron polling a wake-file,
a generated inbox digest) splits three ways when it meets the board:
- **REPLACED** — the coordination plumbing. The board does it natively. ← **this skill owns this half.**
- **ADAPT** — the intent (who leads, how a tick runs, how work is shaped). Lives in the role/loop skills below.
- **KEEP** — engineering discipline (code-trace, compile gates, tester modes, model-by-role, branch hygiene).
  Substrate-independent; already owned by `role-team-leader` / `contract-test` / `merge-protocol`. Unchanged.

## Retired artifact → board-native equivalent (don't rebuild the left column)

| Legacy file-based artifact | Board-native replacement | Tool |
|---|---|---|
| `state/*.yaml` shared coordination state | entities + their status; there is **no** shared state file | `get_project_tree` / `set_status` |
| `active.yaml` (who's active, TL rows, phase) | board membership + live entity status | `find_agents` / `list_entities` |
| `portfolio.yaml` (initiatives/epics index) | projects + epics on the board | `list_projects` / `get_project_tree` |
| `po-queue.yaml` (questions for the user) | a `DECISION:`/question **comment**, surfaced per `questioning-protocol`; if stale → notify | `add_comment` / `notify` |
| `devops-queue.yaml` (deploy / devops asks) | a **request** entity to the deciders; the resource itself reserved/frozen | `create_entity(kind:'request')` / `reserve` / `freeze` |
| `wake-pd.signal` (event file the lead polls) | the tick's own counts + activity; wakeups via notifications | `check_in` (`new_events`) / `get_activity` / `get_notifications` |
| `messages/*.md` (agent→agent message files) | a comment on the entity | `add_comment` (see `commenting`) |
| `inbox.md` (generated human digest) | the **visual board** + chat | `whoami` `board_url` / `render_report` |
| `epics/EPIC-*.md` (DoD, progress log) | the Epic entity + its acceptance criteria + comments | `add_acceptance_criteria` / `set_criterion_met` |
| `completed/` · `archive/` (closed-work archive) | board history — `done`/`cancelled` status + the activity log | `get_activity` |

## Anti-patterns — file-based habits to drop on day one
- **No coordination state in committed files.** No status/queue/index YAML, no per-epic markdown pages.
  The board holds the state; a file copy only drifts from it.
- **No signal / wake / message files.** A tick learns what changed from `check_in` counts; teammates
  reach you through comments, status, dependencies, and notifications — never a file you both edit.
- **No fan-out-to-be-visible.** One board write is atomically visible to everyone. Writing the same fact
  to several places "so nobody misses it" is the file-era reflex the board exists to kill.
- **No human inbox digest.** The human reads chat + the board; hand them the `board_url` as a clickable
  link (and `render_report`'s link). Don't curate a digest of internal state for them.

## Two legacy policies that do NOT survive — delete, don't migrate
These were scar tissue from file fragility; the board removes the wound, so porting them is pure waste:
- **The same-commit "triple-write"** (surface a question by editing a queue file + a signal file + a
  status row in one commit) → **one `add_comment`** (plus a `notify` only if it goes stale). It is already
  atomic and already visible; there is nothing to fan out and nothing to keep in sync.
- **The lead's "reconciliation sweep"** (grep commits / pages to catch questions a teammate forgot to log
  in all three places) → **unnecessary.** A comment/notification is a first-class, never-dropped object;
  the visibility gap that watchdog patched cannot occur on the board.

## Where the rest of the briefing lives (load these — this skill won't repeat them)
- **Roles, lifetimes, staffing, caps, model-by-role** → `role-project-director`, `role-team-leader`
- **Spawn-up: identity / membership / scope** → `worker-onboarding`, `startup-protocol`
- **Per-tick cadence (check_in gates the tick)** → `agent-loop`
- **Modeling work, keys, status lifecycle** → `board-usage`
- **Closure gates + contract tests** → `contract-test`
- **Merge / worktree / green gates** → `merge-protocol`
- **Asking the human a decision** → `questioning-protocol`
- **Recording decisions & handoffs as comments** → `commenting`, `handoff`
- **Pre-sleep flush + session continuity** → `lifecycle-hooks`
- **The cross-cutting rules every agent follows** → `startup-protocol`
