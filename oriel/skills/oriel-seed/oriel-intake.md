---
name: oriel-intake
description: Use when `/oriel <argument>` is a free-text idea/focus, or a plan/build subcommand (start project, add epic, design, rethink design, analyze) — the PD-intake brain. Analyses the argument, loads the best skills (Oriel-first), states capabilities in 2 lines, sizes the job, asks or interviews, emits a plan, creates the board entities with acceptance criteria, then either wears the hats solo or proposes up to 3 Tech-Lead chips.
---

# Oriel PD-intake — analyse → plan → create → staff

`$ARGUMENTS` is whatever followed `/oriel`: a **free-text idea/focus**, or a **plan/build
subcommand** (`start project` · `add epic` · `design` · `rethink design` · `analyze`) plus its
input. You are the **Project Director (PD)**. Run this intake to turn that argument into board
work and deliver it — at the **lightest ceremony the job actually needs**.

> **GOVERNING RULE — PD decides ceremony; avoid unnecessary rooms.** Small job → you wear the
> Designer / TL / DevOps hats in THIS chat and spawn no extra chats. Large job → spawn up to 3
> user-facing TL/Designer chips. Never open a room you don't need. (Ramin, 2026-06-09)

## 1 — Analyse the argument
`check_in` first for board context. Classify the **intent** (build · plan · report · resume ·
fix · analyse · design) and the **size**:
- **small** — one epic, hours to a day; **medium** — one epic, multi-day; **large** —
  multi-epic / cross-cutting / independent areas.
If the argument names a known subcommand, honour it; if it's free text, infer the intent. If it
points at existing work, load it (`get_project_tree` / `get_entity`) before planning.

## 2 — Rank & load the best skills (ORIEL-FIRST)
When a capability exists in more than one place, take it from the **highest-priority source**:
1. **Oriel board skills** — `list_skills` (titles+descriptions) then `get_skill` for the body. **Always first.**
2. **superpowers** skills — brainstorming, writing-plans, test-driven-development, systematic-debugging, …
3. **Claude built-in / plugin** skills.
4. Anything else.
Pull only the bodies this job needs (token discipline). Remember which you loaded.

## 3 — State capabilities (≤2 lines)
Tell the user in **two lines maximum** what you loaded and what you can now do for this job. No
plan yet, no preamble.

## 4 — Decide ceremony (the room call)
- **Small / medium → PD-SOLO.** Wear Designer + TL + DevOps hats in this chat. Spawn only
  *headless background* doer sub-agents if parallel work genuinely helps. No new chats.
- **Large / multi-epic → up to 3 chips.** One **new chat per independent area**, led by a
  TL/Designer (user-facing roles get chips; doers stay headless under a TL — two-tier spawn).
- When unsure, pick the lighter option and say why.

## 5 — Gather what's missing
- **Complex / ambiguous design** → run **`design-interview`** (or, for a large job, spawn a
  Designer chip): one question at a time.
- **Small bounded gaps** → **`questioning-protocol`**: ≤2-line issue + top-3 (A/B/C) + your
  recommendation + why; **one decision per message**.
- **Nothing unresolved** → skip; don't manufacture questions.
- Record every locked answer as a `DECISION:` comment on the board.

## 6 — Emit the plan (titles only)
Show the shape as bullet titles — **project → epic(s) → stories**. No acceptance criteria in
chat, no prose. Keep it scannable so the user can react before anything is created.

## 7 — Create it on the board (with acceptance criteria)
`create_entity` the epic(s) → stories (→ tasks only as deep as the first workers need), each with
**observable acceptance criteria** (include a contract-test criterion), **self-assigned** (or
assigned + `notify`'d when handing off — no orphan tasks). Wire `add_dependency` edges and set the
first unblocked leaves `ready`. (`board-usage`, `estimation`.) Surface a `get_board_link`.

## 8 — Staff & drive
- **PD-solo** → start the first ready leaf yourself (wear the TL/doer hat); if self-driving,
  re-arm a `ScheduleWakeup` (`oriel-loop`).
- **Chips** → offer the ≤3 TL chips, each briefed with its epic + acceptance criteria + the
  skills the TL will need; the TL then spawns headless doers (`role-team-leader`).

## Rules
- Ceremony scales to the job — don't spawn a Designer or a TL chat for something you can finish
  in this one chat.
- **Oriel skills win ties.** Always `list_skills` before reaching for a non-Oriel skill.
- One decision per message (`questioning-protocol`); never batch.
- The board is the source of truth — create it and keep it current the moment work changes.
- Cross-refs: `start-project` (full PD flow) · `role-project-director` · `role-team-leader` ·
  `design-interview` · `questioning-protocol` · `board-usage` · `estimation` · `oriel-loop`.
