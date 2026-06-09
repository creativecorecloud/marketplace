---
name: design-interview
description: Use when shaping a new feature/story on the board before any code — runs a structured, one-question-at-a-time design interview, records decisions as the story's acceptance criteria.
---

# Design Interview (Oriel)

Turn a vague request into a locked design BEFORE work is claimed.

## When
A story is fuzzy, multiple approaches exist, or requirements are unstated. Do this first; never let a worker claim an undesigned story.

## Loop
1. Open (or use) the story; set status `backlog`. `add_comment` a one-line problem statement.
2. **Interview the requester one decision at a time**, following the **questioning-protocol**
   skill — the source of truth for HOW to ask (issue ≤2 lines → top-3 ranked A/B/C →
   recommendation, one per message, never batch). Record each locked decision as an
   `add_comment` ("DECISION: …").
3. When the shape is clear, write the "done" definition as **acceptance criteria** (`add_acceptance_criteria`) — each criterion testable.
4. For a project-level shape (how the epics connect), give the user a **high-level visual to
   verify**: adopt the **mermaid** skill, author a flow chart, store it with
   `set_project_flowchart`, and have the user confirm it via the project's **Flow** button.
5. Resolve every open question (no TBDs). Then `set_status(ready)` so a worker can `claim_task` a child task.

## Rules
- For the design/plan thinking behind the questions, lean on the **superpowers** skills
  (`brainstorming` to open the option space, `writing-plans` to shape the approach); this
  oriel loop owns the user interview + recording the decisions on the board.
- Asking format is owned by **questioning-protocol** (one decision per message; survey existing entities/skills before proposing new structure).
- Decisions live as comments; "done" lives as acceptance criteria; the story body holds the synthesized design.
- Don't start building inside the interview — design first, then decompose into tasks.
