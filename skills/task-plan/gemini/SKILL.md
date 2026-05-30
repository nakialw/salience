---
name: task-plans
description: Create and maintain structured task plan files in plans/[task_name]/plan.md. Use when the user asks for a plan, references plan tags like Deep Review Plan, LLM Checker Plan, Continuous Fix Plan, External LLM Prep Plan, or requests to create/update plan files or TODO-driven execution.
---

# Task Plans

## Overview

Create a plan file, keep it updated, and use it as the single source of truth for execution.

Use this skill for normal serial planning.

For wave-based plans with explicit write scopes, dependencies, checkpoints, and parallel work items, use the `parallel-implementation` skill instead.

For external second opinions on a completed plan, use the `ensemble-check` skill after the plan exists.

## Workflow

1. Select the appropriate template:
   - [Deep Review] Plan -> `assets/deep-review-plan.md`
   - [LLM Checker] Plan -> `assets/llm-checker-plan.md`
   - [Continuous Fix] Plan -> `assets/continuous-fix-plan.md`
   - [External LLM Prep] Plan -> `assets/external-llm-prep-plan.md`
   - Default (general planning) -> `assets/task-plan-template.md`
2. Copy the chosen template to `plans/[task_name]/plan.md`.
3. Replace placeholders (task name, timestamps, branch, PR, etc.).
4. Mark Phase 1 as IN_PROGRESS (only one phase in progress at a time).
5. Execute phase by phase and record results immediately.
6. If new work appears, add a phase before executing it.

## Output conventions

- Use `plans/[task_name]/plan.md` as the primary record.
- Record tool calls and key outputs in each phase result (redact secrets).
- If asked to sync with external TODOs, update both, but keep the plan as the source of truth.

## Resources

- `assets/task-plan-template.md`: general plan template
- `assets/deep-review-plan.md`: exhaustive code review template
- `assets/llm-checker-plan.md`: baseline snapshot and delta review template
- `assets/continuous-fix-plan.md`: ongoing change detection template
- `assets/external-llm-prep-plan.md`: external LLM handoff template
- `references/task-plan-templates/`: shared template originals
