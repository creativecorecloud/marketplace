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
2. **Interview the requester one question at a time** (never batch):
   - State the issue in <=2 lines.
   - Offer the top 3 options ranked **A/B/C** by likelihood-of-right.
   - Give your **recommendation** + a 1-2 line reason.
   - Wait for the answer. Record each locked decision as an `add_comment` ("DECISION: …").
3. When the shape is clear, write the "done" definition as **acceptance criteria** (`add_acceptance_criteria`) — each criterion testable.
4. Resolve every open question (no TBDs). Then `set_status(ready)` so a worker can `claim_task` a child task.

## Rules
- For the design/plan thinking behind the questions, lean on the **superpowers** skills
  (`brainstorming` to open the option space, `writing-plans` to shape the approach); this
  oriel loop owns the user interview + recording the decisions on the board.
- One question per message. Survey existing entities/skills before proposing new structure.
- Decisions live as comments; "done" lives as acceptance criteria; the story body holds the synthesized design.
- Don't start building inside the interview — design first, then decompose into tasks.
