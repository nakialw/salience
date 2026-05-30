# Wave Planning Reference

## Goal

Split a task into parallel work only when the split reduces total time without creating merge chaos.

The most common failure is not the split itself. It is skipping the checkpoint between waves and letting half-integrated work drift forward.

## Decomposition Checklist

Before creating waves, answer:

1. What is the immediate blocker on the critical path?
2. What can proceed independently of that blocker?
3. Which files or modules will each item write?
4. Where do the pieces reconnect?
5. How will each item be verified before integration?
6. Who signs off at the checkpoint before the next wave starts?
7. Does this task actually justify worktree mode, or is that just extra ceremony?

## Good Splits

### By subsystem

- Worker A: API handler and request validation
- Worker B: storage layer and migrations
- Main: integration plus end-to-end verification

### By artifact type

- Worker A: source changes
- Worker B: tests for a disjoint module
- Main: shared docs and interface pass

## Bad Splits

### Same-file parallelism

- Worker A: edit `src/auth/service.ts`
- Worker B: also edit `src/auth/service.ts`

This is serialization disguised as parallelism.

### Dependency blindness

- Worker A: build helper abstractions
- Worker B: consume helper abstractions before they exist

This creates waiting, rework, or both.

## Write Scope Rules

Use concrete write scopes:

- file paths
- directories
- modules
- test folders

Do not use:

- "core logic"
- "backend"
- "the feature"

## Checkpoint Gate

Every wave transition needs a short decision point:

- reviewer: who evaluates readiness to advance
- acceptance criteria: what must be true
- decision: advance, rework, or cut scope

If you cannot write those three lines, the wave boundary is probably not ready.

## Reviewer Role

Keep the reviewer lightweight:

- inspect interface compatibility
- confirm acceptance criteria
- call out missing verification

Do not let the reviewer become a second owner for the same write scope.

## Worktree Mode

Use worktree mode only when:

- the task is large enough that filesystem isolation helps
- the write scopes are mostly disjoint
- merge risk is still high enough to justify the extra overhead

Do not use worktree mode when:

- one agent can finish the task directly
- the same files will be edited anyway
- the overhead is larger than the risk

In Claude Code, worktree isolation is available natively via `isolation: "worktree"` on the Agent tool. In Codex, worktree mode is documentation-only guidance for manual branch management.

## When to Keep Work Local

Keep the task local when:

- the next action depends on the answer immediately
- the change is small enough for one pass
- the write scope is too shared to split safely
- the integration overhead is larger than the task itself

## Minimum Verification Standard

Every work item needs one verification line:

- command
- observable behavior
- review criterion

Integration and final verification need their own explicit items.
