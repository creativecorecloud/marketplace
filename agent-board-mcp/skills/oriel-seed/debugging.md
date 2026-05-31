---
name: debugging
description: Use when a test fails, a deploy breaks, or you hit a bug or unexpected behavior on a board task — find root cause systematically before any fix.
---

# Debugging Protocol

Methodical root-cause debugging for board tasks. Guessing wastes turns and corrupts the board with false "done" signals. Investigate first, fix once.

## Iron Law: no fix before root cause
- Read the ACTUAL error and full stack trace first — not a paraphrase, the real output.
- Reproduce reliably: find the smallest command/input that triggers it every time. No repro, no fix.
- Check what changed: `git diff`, recent commits, and environment differences (env vars, versions, data, auth tokens) between working and broken states.
- If you cannot state the cause in one sentence, you are not ready to edit code.

## Isolate the failing layer (multi-component)
- Board work spans Worker > MCP > RPC > DB. Don't assume which layer breaks.
- Add diagnostic instrumentation (logs/asserts) at each boundary and observe where the data first goes wrong.
- Confirm WHICH layer fails before touching any of them.

## One hypothesis at a time
- State it explicitly: "I think X because Y."
- Test with the SMALLEST possible change — one variable.
- Verify the result. If wrong, REVERT and form a NEW hypothesis.
- Never stack fixes; piling changes hides the real cause and creates new bugs.

## Evidence before claims
- Capture the failing case first (output, status, screenshot).
- Prove the fix flips it: same repro now passes, with observed output.
- NEVER call `set_criterion_met` or say "fixed" without that observed before/after evidence.

## Board hygiene while debugging
- When stuck, `set_status(blocked)` + `add_comment("BLOCKED: <symptom> — ruled out: <what you've eliminated>")` so others don't duplicate the dig.
- Found a separate defect? `create_entity` a new task with a clean repro, then `add_dependency` linking it.
- Use `get_entity` to re-read acceptance criteria before assuming what "correct" means.

## After 3 failed fixes: stop
- Three failed attempts means it's a design problem, not another fix.
- Question the architecture; surface it to the planner via `add_comment` rather than attempt #4.

## Persist the knowledge
- Once root cause is confirmed, record it as a DECISION comment (`add_comment("DECISION: root cause was <X>; fixed by <Y>")`) so the next agent inherits the finding.
