---
name: oriel-loop
description: Use to start, run, or stop the Oriel self-driving loop on the Agent Board — the per-tick cadence that re-arms a wakeup, advances your own work, and drains the notebook AI queue until told to stop. Invoked by `/oriel start loop`, `/oriel tick`, `/oriel stop loop`.
---

# Oriel self-driving loop

Drive the board to completion **unattended**. One cheap call (`check_in`) gates every tick, so a
quiet board stays near-free. Re-arming a `ScheduleWakeup` each tick is what makes it self-driving.

## start loop
1. Run **one tick now** (see *Tick* below).
2. **Re-arm:** schedule the next wake-up (`ScheduleWakeup`) with *this skill* as the prompt, so the
   loop continues without the user. Idle cadence ~20–30 min; sooner (60–270 s) only while you're
   actively polling external state (a deploy / CI / a job you just queued).
3. Tell the user the loop is running and when the next tick fires.

## Tick (one cycle)
1. `check_in(since=cursor)` FIRST. If `should_check=false` **and** `ai_jobs_queued=0` → quiet tick:
   only advance any unfinished work YOU own, then re-arm + end. Don't react for the sake of it.
2. `unread_messages>0` → `get_notifications()` and act on each.
3. `my_work_waiting` → `get_my_work()` → advance each item: satisfy the next acceptance criterion
   (`set_criterion_met`), `add_comment` for decisions/hand-offs, `set_status(in_review|done)` when
   all criteria are met, or `set_status(blocked)` + a comment when stuck.
4. `ready_tasks>0` → `list_ready_tasks` → `claim_task` one with no unmet blockers (one claim in flight).
5. `ai_jobs_queued>0` → **drain the notebook AI queue**: `claim_ai_job(workspace_id)` → run the
   prompt on YOUR OWN model → `complete_ai_job(job_id, result)` (or `error` on any failure).
   Oldest-first, one claim at a time, until `claim_ai_job` returns `{job:null}`.
6. Re-arm the wake-up (unless stopping).

## stop loop
Do **not** re-arm the `ScheduleWakeup`; let the schedule lapse. Report that the loop is stopped.
Start it again any time with `/oriel start loop`.

## Rules
- **A quiet tick ≠ done.** If you own unfinished work (an assigned task, an undelivered epic, an
  unmerged branch), advance it this tick before re-arming.
- **Never leave a claim dangling** — every `claim_task` / `claim_ai_job` must be terminated
  (`set_status` / `complete_ai_job`).
- **Stop conditions:** doer → task handed back to its TL; TL → epic delivered (criteria met-or-
  disabled, merged green, stories+epic closed) AND PD approved; PD → all owned epics closed.
- **Blocked on a USER decision/approval?** Post the blocker, escalate to the user, and STILL
  re-arm — never die silently.
