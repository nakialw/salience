---
name: parallel-implementation
description: Create wave-based implementation plans with disjoint write scopes, dependency links, and explicit integration steps. Use when the user wants a parallel implementation plan, worker split, safe multi-agent decomposition, or phased execution with parallel work.
---

# Parallel Implementation

## Overview

Use this skill to turn a large task into a wave-based execution plan that supports parallel work without overlapping write scopes. The goal is safe decomposition with a clear critical path, explicit ownership, and an integration wave that brings the pieces back together.

The highest-value upgrade over a plain task list is the checkpoint gate between waves. Do not just split work; make it easy to stop, review, cut scope, and only then continue.

If the user only wants a normal serial plan, use the `task-plans` skill instead.

## Core Rules

- One wave can be active at a time.
- Multiple work items inside the active wave can be in progress together.
- Same-wave write scopes must be disjoint.
- Every wave transition needs an explicit checkpoint.
- Every work item must define: owner, review owner, write scope, dependencies, verification.
- Reserve explicit waves for integration and final verification.
- Keep urgent critical-path work local when the next step depends on it immediately.

Read `references/wave-planning.md` when the split is ambiguous.

## Workflow

### 1. Map the task before splitting it

Identify: the critical path, independent sidecars, shared files that force serialization, the final integration surface.

Do not parallelize when:

- The task is small enough for one pass
- All changes touch the same file or narrow function
- The next step depends on information you do not have yet
- Integration overhead exceeds the task itself

If any of these apply, implement directly without waves.

### 2. Create work items with real boundaries

Each work item needs: a single purpose, a bounded write scope (file paths or directories), one owner, one review owner, a concrete verification step.

Good write scopes: `src/api/*`, `tests/auth/*`, `docs/deploy.md`
Bad write scopes: `entire repo`, `misc fixes`, `whatever is needed`

### 3. Assign waves from dependencies plus write scope

- Wave 1: independent foundations
- Wave 2: work that depends on wave 1
- Wave 3: integration
- Wave 4: final verification

If two items touch the same file, they do not belong in the same wave.

### 3.5 Decide whether a reviewer is warranted

Reviewer role — use when the main risk is interface mismatch, incomplete acceptance criteria, or integration drift:

- Review plan completeness
- Verify checkpoint acceptance
- Inspect integration risk
- Do not turn the reviewer into a second owner for the same write scope

### 4. Initialize the plan file

```bash
PLAN_PATH=$(python3 scripts/init_parallel_plan.py \
  --task auth-hardening \
  --base-dir "$PWD")
```

Creates `plans/<task>/plan.md` from `assets/parallel-task-plan.md`.

### 5. Fill the plan before execution

Replace all vague placeholders with: actual paths, actual owners, actual dependencies, actual verification commands, checkpoint acceptance criteria.

### 6. Execute wave by wave

Within a wave: run independent items in parallel, keep item results updated immediately.

Between waves: stop at the checkpoint, verify acceptance criteria, integrate results or cut scope, update blockers and decisions, then advance.

### 7. Integrate locally

Integration is not a side task. Keep the merge, conflict resolution, and final consistency pass in a dedicated integration item or wave.

### 8. Verify after integration

Final verification should check: the promised behavior, cross-slice compatibility, tests or validation commands, docs or interface updates if relevant.

## Anti-Patterns

- Splitting work by "who seems free" instead of by write scope
- Delegating the blocking next step
- Running parallel edits against the same file
- Advancing waves without a checkpoint decision
- Creating a reviewer role so broad that ownership becomes unclear
- Skipping an integration wave because the pieces "look independent"
- Treating verification as optional

## Resources

- `scripts/init_parallel_plan.py`: creates a plan file from the template
- `assets/parallel-task-plan.md`: wave-based plan template
- `references/wave-planning.md`: decomposition heuristics and anti-patterns
