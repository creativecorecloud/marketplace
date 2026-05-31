---
name: contract-test
description: Use when implementing or fixing any task on the board — write boundary contract tests first (TDD), map each acceptance criterion to a test, and never mark a criterion met without a green test.
---

# Contract Test (Oriel)

Behavior-first verification at the boundary an entity promises.

## Before claiming
- **Trace existing code first** — prove the work doesn't already exist (cite file:line or prove absence). If it exists, don't rebuild; cancel or narrow the task.

## While working a task
1. For each **acceptance criterion**, write a contract test describing the promised behavior (not the implementation). Run it — watch it fail.
2. Implement the minimal code to make it pass. Re-run.
3. Only then `set_criterion_met(criterion_id, true)`. **Never** mark a criterion met without its test green.
4. Compile-gate before handoff: typecheck + build + the scoped tests all pass.

## For bug tasks
Reproduce first → isolate the root cause by systematic debugging (form a hypothesis, bisect, confirm) — no guess-patching → add a **regression** contract test that fails on the bug → fix → green.

## Hand-off
`add_comment` the test evidence (what's covered). `set_status(in_review)` when all criteria are met + green.

## Never close without green tests
- A task or story may only reach `done` when **all its code has contract tests and they pass** — every acceptance criterion mapped to a green test. No exceptions, no "tested manually."
- If something genuinely cannot be auto-tested, say so explicitly in a comment and disable that criterion (don't silently skip it) before closing.
- Closing/merging is gated on green — see `merge-protocol` for the integration steps.

## Record the result on the board
- After you run an entity's contract tests, call **`set_contract_test(entity_id, "passed"|"failed")`** so the board shows a ✓/✗ tests badge (others see it at a glance). Use `not_run` to clear it. It's merge-safe — it won't touch the entity's `size` or other metadata.
- Set it to `passed` only when the tests actually passed (don't pre-claim — same honesty rule as acceptance criteria).
