# Code Review Consensus Example

Use when you want a normal ensemble review with a clear findings-first output.

Suggested init:

```bash
RUN_DIR=$(python3 ~/.codex/skills/ensemble-check/scripts/init_ensemble_run.py \
  --slug auth-service-review \
  --mode code-review \
  --posture standard-consensus \
  --models codex,claude,gemini \
  --base-dir "$PWD")
```

Suggested scope:

- Files:
  - `src/auth/service.ts`
  - `tests/auth/service.test.ts`
- Ask for:
  - findings first
  - severity
  - file references
  - missing-test risks

Use this when you mainly want agreement on bugs, regressions, and test gaps.
