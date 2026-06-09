---
name: skill-normalize-runbook
description: Use when you are an Oriel worker agent assigned to normalize adopted third-party skills into the Claude SKILL.md standard by draining the normalize queue via the agent-board MCP tools.
---

# Skill Normalize Runbook

You are a worker agent draining the skill-normalize queue. Oriel uses its own agents' intelligence to normalize skills — there is NO direct LLM/API-key call in the backend; your model IS the normalizer. Work through the queue to completion, then stop.

## Why this exists

Third-party skills arrive in raw form after `adopt_skills`. They must be rewritten into the Claude SKILL.md standard before they are visible in the library. This queue is the pipeline that makes that happen.

## Before you start

Optionally call `list_normalize_jobs` to inspect what is pending. This is read-only; it does not claim anything. Use it to gauge queue depth or preview inputs before committing.

## Drain loop

Repeat the steps below until the queue is empty.

### Step 1 — Claim one job

Call `claim_normalize_job`. It atomically dequeues and locks one job for you. The return contains:
- `job_id` — use this in every subsequent call for this job.
- `slug` — the skill's canonical identifier.
- `title` — human-readable name of the skill.
- `raw_body` — the un-normalized source text to rewrite.

If it returns nothing (empty / null / no job), the queue is empty. Stop.

### Step 2 — Rewrite to SKILL.md standard

Produce a new body that meets the quality bar below. Preserve the original intent; do NOT invent capabilities the source didn't describe.

**SKILL.md quality bar:**

- Open with a `---`-delimited YAML frontmatter block containing at minimum:
  - `name:` — the skill's slug (from the job).
  - `description:` — a single sentence starting with "Use when…" that tells an agent exactly when to invoke this skill. Be concrete; vague descriptions cause wrong invocations.
- After the closing `---`, write a concise markdown body:
  - Action-oriented: lead with what the agent does, not background.
  - No invented features — if the source didn't describe it, omit it.
  - Tight: cut filler. A 10-line body beats a 40-line body that says the same thing.

**Good description pattern:**

> `Use when you need to <concrete action> for <context> — covers <scope>.`

**Bad patterns to avoid:** "This skill helps with…", "Can be used to…", describing the agent itself rather than the invocation trigger.

### Step 3 — Complete the job

On success, call `complete_normalize_job(job_id, body)` with the rewritten body.

On failure — raw input is junk, unintelligible, or cannot be normalized without fabrication — call `complete_normalize_job(job_id, error="<short reason>")`. The job is then marked as errored and skipped; this is the correct outcome. Never guess or hallucinate content to make a bad input pass.

### Step 4 — Loop

Go back to Step 1 and claim the next job.

## Error handling

- **Claim returned nothing mid-loop** — another agent drained the last job between your iterations. Queue is empty; stop cleanly.
- **Raw body is empty or binary garbage** — complete with `error="empty or non-text input"`.
- **Raw body describes something harmful or policy-violating** — complete with `error="content policy violation"`.
- **Source intent is ambiguous beyond reasonable inference** — complete with `error="insufficient source to normalize without fabrication"`.
- **Never emit a fabricated skill body** — a library with invented capabilities poisons every agent that loads it. An error record is always better than a plausible lie.

## Standing down

After `claim_normalize_job` returns empty, post an `add_comment` on your assigned task noting how many jobs you completed and how many errored, then set the task `done`.
