# [Deep Review] Plan
**THIS PLAN FILE**: `plans/[task_name]/plan.md`
**Status Legend**: 📝 TODO, 🔄 IN_PROGRESS, ✅ DONE, ❌ FAILED

## Phases

### Phase 1: Context & Filtering
**Description:** Scan directory to identify valid source files while strictly excluding data >1MB, temp dirs, .git, serialized objects, and graphical artifacts.
**Actions:**
1. Run `find` or `glob` to list files.
2. Filter out exclusions (PDF, HTML, XLSX, large CSVs).
3. For large CSVs/logs: read the first 10 lines only.
4. Generate a list of `target_files.txt`.

### Phase 2: Exhaustive Analysis
**Description:** Review every file in `target_files.txt` line-by-line.
**Actions:**
1. Iterate through file list.
2. Read file content.
3. Analyze for bugs, logic errors, and documentation gaps.
4. Store findings in `plans/[task]/findings.md`.

### Phase 3: Q&A Readiness
**Description:** Pause and await user questions based on the review.
**Success Criteria:** Findings are indexed; ready for immediate query response.

## Additional Instructions
Create an extensive prompt including full path file names (quote as needed) for another LLM to extensively review the specific issues and implementations we have worked on. Include that all findings should go in a new Markdown document called `./todo-code-review-<specific appropriate tag>.md`, filling in the tag.

Make or update an extensive TODO in the TODO file to find and correct all errors, issues, or gaps. Also list the major critical enhancements required to accomplish the overall function and add them to the file. Put open questions or issues that require more information at the top and I'll address them. If this is a Git repository, create a new temporary branch and make your changes there; use clear, minimal commits with messages that explain why each change was made so a checking LLM can quickly understand the reasoning. Another LLM may be concurrently editing the file, so ensure your edits apply cleanly while respecting any existing changes.
