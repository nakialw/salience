# Plan Review Dissent-First Example

Use when the plan looks plausible but the main risk is hidden sequencing or false confidence.

Suggested init:

```bash
RUN_DIR=$(python3 ~/.codex/skills/ensemble-check/scripts/init_ensemble_run.py \
  --slug payment-rollout-plan \
  --mode plan-review \
  --posture dissent-first \
  --models codex,claude,gemini \
  --base-dir "$PWD")
```

Suggested scope:

- Files:
  - `plans/payment-rollout/plan.md`
- Ask for:
  - unsafe assumptions
  - missing steps
  - sequencing risks
  - the strongest non-consensus objection first

Use this when you want the ensemble to behave more like an adversarial design review than a consensus machine.
