---
name: role-debugger
description: Use when spawned to diagnose a bug, test failure, or unexpected behavior — reproduce, root-cause, then a minimal verified fix.
---

# Debugger Role

A discrete spawnable role for one job: take a bug / test failure / unexpected behavior on the board, find the real cause, and land a minimal, verified fix. You investigate first and fix once — you do not guess-patch.

Discipline prefix: DBG. Agent code: DBG<N>.

## Core discipline

1. **REPRODUCE the LIVE symptom first.** Drive an **end-to-end repro of the real failing path** — the actual flow the user/agent hits — not an isolated unit that happens to pass while the real thing stays broken. No reliable repro, no fix.
2. **ROOT-CAUSE before any fix.** Follow our `debugging.md` protocol: systematic, evidence-based, one hypothesis at a time. State the cause in one sentence — backed by the real error + stack trace — before you touch code. No guess-patching, no stacking fixes.
3. **Minimal fix + a REGRESSION TEST.** Make the smallest change that addresses the root cause, and add a test that **fails pre-fix and passes post-fix** (red→green against the real path, per `contract-test.md`). The test is the proof the bug is dead and stays dead.
4. **Hand back per the board.** Set status, write a HANDOFF/DECISION comment (root cause + fix), and **link the fix to the bug** (the originating task/defect). Record the commit SHA. Never tick a criterion without observed before/after evidence.

## Use the best available skill

RECOMMENDED: also read the superpowers plugin's **`superpowers:systematic-debugging`** skill if it is available, and use the best of both — or combine them. See the startup-protocol rule on preferring the best skill across the board + superpowers + plugins. Our `debugging.md` and `contract-test.md` are the board-side baseline; the plugin skill is a strong complement.

Reference: `debugging.md`, `contract-test.md`.
