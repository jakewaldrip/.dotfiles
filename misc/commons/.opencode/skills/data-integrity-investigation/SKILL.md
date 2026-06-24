---
name: data-integrity-investigation
description: >-
  Investigate data-integrity / "why does this data look wrong" questions in the
  Commons codebase (mismatched IDs, orphaned rows, cross-entity divergence,
  unexpected duplicates, values that don't agree across tables). Use when a
  ticket or user asks WHY a piece of data is in a surprising state and you must
  trace it to a root cause through code + production data. Pairs with the
  commons-sql-query skill for the SQL itself.
---

# Data-Integrity Investigation

A discipline for finding the *true* root cause of a data anomaly without
committing to a wrong one. The failure mode this skill prevents: confidently
declaring a hypothesis "confirmed," then having it collapse when one already-
knowable fact (a feature-flag mode, a runtime config, the actual `patientId` on
the row) finally arrives. Slow is smooth; smooth is fast.

## The method (in order)

### 1. Pin the symptom precisely
Restate the anomaly as concrete, checkable facts ("row X has `patientId = A` but
`patientEnrollmentId` resolves to patient B"). Do not paraphrase the ticket —
quote the exact IDs/columns. Note what you have **not** yet proven (e.g. "I have
not confirmed which `patientId` the offending row actually carries").

### 2. Confirm runtime config BEFORE forming hypotheses
This is the step most often skipped, and the most decisive. Before reasoning
about *how* a value got written, establish the environment it was written in:

- **Feature-flag / switch modes.** What mode does **production** run? (e.g.
  `MemberModelV2Switch` = `OLD_ONLY` / `DUAL_SUPPORT` / `NEW_ONLY`.) The same
  code path behaves differently per mode; the wrong assumption invalidates whole
  hypotheses.
- **Which code is even live.** A create-time write path is irrelevant if the
  flag that gates it is off in prod.
- **Environment / data freshness.** prod vs staging; live Postgres vs a dbt
  snapshot (`base_commons.*`).

If you cannot determine the mode from code/config, **ask the user once** — they
usually know, and it is cheaper than chasing a dead hypothesis for 40 minutes.
Grep for the switch/flag definition and its production value before guessing.

### 3. Enumerate EVERY write path for the suspect column
Dispatch sub-agents (`explore`) in parallel to find, for the column in question,
*every* mechanism that can write it: create paths, update paths, decorators,
backfill jobs, migrations, merge/move/migrator tooling, and any caller-supplied
override. For each, note the precondition under which it runs (tie back to the
runtime config from step 2 — cross out any path the live config disables).

### 4. Form hypotheses with explicit confidence + a disconfirming check
For each surviving hypothesis, write:
- a **confidence** label (e.g. low/medium/high) — and resist "high" before data;
- the **single check that would DISCONFIRM it** (the query whose result kills it);
- what each possible result would mean.

Never call a root cause **"confirmed"** until its disconfirming check has
actually run and survived. Treat "this fits" as a hypothesis, not a verdict.
Phrases like "confirmed beyond doubt" / "highest-probability mechanism" are
banned until the disconfirming evidence is in hand.

### 5. Batch the SQL — minimize human round-trips
The user runs SQL themselves (see `commons-sql-query`). Each round-trip is slow,
so **bundle all of a round's queries into one copy-pasteable block**: the
rule-out queries AND the would-be confirmation query together, numbered, each
with a one-line "what this result tells us." Do not dribble out one query, wait,
then ask for the next. Anticipate the next branch and include its query now.

### 6. Re-derive, don't assume
When data returns, re-read what it actually proves before layering
interpretation. A classic trap: assuming both anomalous rows share the expected
`patientId` when the data never said so. If a result is surprising, suspect your
assumption first.

### 7. Converge and write up
When one hypothesis survives every check and explains *every* observed fact (and
the rivals are each killed by a specific piece of evidence), state the verdict
with the kill-shot for each dead suspect. Cite `file:line` for the mechanism and
the exact production rows/timestamps for the evidence. Note blast radius (is this
one row, or a class of rows / tables?) and flag follow-ups without scope-creeping
the current ticket.

## Output shape for the verdict
- **TL;DR** — one paragraph: the mechanism, in plain terms.
- **Suspects ruled out** — each with the single fact that kills it.
- **Confirmed root cause** — the sequence of events, `file:line` cited.
- **Production evidence** — the rows/timestamps that prove it.
- **Blast radius** — scope (this row vs many tables), with a sizing query.
- **Follow-ups (informational)** — not implemented unless asked.

## Pairs with
- `commons-sql-query` — for writing the actual copy-pasteable SQL (engine choice,
  `base_commons` vs federated, soft-delete filtering, schema discovery). Load it
  alongside this skill.
- `ticket-writer` — if the investigation spawns remediation tickets.

## Anti-patterns (each seen cause a long detour)
- Reasoning about all flag modes without asking which one production runs.
- Declaring a hypothesis "confirmed" before the disconfirming query returns.
- Sending SQL one query per turn instead of a batched block.
- Interpreting a result past what it literally proves.
