# [TASK NAME] Parallel Implementation Plan
**Plan file**: `plans/[TASK SLUG]/plan.md`
**Created**: [TIMESTAMP]
**Branch**: [BRANCH]

## Objective

[State the task in one paragraph.]

## Success Criteria

- [Behavior or artifact that must exist]
- [Verification or test that must pass]

## Constraints

- [Constraint]

## Worktree Mode

**Status:** off
**Use Only If:** [Condition that justifies filesystem isolation]
**Reason:** [Why worktree mode is needed or N/A]

## Parallelization Rules

- One wave may be active at a time.
- Multiple work items inside the active wave may be in progress together.
- Same-wave write scopes must be disjoint.
- Every work item must define owner, write scope, dependencies, and verification.
- Every wave transition needs an explicit checkpoint decision.
- Keep integration and final verification explicit.

## Wave Summary

| Wave | Goal | Work Items | Status | Notes |
| --- | --- | --- | --- | --- |
| 1 | [foundation] | [W1-A, W1-B] | TODO | [notes] |
| 2 | [dependent work] | [W2-A] | TODO | [notes] |
| 3 | Integration | [W3-INT] | TODO | [notes] |
| 4 | Verification | [W4-VERIFY] | TODO | [notes] |

## Wave Checkpoints

### After Wave 1
**Status:** TODO
**Reviewer:** [main or reviewer]
**Acceptance Criteria:** [What must be true before Wave 2]
**Decision:** [advance | rework | cut scope]
**Notes:** [Checkpoint outcome]

### After Wave 2
**Status:** TODO
**Reviewer:** [main or reviewer]
**Acceptance Criteria:** [What must be true before integration]
**Decision:** [advance | rework | cut scope]
**Notes:** [Checkpoint outcome]

### After Wave 3
**Status:** TODO
**Reviewer:** [main or reviewer]
**Acceptance Criteria:** [What must be true before final verification]
**Decision:** [advance | rework | cut scope]
**Notes:** [Checkpoint outcome]

## Work Items

### W1-A: [Title]
**Status:** TODO
**Owner:** [main or agent name]
**Review Owner:** [main or reviewer]
**Wave:** 1
**Write Scope:** `[path/or/module]`
**Depends On:** none
**Purpose:** [What this item accomplishes]
**Verification:** [Command or check]
**Result:** [Fill after execution]

### W1-B: [Title]
**Status:** TODO
**Owner:** [main or agent name]
**Review Owner:** [main or reviewer]
**Wave:** 1
**Write Scope:** `[path/or/module]`
**Depends On:** none
**Purpose:** [What this item accomplishes]
**Verification:** [Command or check]
**Result:** [Fill after execution]

### W2-A: [Title]
**Status:** TODO
**Owner:** [main or agent name]
**Review Owner:** [main or reviewer]
**Wave:** 2
**Write Scope:** `[path/or/module]`
**Depends On:** W1-A
**Purpose:** [What this item accomplishes]
**Verification:** [Command or check]
**Result:** [Fill after execution]

### W3-INT: Integration
**Status:** TODO
**Owner:** main
**Review Owner:** [main or reviewer]
**Wave:** 3
**Write Scope:** `[integration files]`
**Depends On:** [All implementation items]
**Purpose:** Merge outputs, resolve conflicts, align interfaces.
**Verification:** [Integration checks]
**Result:** [Fill after execution]

### W4-VERIFY: Final Verification
**Status:** TODO
**Owner:** main
**Review Owner:** [main or reviewer]
**Wave:** 4
**Write Scope:** read-only or verification artifacts only
**Depends On:** W3-INT
**Purpose:** Verify the integrated result satisfies the objective.
**Verification:** [Final tests, review steps, or manual checks]
**Result:** [Fill after execution]

## Decisions

- [Decision]: [Reason]

## Blockers

- [Blocker]: [Resolution path]

## Notes

- [Cross-wave notes or risks]
