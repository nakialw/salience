---
name: parallel-implementation
description: Create wave-based implementation plans with disjoint write scopes, dependency links, and explicit integration steps. Use when the user wants a parallel implementation plan, worker split, safe multi-agent decomposition, or phased execution with parallel work.
metadata:
  short-description: Build wave-based execution plans
---

# Parallel Implementation

## Overview

Use this skill to turn a large task into a wave-based execution plan that supports parallel work without overlapping write scopes. The goal is not "more tasks"; it is safe decomposition with a clear critical path, explicit ownership, and an integration wave that brings the pieces back together.

The highest-value upgrade over a plain task list is the checkpoint gate between waves. Do not just split work; make it easy to stop, review, cut scope, and only then continue.

If the user only wants a normal serial plan, use `$task-plans` instead.

## Best Fit

- Large features split across distinct modules
- Multi-file refactors with natural subsystem boundaries
- Parallel worker decomposition before execution
- Tasks where integration and verification need to be explicit

## Avoid

- Tiny tasks that one agent can finish directly
- Changes that all touch the same file or same narrow function
- Work where the next action depends on information you do not have yet

## Core Rules

- One wave can be active at a time.
- Multiple work items inside the active wave can be in progress together.
- Same-wave write scopes must be disjoint.
- Every wave transition needs an explicit checkpoint.
- Every work item must define:
  - owner
  - review owner
  - write scope
  - dependencies
  - verification
- Review responsibility should stay lightweight and explicit.
- Reserve explicit waves for integration and final verification.
- Keep urgent critical-path work local when the next step depends on it immediately.
- Use worktree mode only as an escalation path for risky parallel edits, not as the default.

Read `references/wave-planning.md` when the split is ambiguous.

## Workflow

### 1. Map the task before splitting it

Identify:

- the critical path
- independent sidecars
- shared files that force serialization
- the final integration surface

Do not parallelize just because multiple subagents exist.

### 2. Create work items with real boundaries

Each work item needs:

- a single purpose
- a bounded write scope
- one owner
- one review owner
- a concrete verification step

Good write scopes:

- `src/api/*`
- `tests/auth/*`
- `docs/deploy.md`

Bad write scopes:

- `entire repo`
- `misc fixes`
- `whatever is needed`

### 3. Assign waves from dependencies plus write scope

Use waves to capture what can run together.

- Wave 1: independent foundations
- Wave 2: work that depends on wave 1
- Wave 3: integration
- Wave 4: final verification

If two items touch the same file, they do not belong in the same wave unless one is explicitly read-only.

### 3.5 Decide whether a reviewer or worktree mode is warranted

Reviewer role:

- Use a reviewer when the main risk is interface mismatch, incomplete acceptance criteria, or integration drift.
- Keep the role narrow:
  - review plan completeness
  - verify checkpoint acceptance
  - inspect integration risk
- Do not turn the reviewer into a second owner for the same write scope.

Worktree mode:

- Use it only when the task is big enough that filesystem isolation is useful and merge risk is real.
- Keep it optional and documented in the plan.
- Do not treat it as required for routine parallel work.
- Do not automate worktree creation in this skill.

### 4. Initialize the plan file

Run:

```bash
PLAN_PATH=$(python3 ~/.codex/skills/parallel-implementation/scripts/init_parallel_plan.py \
  --task auth-hardening \
  --base-dir "$PWD")
```

This creates `plans/<task>/plan.md` from `assets/parallel-task-plan.md`.

### 5. Fill the plan before execution

Do not leave vague placeholders in the final plan. Replace them with:

- actual paths
- actual owners
- actual dependencies
- actual verification commands
- actual checkpoint reviewers and acceptance criteria where relevant

The wave summary should let someone understand the whole execution order in under a minute.

### 6. Execute wave by wave

Within a wave:

- run independent items in parallel
- keep item results updated immediately

Between waves:

- stop at the checkpoint
- reviewer or main verifies the acceptance criteria
- integrate results or cut scope if needed
- update blockers and decisions
- only then advance

### 7. Integrate locally

Integration is not a side task. Keep the merge, conflict resolution, and final consistency pass in a dedicated integration item or wave.

### 8. Verify after integration

Final verification should check:

- the promised behavior
- cross-slice compatibility
- tests or validation commands
- docs or interface updates if relevant

## Anti-Patterns

- Splitting work by "who seems free" instead of by write scope
- Delegating the blocking next step
- Running parallel edits against the same file
- Advancing waves without a checkpoint decision
- Creating a reviewer role so broad that ownership becomes unclear
- Treating worktrees as a default instead of an escalation path
- Skipping an integration wave because the pieces "look independent"
- Treating verification as optional

## Resources

- `scripts/init_parallel_plan.py`: creates a plan file from the template
- `assets/parallel-task-plan.md`: wave-based plan template
- `references/wave-planning.md`: decomposition heuristics and anti-patterns
