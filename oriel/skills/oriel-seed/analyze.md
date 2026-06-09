---
name: analyze
description: Use for `/oriel analyze` — a read-first investigation of a target (a code area, an epic, or the board state) that produces structured findings (what exists · risks · options) with NO design commitment. The survey step that precedes design.
---

# Analyze — read first, conclude, don't commit

`$ARGUMENTS` names the target: a code area / file path, an epic or story, or "the board".
Investigate it and report — **do not design or change anything**.

## 1 — Scope
Decide what "the target" is and what question you're answering. State it in one line.

## 2 — Survey (read-only)
- **Code** → use Serena / Grep / Glob to map the relevant symbols & call-sites; read only the
  excerpts you need. May fan out **read-only Explore sub-agents** for breadth (you keep the
  conclusion, not the file dumps).
- **Board** → `get_project_tree` / `get_activity` / `get_entity`.
Survey BEFORE forming any opinion (survey-before-design discipline).

## 3 — Findings (structured, no commitment)
- **What exists** — the current state, accurately.
- **Risks / gaps** — what's fragile, missing, or surprising.
- **Options** — 2–3 directions, each with a one-line trade-off. This is analysis, not a plan —
  don't turn a recommendation into a decision here.

## 4 — Hand-off
Offer the next step: `design` / `rethink design` to shape a solution, or `start project` /
`add epic` to plan one. Record findings as a comment if it's board work.

## Rules
- Read-only: never edit code or mutate the board during analysis.
- Conclusions, not file dumps. Be specific — cite `file:line` / entity keys.
- Cross-refs: `design-interview`, `rethink-design`, `role-resolution`, superpowers `brainstorming`.
