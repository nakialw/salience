---
name: ensemble-check
description: Run a small multi-LLM ensemble review across Codex, Claude, and Gemini for code review, plan critique, debugging hypotheses, or writing synthesis. Use when the user asks for a second opinion, model comparison, adversarial review, or consensus check.
metadata:
  short-description: Compare multiple LLM outputs
---

# Ensemble Check

## Overview

Use this skill when the user wants an explicit external second opinion from multiple local CLIs, not just more internal reasoning. Default to read-only prompts, keep the prompt identical across models, and produce durable artifacts that make agreement and disagreement easy to inspect.

The highest-value control is not the model list, it is the review posture. Keep mode and posture separate:

- mode = what is being reviewed
- posture = how disagreement is handled

## Best Fit

- Findings-first code review
- Plan critique before implementation
- Debugging hypothesis comparison
- Writing or research synthesis
- Dissent-oriented review before a risky change
- Explicit adjudication when models disagree materially
- "What do Claude and Gemini think?" style requests

## Avoid

- Trivial tasks where a second opinion will not change the answer
- Tasks containing secrets you do not want written into model prompts or output files
- Huge, uncurated contexts where the real problem is bad scoping rather than lack of opinions
- Edit-heavy tasks unless the user explicitly wants models to propose code changes

## Workflow

### 1. Choose the review mode and posture

Pick one mode up front and keep it explicit in the artifacts:

- `code-review`
- `plan-review`
- `debug`
- `writing`
- `research`

Pick one posture up front and keep it explicit in the artifacts:

- `standard-consensus`: balanced comparison with a normal synthesis pass
- `dissent-first`: force the strongest non-consensus concern to surface before consensus language
- `adjudication`: collect independent first-pass outputs, then explicitly choose the strongest argument in the final synthesis

Default model set:

- `codex`
- `claude`
- `gemini`

If one CLI is unavailable, continue with the remaining models and note the gap in `summary.md`.

### 2. Initialize the run directory

Run the helper script from the skill directory:

```bash
RUN_DIR=$(python3 ~/.codex/skills/ensemble-check/scripts/init_ensemble_run.py \
  --slug auth-review \
  --mode code-review \
  --posture standard-consensus \
  --models codex,claude,gemini \
  --base-dir "$PWD")
```

Directory policy:

- If `plans/` exists, write to `plans/<slug>/ensemble/<timestamp>/`
- Otherwise, write to `reports/ensemble/<timestamp>-<slug>/`

The script creates:

- `prompt.md`
- `summary.md`
- `metadata.json`
- one markdown file per selected model, for example:
  - `codex.md`
  - `claude.md`
  - `gemini.md`

### 3. Fill the shared prompt

Start from `assets/shared-prompt-template.md`.

The prompt must be:

- self-contained
- comparable across models
- scoped to the exact decision or artifact under review

Always include:

- objective
- exact files or code regions
- constraints
- expected output contract
- posture-specific instructions

For code review, ask for:

- findings first
- severity
- file references
- confidence or uncertainty notes

Posture guidance:

- `standard-consensus`: ask for the strongest grounded answer after reviewing the material normally.
- `dissent-first`: require the first-pass answer to lead with the strongest plausible disagreement, objection, or failure mode.
- `adjudication`: require each model to argue from the evidence independently and avoid trying to force consensus early.

Do not feed one model's answer into another before all first-pass outputs are captured.

### 4. Run each model non-interactively

Prefer read-only or plan-style settings unless the user explicitly wants edits.

```bash
PROMPT=$(cat "$RUN_DIR/prompt.md")

codex exec \
  --cd "$PWD" \
  --ephemeral \
  --sandbox read-only \
  --skip-git-repo-check \
  -o "$RUN_DIR/codex.md" \
  "$PROMPT"

claude -p \
  --permission-mode plan \
  --output-format text \
  --no-session-persistence \
  "$PROMPT" > "$RUN_DIR/claude.md"

gemini -p "$PROMPT" \
  --approval-mode plan \
  --output-format text > "$RUN_DIR/gemini.md"
```

If the prompt is especially long or shell-sensitive, keep it in `prompt.md` and use a shell variable only once, exactly as above.

### 5. Synthesize after all first-pass outputs exist

Use `assets/summary-template.md` and fill it from the model outputs. Keep the synthesis compact and decision-oriented.

Required sections:

- task summary
- posture and model set
- consensus
- strongest dissent
- decision or adjudication record
- recommended next step
- residual risks

Do not average outputs mechanically. Prefer the strongest argument that is backed by the concrete files or prompt constraints.

Posture-specific synthesis rules:

- `standard-consensus`: summarize where the models align, but still record any material dissent.
- `dissent-first`: do not collapse disagreement too early. Preserve the sharpest objection even if you ultimately reject it.
- `adjudication`: explicitly say which argument wins and why.

### 6. Report the result

Return:

- the recommended action
- the strongest consensus points
- the most important disagreement
- links to `summary.md` and any especially useful raw outputs

## Operating Rules

- Keep the shared prompt stable across models.
- Default to read-only analysis.
- Save raw outputs before writing the synthesis.
- Prefer two or three strong models over many shallow variants.
- If one model is clearly off-task, note it and move on rather than forcing consensus.
- Keep mode and posture separate.
- If the user wants a sharper review, change posture before changing models.
- `dissent-first` is the best default for risky plans and adversarial review.
- `adjudication` is the best default when the models produce materially different recommendations.

## Resources

- `scripts/init_ensemble_run.py`: creates the artifact directory and starter files
- `assets/shared-prompt-template.md`: shared prompt scaffold
- `assets/summary-template.md`: synthesis scaffold
- `examples/`: compact posture-specific examples
