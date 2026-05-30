---
argument-hint: <task description or plan type>
---

Create and execute a structured serial task plan for:

$ARGUMENTS

## Instructions

You are creating a serial task plan — a single phased plan executed one step at a time. The plan file is the single source of truth. If it's not in the plan, it didn't happen.

For wave-based parallel plans, use `/parallel-implementation` instead.
For external second opinions on a finished plan, use `/ensemble` instead.

### Step 1: Select the plan type

Based on the user's request, choose the appropriate template from `~/.claude/commands/references/task-plan-templates/`:

- **Default** (`general.md`): General-purpose serial planning for features, refactors, investigations, or any structured work.
- **Deep Review** (`deep-review.md`): Exhaustive code review — scan, filter, analyze every file, produce findings.
- **LLM Checker** (`llm-checker.md`): Baseline snapshot, wait for changes, then delta review against the snapshot.
- **Continuous Fix** (`continuous-fix.md`): Ongoing change detection and implementation review against a TODO list.
- **External LLM Prep** (`external-llm-prep.md`): Bundle repository context for handoff to an external LLM.

If the user specifies a type (e.g., "deep review of the auth module"), use that template. Otherwise default to `general.md`.

### Step 2: Read the template and create the plan

1. Read the selected template from `~/.claude/commands/references/task-plan-templates/`
2. Create `plans/<task-slug>/plan.md` with all placeholders replaced:
   - Task name and description
   - Current timestamp
   - Git branch (if in a git repo)
   - Objective and success criteria from the user's request
3. Mark Phase 1 as IN_PROGRESS

### Step 3: Execute phase by phase

**Rules:**
- Only one phase IN_PROGRESS at a time
- Record results immediately after each phase completes (commands run, outputs, errors, deviations)
- If new work appears mid-plan: stop, add a new phase, save, then execute
- The plan file is the only memory — keep it self-describing enough that any agent can resume by reading only the plan

**Status values:** TODO, IN_PROGRESS, DONE, FAILED, SKIPPED, BLOCKED

### Step 4: Maintain the plan

- Update the plan after every phase completion
- Record key decisions and lessons learned
- If the plan grows past ~20 completed phases, compact: summarize completed phases at the top, remove their details, continue with fresh phase numbers
- Keep the plan synchronized with any external task tracking the user mentions

### Plan principles

- **Self-describing**: All context needed to resume is in the plan file
- **Constantly updated**: Every action's result is recorded immediately
- **Single source of truth**: If it's not in the plan, it didn't happen
- **Safe to resume**: Any agent can pick up by reading only this file
