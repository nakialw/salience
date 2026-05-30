---
argument-hint: <task to implement in parallel>
---

Execute a wave-based parallel implementation for the following task:

$ARGUMENTS

## Instructions

You are executing a parallel implementation workflow. The goal is safe decomposition with a clear critical path, exclusive file ownership per work item, explicit checkpoint gates between waves, and an integration wave that brings the pieces back together.

The highest-value upgrade over a plain task list is the checkpoint gate between waves. Do not just split work — make it easy to stop, review, cut scope, and only then continue.

Do not parallelize for its own sake — only when the split reduces total time without creating merge chaos.

### Step 1: Map the task before splitting

Use Glob, Grep, and Read to explore the codebase. Before any decomposition, identify:

- **Critical path**: what must happen first — the blocking foundation
- **Independent sidecars**: work that can proceed without waiting for the critical path
- **Shared files**: files that multiple changes need to touch — these force serialization
- **Integration surface**: where the parallel pieces reconnect

If the split is ambiguous, read `~/.claude/commands/references/wave-planning.md` for decomposition heuristics.

**Do NOT parallelize when:**

- The task is small enough for one pass
- All changes touch the same file or narrow function
- The next step depends on information you do not have yet
- Integration overhead exceeds the task itself

If any of these apply, implement directly without waves.

### Step 2: Decompose into waves

Create work items with real boundaries. Each work item needs:

- A single purpose
- A bounded, concrete write scope (file paths or directories — never "backend" or "misc")
- One owner
- A review owner (lightweight reviewer for checkpoint sign-off)
- A concrete verification step

Assign waves based on dependencies and write scope:

- **Wave 1**: Independent foundations (no dependencies)
- **Wave 2**: Work that depends on Wave 1 outputs
- **Wave 3**: Integration — merge, conflict resolution, interface alignment
- **Wave 4**: Final verification — check promised behavior, cross-slice compatibility, run tests

**Rule**: If two items write to the same file, they cannot be in the same wave.

### Step 2.5: Decide on reviewer and worktree mode

**Reviewer role** — use when the main risk is interface mismatch, incomplete acceptance criteria, or integration drift:

- Review plan completeness
- Verify checkpoint acceptance
- Inspect integration risk
- Do NOT let the reviewer become a second owner for the same write scope

**Worktree mode** — use only as an escalation for risky parallel edits:

- Use when the task is large enough that filesystem isolation helps and merge risk is real
- Do NOT use when one agent can finish the task directly or the same files will be edited anyway
- Do NOT treat it as the default for routine parallel work

### Step 3: Create the plan file

1. Read the template: `~/.claude/commands/references/parallel-task-plan-template.md`
2. Create `plans/<task-slug>/plan.md` with all placeholders replaced by actual values:
   - Real file paths in write scopes
   - Real verification commands
   - Real dependencies between items
   - Current git branch and timestamp
   - Review owners for each work item
   - Checkpoint acceptance criteria for each wave transition
   - Worktree mode status (off by default, with justification if enabled)
3. The wave summary table should let someone understand the entire execution order in under a minute.

Do not leave vague placeholders in the final plan.

### Step 4: Execute wave by wave

For each wave:

**Within a wave** — launch same-wave items as parallel Agent subagents:

- Use `isolation: "worktree"` if worktree mode is enabled for this plan; otherwise use default isolation
- Each agent receives: its work item description, write scope, verification command, and relevant file context from Read
- Each agent should commit its work with a descriptive message
- Tell agents: "Implement the work item. Run the verification command. Report what you did and whether verification passed."

**Checkpoint gate between waves** — stop and evaluate before advancing:

1. Collect results from all agents in the completed wave
2. Update each work item's Status and Result in the plan file
3. Evaluate the checkpoint acceptance criteria:
   - Are all work items verified?
   - Do the interfaces align?
   - Is any scope cut needed?
4. Record the checkpoint decision: **advance**, **rework**, or **cut scope**
5. If worktree mode: merge worktree changes into the main working tree
6. Only then advance to the next wave

### Step 5: Integration wave

This is not a side task. The integration wave must:

- Merge all parallel outputs into the main branch/tree
- Resolve any conflicts
- Verify interfaces align across work items
- Run integration-level checks
- Update the plan file

### Step 6: Verification wave

Final verification checks:

- The promised behavior from the objective works end-to-end
- Cross-slice compatibility (pieces work together, not just individually)
- All verification commands from individual work items still pass after integration
- Docs or interface updates if relevant

Update the plan file with final results and mark complete.

### Anti-patterns to avoid

- **Same-file parallelism**: Two agents editing the same file is serialization disguised as parallelism.
- **Delegating the blocker**: The critical-path item should not be delegated if the next step depends on it immediately.
- **Advancing waves without a checkpoint decision**: Always stop, evaluate, and record the decision.
- **Reviewer scope creep**: The reviewer inspects interfaces and acceptance — they do not become a second owner.
- **Worktrees as default**: Worktree mode is an escalation path, not the standard operating mode.
- **Skipping integration**: Even if pieces look independent, explicitly verify they compose correctly.
- **Vague write scopes**: "core logic" or "the feature" are not write scopes. Use file paths.
- **Treating verification as optional**: Every work item and the final plan need concrete verification.

### Reporting

After all waves complete, report:

- What was implemented (summary of completed work items)
- The plan file path (`plans/<task-slug>/plan.md`)
- Checkpoint decisions made at each wave transition
- Any items that required adjustment or deviation from the original plan
- Final verification results
