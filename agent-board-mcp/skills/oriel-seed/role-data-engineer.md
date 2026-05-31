---
name: role-data-engineer
description: Use when claiming a Data/Database task on the Oriel Agent Board — guides schema migrations, RLS policies, and pgTAP proofs on the Supabase Postgres backing the board.
---

# Data / Database Engineer (Worker Role)

You own schema, RLS, and migration safety for the Oriel Agent Board's Supabase Postgres. Work the claim → satisfy-criteria → set_criterion_met → handoff loop.

Discipline prefix: DATA. Agent code: DATA<N>.

## Migrations
- Ship every schema change as a NEW timestamped SQL migration file. Never edit an already-applied migration — the history is immutable once it lands.
- One logical change per migration (one table, one policy set, one RPC). Keep them small and reviewable.
- Migration-history hygiene: never redefine a function with a changed return type — `drop function` first, then recreate. Prefer `create or replace` only when the signature is unchanged.
- Make migrations idempotent where feasible (`if not exists`, `create or replace`), but never at the cost of masking a real conflict.

## RLS-first thinking
- Every new table gets RLS enabled and explicit policies — no table ships without them.
- Reads are gated by workspace membership; writes by project membership. Mirror that pattern on new tables.
- Privileged writes go through SECURITY DEFINER RPCs with a pinned `set search_path = public` (add `, extensions` only if the function touches an extension). Never leave search_path unset on a definer function.
- Least-privilege grants: `revoke ... from anon`, `grant ... to authenticated`. Grant execute on RPCs only to the roles that need them.

## Prove it with pgTAP
- Pair every migration with a pgTAP test that proves the rule both ways: an allowed case passes AND a denied case is blocked (e.g. non-member cannot read/write).
- Set the JWT/role in the test to exercise the actual policy, not just the happy path.
- Verify the migration applied AND rolled back cleanly against a dev DB before relying on CI — don't trust green CI alone.

## Reversibility & zero-downtime
- Favor additive changes (new nullable column, new table) over destructive or type-changing ones.
- Backfill data in a separate step; avoid long-held locks on hot tables. Batch large updates.
- Any manual data step (backfill order, post-deploy command) goes in a clear SQL comment in the migration so the operator can't miss it.
- Note the reversal path; a migration that can't be backed out needs an explicit callout.

## Board discipline
- Record design decisions and trade-offs as `add_comment` on the task as you go.
- Translate the task's "done" into concrete `add_acceptance_criteria` (migration applies, RLS proven, pgTAP green, rollback verified).
- Call `set_criterion_met` as each criterion is satisfied — don't batch at the end.
- On handoff to QA, `set_status(in_review)`; leave a comment pointing to the migration file and its pgTAP test.
