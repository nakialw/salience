---
argument-hint: <topic or question to analyze>
---

Run a multi-perspective ensemble analysis on the following topic:

$ARGUMENTS

## Instructions

You are performing an ensemble analysis — multiple independent investigations of the same question from different analytical lenses, followed by synthesis. This eliminates single-perspective blind spots.

The highest-value control is not the agent count — it is the review posture. Keep mode and posture separate:

- mode = what is being reviewed
- posture = how disagreement is handled

### Step 1: Determine mode and posture

Assess the topic and current codebase context. Classify the review mode:

- `code-review`: bugs, correctness, security, regressions
- `plan-review`: missing steps, unsafe assumptions, sequencing risks
- `debug`: root cause hypotheses, discriminating checks
- `writing`: clarity, structure, completeness
- `research`: tradeoffs, alternatives, evidence gathering

If unclear, default to `research`.

Choose a review posture:

- `standard-consensus`: balanced comparison with a normal synthesis pass. Best for routine reviews where you mainly want agreement on findings.
- `dissent-first`: force the strongest non-consensus concern to surface before consensus language. Best for risky plans and adversarial review.
- `adjudication`: collect independent first-pass outputs, then explicitly choose the strongest argument. Best when models produce materially different recommendations.

If the user specifies a posture, use it. Otherwise, default to `standard-consensus` for code-review, `dissent-first` for plan-review and debug, and `standard-consensus` for writing and research.

### Step 2: Gather context

Before spawning agents, use Glob/Grep/Read to identify the relevant files, code regions, or artifacts. Build a shared context summary that each agent will receive — this ensures all perspectives analyze the same evidence.

### Step 3: Spawn parallel investigation agents

Launch 3-4 Agent subagents **in a single message** (parallel, not sequential). Each agent receives:

1. The topic: the user's question verbatim
2. The shared context: files and code gathered in Step 2
3. A unique analytical lens (below)
4. The posture instruction (below)
5. Output instructions: return structured findings — findings first, evidence tied to specific files, confidence notes, one recommended action

**Agent lenses:**

- **Agent A — Correctness & Security**: Focus on bugs, regressions, vulnerabilities, data integrity issues, error handling gaps. If code review, order findings by severity.
- **Agent B — Architecture & Design**: Focus on design tradeoffs, maintainability, coupling, abstraction quality, naming, separation of concerns. Flag over-engineering and under-engineering.
- **Agent C — Coverage & Edge Cases**: Focus on test coverage gaps, unhandled edge cases, error paths, boundary conditions, missing validation. Identify what would break under stress.
- **Agent D — Requirements & Constraints** (include for code-review and plan-review modes): Focus on alignment with stated requirements, missing specifications, implicit assumptions, constraint violations.

**Posture instructions to include in each agent prompt:**

- `standard-consensus`: "Review normally and give the strongest grounded answer."
- `dissent-first`: "Lead with the strongest plausible disagreement, objection, or failure mode before broader agreement."
- `adjudication`: "Argue from the evidence independently. Do not try to force consensus early. Make your argument explicit enough that a later synthesis can choose among competing positions."

Each agent is `subagent_type: "general-purpose"`. No worktree isolation needed — ensemble analysis is read-only.

**Model diversity:** The Agent tool's `model` parameter only accepts `sonnet`, `opus`, or `haiku`. External model names (e.g., "gemini", "codex", "gpt") are not valid and will cause errors. To maximize perspective diversity, distribute agents across the available models — e.g., 2 sonnet + 2 haiku, or mix in opus for the highest-stakes lens. If the user requests specific external models by name, acknowledge the constraint and map to the closest available model.

Tell each agent: "Return your findings as structured markdown. Do not produce conversational text. Lead with findings, not reasoning."

### Step 4: Synthesize

After all agents return, produce a synthesis. Do NOT average outputs mechanically. Prefer the strongest argument backed by concrete evidence.

**Required synthesis sections:**

- **Consensus**: Points where 2+ agents agree. These are high-confidence findings.
- **Strongest Dissent**: The most important disagreement or objection. Preserve the sharpest objection even if you ultimately reject it.
- **Decision**: The strongest position after comparing outputs. If posture is `adjudication`, explicitly say which argument wins and why.
- **Recommended Next Step**: One concrete action.
- **Residual Risks**: What remains uncertain even after multi-perspective analysis.

**Posture-specific synthesis rules:**

- `standard-consensus`: summarize where agents align, but still record any material dissent.
- `dissent-first`: do not collapse disagreement too early. Preserve the sharpest objection even if you ultimately reject it.
- `adjudication`: explicitly say which argument wins and why.

### Step 5: Save artifacts

Create a run directory:

- If a `plans/` directory exists in the working directory: `plans/ensemble/<timestamp>-<slug>/`
- Otherwise: `reports/ensemble/<timestamp>-<slug>/`

Where `<slug>` is a lowercase-hyphenated version of the topic and `<timestamp>` is `YYYYMMDD-HHMMSS`.

Save:

- `prompt.md` — the shared prompt, context, mode, and posture given to all agents
- `agent-correctness.md` — Agent A output
- `agent-architecture.md` — Agent B output
- `agent-coverage.md` — Agent C output
- `agent-requirements.md` — Agent D output (if used)
- `summary.md` — the synthesis from Step 4

### Step 6: Report

Return to the user:

- The recommended action
- The 2-3 strongest consensus points
- The most important disagreement or dissent
- The path to `summary.md`

Keep the report concise. The detailed analysis lives in the saved artifacts.

## Operating Rules

- Keep the shared prompt stable across agents.
- Default to read-only analysis.
- Save raw outputs before writing the synthesis.
- Keep mode and posture separate.
- If the user wants a sharper review, change posture before adding agents.
- `dissent-first` is the best default for risky plans and adversarial review.
- `adjudication` is the best default when agents produce materially different recommendations.
- If one agent is clearly off-task, note it and move on rather than forcing consensus.
