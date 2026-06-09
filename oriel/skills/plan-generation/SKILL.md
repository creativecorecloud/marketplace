---
name: plan-generation
description: Use when a WORKSPACE's Plan (timeline) has gone stale (or has never been generated) and an agent must (re)derive its soft structure — bucket grouping + a suggested project layout — from the workspace's projects, epics, sizes, and cross-project dependencies, then store it with set_workspace_plan. The workspace-level analogue of the per-project mermaid flowchart skill.
---

# Plan generation (Oriel workspace timeline)

A workspace **Plan** lays the workspace's **projects** out on a horizontal relative-time axis so a
user can see at a glance what is happening **now / next / later**, what runs in parallel, and what
must follow what. It is the workspace-level analogue of a project's **mermaid flowchart**: one level
up, over *projects* instead of *epics*. Regeneration is **on demand** — the plan is marked `stale`
when the underlying work changes; an agent then re-derives the **soft** structure and saves it.

This skill is for that regeneration step. It is not role-specific; whoever picks up the regen task
(usually the workspace's PD) runs it.

## What the plan IS (and what you do NOT compute)

The stored plan blob holds only the **soft, opinion** layer + user nudges:

```jsonc
plan = {
  version: <int>,                                   // bump on each regen
  buckets:   [ { id, name, order } ],               // user-named rows you GROUP projects into
  items:     [ { project_id, bucket_id,
                 start_offset,  // integer relative-time lane from "now"
                 span } ],      // integer lanes; default from t-shirt size, user-resizable
  relations: [ { from_project_id, to_project_id, type: "FS" | "SS" } ]
}
```

The server does the **deterministic** layer for you — never recompute it by hand:
- **Auto-seed** — any workspace project you omit from `items` is still shown, seeded with the
  default bucket + a size-derived span. You only need to place projects you want to *move/regroup*.
- **Size rollup** — each project's t-shirt size (and its default span) is rolled up from its
  entities' `metadata.size` and returned by `get_workspace_plan` in a `sizes` map. **Read it; don't
  invent spans.** Buckets→span scale: S→2, M→5, L→10, XL→18.
- **FS seed** — every cross-project `entity_dependency` in the workspace is already surfaced as an
  **FS** (Finish→Start) relation. You only ever **add SS** (Start→Start / "run in parallel"), or an
  FS the deps don't capture. No link = independent.

So your job is the *judgement*: **which projects group together**, **roughly when each starts**, and
**which extra parallelism (SS) to assert** — not arithmetic the resolver already does.

## The loop — read the overview, derive, store, verify

1. **Read the resolved plan + stale reason.**
   `get_workspace_plan(workspace_id)` → the resolved blob: `buckets`, `items` (incl. auto-seeded,
   flagged `seeded:true`), `relations` (incl. seeded FS, `seeded:true`), the `sizes` map, and
   `stale` / `stale_reason` (e.g. *"epic added"*, *"task size changed"*). The reason tells you what
   moved since the last generation.

2. **Pull the workspace overview** so your grouping reflects reality:
   - `list_projects` → the workspace's projects, each with its `flowchart` (epic-level shape),
     `status`, and code. Keep the projects in *this* workspace.
   - For shape/sequencing, skim each project's epics (`list_entities(project_id, type:'epic')`) and
     the cross-project dependencies already reflected as FS in the resolved `relations`.
   - Use the `sizes` map for magnitude — bigger projects deserve later/longer placement, not a guess.

3. **Derive the soft structure** (the actual thinking):
   - **Buckets** = a few meaningful rows. Good defaults: by **phase** (`Now`, `Next`, `Later`), by
     **track/theme** (e.g. *Platform*, *Product*, *Infra*), or by **team**. 2–5 buckets; keep names
     short. Give each a stable `id` and an `order`.
   - **Placement** (`start_offset`): order projects so an **FS** target starts at/after its
     predecessor finishes (`pred.start_offset + pred.span`). Respect the seeded FS edges — they come
     from real board dependencies. Leave `span` to the size rollup unless the user resized it
     (a stored item's `span` wins over the seed).
   - **SS relations**: add `type:"SS"` between projects that should **start together** / run in
     parallel. This is the one relation the board can't infer — add it where the program intends
     concurrency. Keep the relation graph a DAG; don't duplicate a pair the FS seed already covers
     (a stored relation on the same `from`/`to` pair shadows the seeded FS).
   - **Preserve user intent**: if `items` already carry user `start_offset`/`span`/`bucket_id`
     (not `seeded`), keep them unless the stale reason makes them wrong.

4. **Store it.** `set_workspace_plan(workspace_id, plan)` with the full object
   `{version, buckets, items, relations}`. The server stamps `updated_at`, archives the prior plan
   into a capped (5) history, and **clears `stale` / `stale_reason`**. (Pass `null` or `{}` to clear
   the plan entirely; history is kept.) You do **not** set `stale`, `updated_at`, or `versions` —
   the server owns them.

5. **Verify.** Re-read with `get_workspace_plan` and confirm: every non-archived project appears in
   `items` (yours + still-seeded), `stale` is gone, FS edges still resolve, and your SS links are
   present. Ask the user to open the workspace **Plan** page and confirm the now/next/later story
   reads right. Record the outcome on the relevant story:
   `add_comment("DECISION: workspace plan regenerated — <one line>")`. Iterate by calling
   `set_workspace_plan` again until approved.

## Rules of thumb
- **Group by meaning, sequence by dependency, size by rollup.** Buckets carry *no* scheduling
  meaning — they are organizational rows; timing lives entirely in `start_offset` + `span`.
- **Don't fight the resolver.** Omit projects you don't need to move (they auto-seed); read spans
  from `sizes`; let seeded FS stand. Add only the judgement the board can't derive (grouping,
  start offsets, SS).
- **Keep it a DAG and keep it small** — a handful of buckets, clear FS/SS links. If it's unreadable,
  the grouping is wrong, not the data.
- **Regenerate on stale, not on every change.** The trigger marks `stale` with a reason; that is the
  signal to run this loop. A plan that isn't stale doesn't need regenerating.
