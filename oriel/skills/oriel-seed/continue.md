---
name: continue
description: Use for `/oriel continue` — recap where you left off (like where-were-we) and then ACT: claim/advance the next unblocked leaf or re-arm the self-driving loop, reporting what you picked up and why. Honors PD-solo (advance in-chat, no new rooms).
---

# Continue — recap, then advance

`$ARGUMENTS` optionally names the project. Runs the `where-were-we` recap, then **does the next
thing**.

## 1 — Recap
Run `where-were-we` (read-only): last activity, in-flight, next unblocked, open questions.

## 2 — Advance one step
- You own an in-flight item → advance it: satisfy the next acceptance criterion
  (`set_criterion_met`), `add_comment` for decisions, `set_status(in_review|done)` when all met,
  or `set_status(blocked)` + comment if stuck.
- Otherwise a ready leaf exists → `claim_task` ONE with no unmet blockers and start it.
- Self-driving was on → re-arm the `ScheduleWakeup` (`oriel-loop`).
- Blocked only on a user decision → post the blocker, escalate, and stop (don't spin).

## 3 — Report
Say exactly what you picked up (entity key) and why, and what's next.

## Rules
- **Avoid unnecessary rooms** — PD-solo advances the work in THIS chat; only spawn a headless
  doer if parallel work genuinely helps.
- One claim in flight; never leave a claim dangling.
- Cross-refs: `where-were-we`, `oriel-loop`, `agent-loop`, `role-team-leader`.
