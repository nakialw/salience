# [LLM Checker] Plan
**THIS PLAN FILE**: `plans/[task_name]/plan.md`
**Status Legend**: 📝 TODO, 🔄 IN_PROGRESS, ✅ DONE, ❌ FAILED

## Phases

### Phase 1: Baseline Snapshot
**Description:** Capture the current repository state before changes occur.
**Actions:**
1. Run `git status`.
2. Generate checksums for all tracked files.
3. Save output to `plans/[task]/snapshot_baseline.txt`.
**Result:** Snapshot saved.

### Phase 2: Wait for Instruction
**Description:** IDLE state. Await detailed instructions from the user to review new codebase changes.
**Status:** 📝 TODO (Do not proceed until prompted).

### Phase 3: Delta Review
**Description:** Compare new state against `snapshot_baseline.txt`.
**Actions:**
1. Identify modified/new files.
2. Create `todo-gemini-review.md`.
3. List all identified issues in that file.
