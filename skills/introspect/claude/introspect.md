---
argument-hint: [the current/just-finished stage, or what stage you're scoping toward]
description: Scope the tests and context needed before the next stage, and write a structured cached-objectives doc that anterospect's loop then executes against.
---

Apply the **introspect** skill. Define what must be true to finish the next stage, and write (or update) the shared `cached-objectives.md` that drives the execution loop.

$ARGUMENTS

## Role

`introspect` is the **scoper / stage-gate** half of the loop pair. It does not do the work — it decides *what the next stage requires* and records it as a durable, machine-parseable cache. [`anterospect`](../../anterospect/claude/anterospect.md) is the **executor** that reads this cache, runs experiments, and checks items off. The contract between the two skills **is** the cached-objectives doc, so its format is fixed (below) — both skills depend on it.

> This skill targets Claude Code (it writes plan files and, at stage boundaries, may invoke `clarify`). It extends the `task-plan` convention rather than replacing it: `task-plan` is for general serial plans; `introspect`/`anterospect` add iterate-to-convergence execution on top of a cache.

## Step 1 — Establish where we are

Ground the current state in artifacts, not memory:

- If a `plans/<task>/cached-objectives.md` already exists, read it — you are advancing it to the next stage, not starting fresh.
- Read the relevant `plans/<task>/plan.md` (if present), recent commits, and the lab notebook (`docs/lab-notebook.md`) if `note` is in use — these tell you what actually got done.
- Identify the **stage just completed** and the **next stage** to scope. If ambiguous, state your reading of the stage boundary explicitly.

## Step 2 — Stage-boundary verification (hybrid wiring)

At a stage boundary, the load-bearing **empirical claims** the finished stage produced — the ones the next stage will build on — get verified before they enter the new cache. For each such claim that is checkable against published evidence (a mechanism, a generalization claim, a "X outperforms Y" result — not a mechanical "the script runs"):

- Route it to [`clarify`](../../clarify/claude/clarify.md). Record the verdict (SUPPORTS / REFUTES / NEI + strength) in the cache.
- A **REFUTES or NEI/Contested** claim must **not** silently become a foundation for the next stage — flag it, and either down-scope the stage to not depend on it or add "re-establish this claim" as an explicit objective.

Verify only the **decision-driving** claims, not every result (ART selective-verification: checking everything is wasteful). If a claim has no external literature to check (it's about *this* codebase/dataset), it's verified by experiment in the loop, not by `clarify`.

## Step 3 — Scope the next stage

Decide what must be true to *finish* the next stage. Be concrete and falsifiable:

- **Necessary tests / experiments** — what has to be run or shown for the stage to count as done. Prefer tests that are tractable and high-information.
- **Necessary context** — the minimal overview a fresh executor needs to act without re-deriving everything (key files, datasets, decisions already made, constraints).
- **Done criteria** — the observable condition that ends the stage.

Keep the stage **small enough to be tractable**. If the "next stage" is really three stages, scope only the first and note the rest as future stages.

## Step 4 — Write `cached-objectives.md`

Write (or update) `plans/<task>/cached-objectives.md` in **exactly** this format — `anterospect` parses it:

```markdown
# Cached Objectives — <task>

**Stage:** <n> — <stage title>
**Updated:** <YYYY-MM-DD HH:MM>
**Done when:** <observable condition that ends this stage>

## Context overview
<the minimal context a fresh executor needs: key files, datasets, decisions made, constraints. Bullet form. This is what gets "compacted" and re-read each loop iteration.>

## Objectives (this stage)
- [ ] OBJ1: <concrete, falsifiable objective>
- [ ] OBJ2: <…>
- [ ] OBJ3: <…>

## Verified claims (carried from prior stage)
- <claim> — clarify: <SUPPORTS/REFUTES/NEI · tier> (or "experiment-verified" / "unverified — to establish")

## Open risks
- <known risk, assumption not yet validated, or rejected approach to avoid repeating>

## Next stages (not yet scoped)
- <one-line placeholders for what comes after this stage>
```

Rules:
- **Objectives are checkboxes** (`- [ ]`) — `anterospect` ticks them to `- [x]` as it completes them, so the syntax must be exact.
- Each objective is **independently checkable** — avoid "improve the method" (untestable); prefer "show method achieves X on dataset Y" (testable).
- **Carry verified claims forward** with their `clarify` verdict, so the loop never re-litigates settled facts and never builds on refuted ones.
- **Open risks is mandatory and substantive** — a stage doc with no acknowledged risk is usually dishonest. Name the assumption most likely to be wrong.
- Don't invent state. Context and prior results trace to Step 1.

## Output

Show the path written and the stage title + done-criterion. One line of confirmation, then stop — the executor (`anterospect`) takes it from here.

## Scope

`introspect` scopes and records; it does not run the experiments (that's `anterospect`) or judge writing quality (that's `tap`). It is the gate between stages: verify what the last stage claimed, define what the next stage needs.

Lineage and rationale: [references/sources.md](references/introspect/sources.md).
