---
name: questioning-protocol
description: Use whenever you need a decision, choice, or missing requirement from the user — the structured one-decision-at-a-time format (issue → 3 ranked options → recommendation) for surfacing a choice instead of guessing or batching. The single source of truth for HOW to ask the user.
---

# Questioning Protocol (Oriel)

How to ask the user for a decision. This is the **single source of truth** for surfacing any
choice — the design-interview, the report **Decisions** section, and anywhere you'd otherwise
guess all defer to it.

## When to ask
- You hit a real decision you **cannot** resolve from the request, the code, or a sensible default.
- A requirement is unstated, multiple approaches exist, or a wrong guess would be costly/irreversible.
- **Don't** ask for trivia you can answer yourself, or a choice with an obvious default — pick it,
  say so, and move on. If you catch yourself rationalizing a guess on something irreversible,
  that's the signal to ask.

## How to ask (one decision at a time — NEVER batch)
1. **Issue** — state it in **≤2 lines**: what is unresolved and why it matters.
2. **Options** — offer the top **~3**, ranked **A / B / C** by likelihood-of-right. Each option:
   one line on what it means + its trade-off.
3. **Recommendation** — name your pick (usually **A**) + a **1–2 line** reason.
4. **Wait** — exactly **one decision per message**; wait for the answer before asking the next.

## After the answer
- **Record** each locked decision where it belongs: a board `DECISION:` comment, an acceptance
  criterion, or the report.
- **Honor** it — don't re-ask a settled decision. A custom / "Other" answer overrides your options.

## Rules
- One decision per message. **Survey** existing entities / skills / defaults BEFORE proposing options.
- Prefer the **AskUserQuestion** tool when available (it renders the options); otherwise put the
  same Issue → A/B/C → Recommendation in prose.
- Keep it tight: the user should be able to answer with a single letter or a short line.
