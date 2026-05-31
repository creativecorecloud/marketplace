---
name: demo-e2e-walk
description: Use when a task/story is in_review and needs eyes-on or end-to-end verification — prep the data + preview, give 1-3 observe-and-report steps, then close on PASS or reopen on FAIL.
---

# Demo / E2E Walk (Oriel)

Verify a finished slice the way a reviewer would, with minimal reviewer effort.

## When
A task/story is `in_review` and benefits from a behavioral or visual check beyond unit tests (a user-visible flow, a migrated list, a layout call).

## Prep (do this BEFORE asking anyone to look)
- Seed any required fixture data yourself — never ask the reviewer to set up data.
- Make the thing reachable (running preview / deployed URL) and capture the starting state.

## Walk
Provide a tight, scannable block:
- **Title** + 2-line context (what was built / why it needs eyes).
- **Steps (1-3, observe + report):** each `action -> expected outcome`.
- **Report:** `PASS` / `FAIL <what you saw>` / `HUMAN <real-state needed>`.

## Close
- **PASS** -> `set_status(done)`; if all sibling tasks done, the story can close.
- **FAIL** -> `set_status(in_progress)` (or reopen) + `add_comment` the exact failure; that comment is the next worker's brief.
- **HUMAN** -> wait for the minimal manual step, then resume.

One walk at a time. Don't bundle. More than ~6 steps means the slice is too big — re-scope.
