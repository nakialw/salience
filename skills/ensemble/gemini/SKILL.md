---
name: ensemble-check
description: Run a multi-perspective ensemble analysis across Gemini, Claude, and Codex for code review, plan critique, debugging hypotheses, or writing synthesis. Use when the user asks for a second opinion, model comparison, adversarial review, consensus check, or multi-LLM comparison.
---

# Ensemble Check

## Overview

Use this skill when the user wants an explicit external second opinion from multiple local CLIs, not just more internal reasoning. Default to read-only prompts, keep the prompt identical across models, and produce durable artifacts that make agreement and disagreement easy to inspect.

The highest-value control is not the model list, it is the review posture. Keep mode and posture separate:

- mode = what is being reviewed
- posture = how disagreement is handled

## Workflow

### 1. Choose the review mode and posture

Pick one mode:

- `code-review`
- `plan-review`
- `debug`
- `writing`
- `research`

Pick one posture:

- `standard-consensus`: balanced comparison with a normal synthesis pass
- `dissent-first`: force the strongest non-consensus concern to surface before consensus language
- `adjudication`: collect independent first-pass outputs, then explicitly choose the strongest argument

Default model set: `gemini`, `codex`, `claude`. If one CLI is unavailable, continue with the remaining models and note the gap in `summary.md`.

### 2. Initialize the run directory

Run the helper script:

```bash
RUN_DIR=$(python3 scripts/init_ensemble_run.py \
  --slug auth-review \
  --mode code-review \
  --posture standard-consensus \
  --models gemini,codex,claude \
  --base-dir "$PWD")
```

Directory policy:

- If `plans/` exists, write to `plans/<slug>/ensemble/<timestamp>/`
- Otherwise, write to `reports/ensemble/<timestamp>-<slug>/`

### 3. Fill the shared prompt

Start from `assets/shared-prompt-template.md`. The prompt must be self-contained, comparable across models, and scoped to the exact decision or artifact under review.

Always include: objective, exact files or code regions, constraints, expected output contract, posture-specific instructions.

Posture guidance:

- `standard-consensus`: ask for the strongest grounded answer.
- `dissent-first`: require the first-pass answer to lead with the strongest plausible disagreement.
- `adjudication`: require each model to argue from evidence independently.

Do not feed one model's answer into another before all first-pass outputs are captured.

### 4. Run each model non-interactively

```bash
PROMPT=$(cat "$RUN_DIR/prompt.md")

# Codex
codex exec \
  --cd "$PWD" \
  --ephemeral \
  --sandbox read-only \
  --skip-git-repo-check \
  -o "$RUN_DIR/codex.md" \
  "$PROMPT"

# Claude
claude -p \
  --permission-mode plan \
  --output-format text \
  --no-session-persistence \
  "$PROMPT" > "$RUN_DIR/claude.md"

# Gemini (you are the host — write your own analysis directly to gemini.md)
```

Since Gemini is the host context, analyze the prompt directly and write your findings to `$RUN_DIR/gemini.md` rather than invoking yourself.

### 5. Synthesize after all first-pass outputs exist

Use `assets/summary-template.md`. Required sections:

- task summary
- posture and model set
- consensus
- strongest dissent
- decision or adjudication record
- recommended next step
- residual risks

Do not average outputs mechanically. Prefer the strongest argument backed by concrete evidence.

Posture-specific synthesis rules:

- `standard-consensus`: summarize where models align, but still record any material dissent.
- `dissent-first`: do not collapse disagreement too early. Preserve the sharpest objection.
- `adjudication`: explicitly say which argument wins and why.

### 6. Report the result

Return: the recommended action, the strongest consensus points, the most important disagreement, links to `summary.md` and any especially useful raw outputs.

## Operating Rules

- Keep the shared prompt stable across models.
- Default to read-only analysis.
- Save raw outputs before writing the synthesis.
- Keep mode and posture separate.
- If the user wants a sharper review, change posture before changing models.
- `dissent-first` is the best default for risky plans and adversarial review.
- `adjudication` is the best default when models produce materially different recommendations.
- If one model is clearly off-task, note it and move on rather than forcing consensus.

## Resources

- `scripts/init_ensemble_run.py`: creates the artifact directory and starter files
- `assets/shared-prompt-template.md`: shared prompt scaffold
- `assets/summary-template.md`: synthesis scaffold
- `examples/`: compact posture-specific examples
