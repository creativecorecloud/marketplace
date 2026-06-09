---
name: merge-protocol
description: Use when integrating completed work — merge your worktree as soon as contract tests pass (no waiting for approval if there are no conflicts), never blind-overwrite develop, and always record the commit SHA on the task.
---

# Merge Protocol (Oriel)

How finished work gets onto `develop` safely and promptly. The board is the source of truth; `develop` is the integration branch. Work in a per-task worktree/branch off `develop`.

## Worktree setup — symlink node_modules, never install
- **Do NOT run `npm install`/`npm ci` in a worktree.** A fresh install per worktree wastes ~75 MB and minutes each. Instead **symlink** the worktree's `ui/node_modules` to the main checkout's:
  `ln -s <main>/ui/node_modules <worktree>/ui/node_modules`
- One shared install serves every worktree; `tsc`, `vite`, and `npm run build` all resolve through the symlink. Keep the real `node_modules` only in the main checkout (the symlink target) and install there if it's ever missing.
- If a branch genuinely changes dependencies (`package.json`), install in the **main** checkout so every worktree picks the change up through its symlink — don't fork a per-worktree install.

## Merge as soon as you're green
- When your contract tests pass (every acceptance criterion green — see `contract-test`) and `develop` merges your branch **with no conflicts**, merge it immediately. **Do not wait for human approval** — green + conflict-free is the gate.
- "Green" means: typecheck + build + the scoped contract tests all pass on the merged result, not just on your branch. Re-run them after merging `develop` in.
- Promotion to `main` is different — that is a versioned release and still goes through review. This rule is for `develop` only.

## Never blind-overwrite develop
- If integrating requires a **hard replace / force-overwrite** of existing code (force-push, `-X theirs`, clobbering files, "take all mine"), STOP.
- Only proceed if you have **double-checked and are 100% sure** nothing is lost or overridden: diff the overwrite against what's on `develop`, confirm every removed/changed line is intentional, and that no parallel work is silently discarded.
- When unsure, do NOT merge — resolve the conflict file-by-file (keep both where both are needed), or escalate with a comment. A clean three-way merge is fine; a blind replace is never fine.
- Rule of thumb: a conflict you can't resolve without deleting someone else's work is a coordination problem, not a merge — pause and flag it.

## Always record the commit on the task
- After merging, `add_comment` on the task/story with the **merge commit SHA** (and the feature commit SHA if different), e.g. "merged to develop @ <sha>". This makes every board item traceable to code.
- If a task spans several commits, list them. The board must always answer "which commit closed this?".

## Order of operations
1. Finish work; all acceptance-criteria contract tests green (`contract-test`).
2. Merge latest `develop` into your branch; re-run typecheck + build + tests.
3. No conflicts + still green → merge to `develop` (no approval needed) and push.
4. `add_comment` the commit SHA on the task; advance status (`in_review`/`done` per the done rules).
5. Conflicts or any hard-replace risk → do NOT auto-merge; resolve carefully or escalate.
