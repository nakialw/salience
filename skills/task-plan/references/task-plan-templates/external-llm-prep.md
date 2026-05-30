# [TASK NAME] External LLM Prep Plan
**Plan file**: `plans/[TASK SLUG]/plan.md`
**Created**: [TIMESTAMP]
**Branch**: [BRANCH]

## Objective

Bundle repository context for handoff to an external LLM for review or analysis.

## Success Criteria

- Relevant files identified and prioritized
- Context bundle under token limit (target <100k tokens)
- Companion prompt ready with tree view and issue list

## Phases

### Phase 1: Repository Mapping
**Status:** IN_PROGRESS
**Description:** Generate high-level tree view and identify key files.
**Actions:**
1. Generate directory tree (respecting .gitignore)
2. Identify most recently edited files for prioritization
3. Estimate token counts for candidate files
**Success Criteria:** File priority list with token estimates
**Result:** [Fill when complete]

### Phase 2: Content Bundling
**Status:** TODO
**Description:** Prepare a compact context bundle.
**Actions:**
1. Create `plans/[TASK SLUG]/context-bundle/`
2. Concatenate relevant source (preserving structure, under token limit)
3. Create `companion_prompt.md` with tree view, issue list, and review instructions
**Success Criteria:** Bundle under token limit; companion prompt complete
**Result:** [Fill when complete]

### Phase 3: Final Verification
**Status:** TODO
**Description:** Verify bundle is complete and within limits.
**Actions:**
1. Check token count estimate
2. Verify no sensitive content included
3. Confirm companion prompt is self-contained
**Success Criteria:** Bundle ready for external handoff
**Result:** [Fill when complete]

## Key Decisions

- [Decision]: [Reasoning]

---
*Plan created: [TIMESTAMP]*
