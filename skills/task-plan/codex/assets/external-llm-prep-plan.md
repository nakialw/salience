# [External LLM Prep] Plan
**THIS PLAN FILE**: `plans/[task_name]/plan.md`
**Status Legend**: 📝 TODO, 🔄 IN_PROGRESS, ✅ DONE, ❌ FAILED

## Phases

### Phase 1: Repository Mapping
**Description:** Generate high-level tree view and identify key files.
**Actions:**
1. Run `tree` (respecting `.gitignore`).
2. Identify "most recent edits" for prioritization.

### Phase 2: Content Bundling
**Description:** Prepare <10 files with <100k tokens total.
**Actions:**
1. Create `temp-YYYYMMDD-HHMM-repo-review/`.
2. Concatenate relevant source code (preserving structure).
3. Create `companion_prompt.md` with the tree view and verbose issue list.

### Phase 3: Final Output
**Description:** Verify token counts and file limits.
