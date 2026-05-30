# [TASK NAME] LLM Checker Plan
**Plan file**: `plans/[TASK SLUG]/plan.md`
**Created**: [TIMESTAMP]
**Branch**: [BRANCH]

## Objective

Capture a baseline snapshot, then review changes against it when instructed.

## Success Criteria

- Baseline captured before any changes
- Delta review identifies all modified/new files
- Issues documented with file references

## Phases

### Phase 1: Baseline Snapshot
**Status:** IN_PROGRESS
**Description:** Capture the current repository state before changes occur.
**Actions:**
1. Run git status and git log
2. Record file checksums or diff state
3. Save output to `plans/[TASK SLUG]/snapshot_baseline.txt`
**Success Criteria:** Snapshot saved and verifiable
**Result:** [Fill when complete]

### Phase 2: Wait for Instruction
**Status:** TODO
**Description:** Idle state. Do not proceed until the user provides instructions to review new changes.

### Phase 3: Delta Review
**Status:** TODO
**Description:** Compare new state against baseline snapshot.
**Actions:**
1. Identify modified and new files
2. Review each change for correctness, conventions, and issues
3. Document findings in `plans/[TASK SLUG]/delta-review.md`
**Success Criteria:** All changes reviewed; issues documented
**Result:** [Fill when complete]

## Key Decisions

- [Decision]: [Reasoning]

---
*Plan created: [TIMESTAMP]*
