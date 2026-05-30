# [TASK NAME] Deep Review Plan
**Plan file**: `plans/[TASK SLUG]/plan.md`
**Created**: [TIMESTAMP]
**Branch**: [BRANCH]

## Objective

Exhaustive review of [scope — directory, module, or file set].

## Success Criteria

- Every relevant source file reviewed
- Findings documented with file references and severity
- Ready for Q&A on any finding

## Phases

### Phase 1: Context and Filtering
**Status:** IN_PROGRESS
**Description:** Scan directory to identify valid source files while excluding data files (>1MB), temp dirs, .git, serialized objects, and generated artifacts.
**Actions:**
1. List files with Glob
2. Filter exclusions (binary, generated, data files)
3. For large files: read first 20 lines only for triage
4. Record the target file list in this plan
**Success Criteria:** Clean file list with no noise
**Result:** [Fill when complete]

### Phase 2: Exhaustive Analysis
**Status:** TODO
**Description:** Review every file in the target list.
**Actions:**
1. Read each file
2. Analyze for bugs, logic errors, documentation gaps, security issues
3. Record findings in `plans/[TASK SLUG]/findings.md`
**Success Criteria:** Every target file reviewed; findings indexed by file and severity
**Result:** [Fill when complete]

### Phase 3: Q&A Readiness
**Status:** TODO
**Description:** Pause and report findings to user.
**Success Criteria:** Findings indexed; ready for immediate query response
**Result:** [Fill when complete]

## Additional Output

Create `plans/[TASK SLUG]/findings.md` with all findings organized by severity, then by file.

## Key Decisions

- [Decision]: [Reasoning]

---
*Plan created: [TIMESTAMP]*
