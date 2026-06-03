---
argument-hint: [task name, or path to plans/<task>/cached-objectives.md; optional max iterations (default 5)]
description: Execute a bounded iterate-to-convergence loop against a cached-objectives doc — pick a tractable step, run two high-confidence controlled experiments, check off completed objectives, update the cache. Halts early on convergence or stall.
---

Apply the **anterospect** skill. Run the execution loop against the cached-objectives doc that [`introspect`](../../introspect/claude/introspect.md) produced, advancing objectives until the stage is done, the loop converges, or it stalls.

$ARGUMENTS

## Role

`anterospect` is the **executor** half of the loop pair. `introspect` scopes a stage and writes `plans/<task>/cached-objectives.md`; `anterospect` reads it, does the work in bounded iterations, and updates it. It does **not** re-scope stages (that's `introspect` at the next boundary).

> Claude Code skill. The loop below assumes an environment that can run experiments (code execution, file edits) and, rarely, invoke `clarify`. It cannot be exercised in a plain chat session.

## Preconditions

- A `plans/<task>/cached-objectives.md` must exist (run `/introspect` first if not). If it's missing, stop and say so.
- Max iterations defaults to **5**; honor an override if given. This is a **cap, not a quota** — halt earlier per the termination rules.

## The loop (each iteration)

### A. Read + compact the cache
Read `cached-objectives.md`. Restate, compactly, the stage's **done-when** condition, the **open objectives** (`- [ ]` only), the **verified claims** (don't re-litigate these), and the **open risks**. This compaction is the working context for the iteration — keep it tight.

### B. Scope one tractable step + 3 reasons
Pick the **single most tractable, highest-information** next step toward an open objective. State **three supporting reasons** it's the right step now (why this, why now, why it advances the done-criterion). If you can't give three honest reasons, it's probably the wrong step — pick another.

### C. Review the plan for inconsistencies
Before acting, check the step against the cache: does it contradict a verified claim? Re-do work already done? Depend on an unverified/refuted claim? Violate an open risk? Resolve inconsistencies before running anything.

### D. Run two controlled experiments
Run the **two highest-confidence controlled experiments** for advancing the chosen objective — controlled meaning each isolates one variable so the result is interpretable. Record what each tested, the result, and whether it advanced the objective. Two is deliberate: enough for a cross-check, few enough to stay tractable.

### E. Mid-loop verification (rare — hybrid trigger)
**Only** if an experiment produced an empirical claim that will *directly determine the next step's direction* (a load-bearing, decision-driving claim checkable against published literature — not a mechanical result, not a claim about this local codebase), route it to [`clarify`](../../clarify/claude/clarify.md). This is the external signal that breaks self-reinforcing confidence (guards against Degeneration-of-Thought) at the moment it matters.

Do **not** fire `clarify` on every claim — that's wasteful and off-task. Most iterations will not trigger it. If `clarify` returns **REFUTES/NEI** on a decision-driving claim, do not build the next step on it: record the verdict in the cache and adjust course.

### F. Update the cache
- Tick completed objectives `- [ ]` → `- [x]` (exact syntax; only when genuinely done per the done-criterion).
- Add any new verified claims (with `clarify` verdict or "experiment-verified").
- Update **open risks** with anything the iteration surfaced (a shortcut taken, a result that was weaker than hoped).
- If new necessary work appeared, add it as an objective rather than doing it silently.
- Write the cache back. Each iteration leaves a durable, honest record.

## Termination (hard stop — checked after every iteration)

Halt and stop looping when **any** holds — do not run out the remaining iterations for its own sake:

1. **Done** — every objective is `- [x]` and the stage done-criterion is met. (Suggest `/introspect` for the next stage.)
2. **Converged** — the last iteration produced no material progress *and* no new tractable step exists (you'd be repeating yourself). Repetition is a stop signal, not thoroughness.
3. **Stalled / Degeneration-of-Thought** — two consecutive iterations made no real progress, or you're increasingly confident while objectives aren't actually advancing. This is the failure mode the cap exists to bound: **stop and report**, don't grind. Recommend an external check (`/ensemble` or `/clarify`) or human input.
4. **Cap reached** — `max` iterations done. Report status honestly; do not pretend convergence.

On any halt, write a final cache state and a one-paragraph status: which objectives are done, what's left, why you stopped, and the single recommended next action.

## Why bounded + convergence-gated (not just "loop 5")

Naive self-iteration degrades: once a model is confident, self-reflection often can't produce novel correction even when wrong (Degeneration-of-Thought). So iteration count is a *ceiling*, the real controls are the **stall/convergence stop** and the **external `clarify` signal** at decision points. Running all 5 iterations regardless would manufacture motion, not progress.

## Output

Per iteration: a short record (step + 3 reasons, two experiment results, any `clarify` verdict, objectives ticked). At halt: the final status paragraph and cache path. Keep iteration logs terse — the cache is the durable artifact, not the chat transcript.

## Scope

`anterospect` executes and records; it does not scope new stages (`introspect`) or judge output quality (`tap`/`publication-figure-qc`). Its discipline is: tractable step, justified, controlled experiments, honest cache updates, and an early stop when progress stops.

Lineage and rationale: [references/sources.md](references/anterospect/sources.md).
