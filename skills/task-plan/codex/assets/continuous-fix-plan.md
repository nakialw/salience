# [Continuous Fix] Plan
**THIS PLAN FILE**: `plans/[task_name]/plan.md`
**Status Legend**: 📝 TODO, 🔄 IN_PROGRESS, ✅ DONE, ❌ FAILED

## Phases

### Phase 1: Change Detection
**Description:** Identify implementations since the last snapshot.
**Actions:**
1. Run `git diff` or compare against the previous plan state.

### Phase 2: Implementation Review
**Description:** Check code/docs for correctness.
**Actions:**
1. Read new implementations.
2. Verify against project conventions.

### Phase 3: Documentation
**Description:** Update `TODO_FIXES.md` with new findings.
**Actions:**
1. Read `TODO_FIXES.md`.
2. Prepend new section `## Ongoing Gemini code checks`.
3. Add fixes as single lines with extensive rationale.

## Additional Instructions
Now begin implementing the TODO. Focus on one section at a time as I paste the queue and update the TODO. As we progress, check off each item and add a single line under the checked item summarizing the precise edit made. I'll give you the first TODO items to work on.
