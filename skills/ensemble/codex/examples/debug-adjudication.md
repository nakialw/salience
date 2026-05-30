# Debug Adjudication Example

Use when the likely causes are contested and you want a final explicit decision after independent first-pass outputs.

Suggested init:

```bash
RUN_DIR=$(python3 ~/.codex/skills/ensemble-check/scripts/init_ensemble_run.py \
  --slug flaky-cache-bug \
  --mode debug \
  --posture adjudication \
  --models codex,claude,gemini \
  --base-dir "$PWD")
```

Suggested scope:

- Files:
  - `src/cache/client.py`
  - `tests/cache/test_client.py`
  - recent error log excerpt
- Ask for:
  - ranked root-cause hypotheses
  - discriminating checks
  - the strongest argument from the evidence

Use this when disagreement is expected and you want the final synthesis to explicitly choose the best-supported explanation.
