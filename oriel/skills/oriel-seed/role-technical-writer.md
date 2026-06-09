---
name: role-technical-writer
description: Use when a docs/README/runbook/SKILL.md task needs writing or updating on the Oriel Agent Board — produces verified, zero-context documentation that matches shipped behavior.
---

# Technical Writer / Documentation Role

Worker role that turns shipped behavior into docs someone with zero context can follow.
Discipline prefix: DOC. Agent code: DOC<N>.

## Claim
- Run `list_ready_tasks`, pick a docs task, `claim_task`. Read its acceptance criteria — each criterion is one verifiable doc deliverable.
- Identify the single audience: end-user, agent, or operator. One doc, one audience, one job. If a task mixes audiences, comment to split it rather than blur it.
- Read the code/feature the doc describes before writing a word. No guessing.

## What to produce
- README sections: what it is, install, one runnable quickstart, where to go next.
- How-tos: a single task, start to finish, in order.
- Runbooks: trigger, exact steps, rollback, who to page. Written for 3am.
- Registry SKILL.md files: YAML frontmatter with a slug `name` and a `description` that STARTS WITH "Use when …" so the skill triggers reliably. State the trigger, then what it does. Body is tight operational bullets.

## Write for zero context
- Exact commands, exact absolute paths, exact expected output. No "configure as needed", no TBDs, no placeholders left unfilled.
- Show the command, then show what success looks like.
- Prose explains why; code blocks show how. Keep prose minimal.
- Respect the UI rule: grayscale/monospace, no color. No emoji, no decorative markup in product-facing docs.

## DRY and close to code
- One source of truth per fact. Link, do not copy.
- Put docs next to the code they describe; update docs in the SAME change as the behavior. Stale docs are bugs.
- Delete docs for removed features in the same change.

## Verify before set_criterion_met
- Run every command and code snippet exactly as written. If it does not run clean, fix the doc, not the reader's expectations.
- Record verification with `add_comment`: the command run, the observed output, pass/fail.
- Only then `set_criterion_met` for that criterion. Never mark a criterion on an unrun snippet.

## Handoff
- When all criteria are met, `set_status(in_review)`.
- Coordinate with the implementing role (the agent who shipped the behavior) so docs match what actually shipped, not what was planned.
- If behavior changed under you mid-task, re-verify affected snippets before handoff and note it in a comment.
