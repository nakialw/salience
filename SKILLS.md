# Skill index

| Skill | Claude (`/command`) | Codex | Gemini | Purpose |
|-------|---------------------|-------|--------|---------|
| **tap** | `/tap` | `tap` | `tap` | Adversarial review on `[[tapped]]` spans until convergence |
| **immune** | `/immune` | `immune` | `immune` | Auto-tap immunology spans → chain to `tap` |
| ensemble | `/ensemble` | `ensemble-check` | `ensemble` | Multi-perspective ensemble analysis |
| task-plan | `/task-plan` | `task-plans` | `task-plan` | Structured serial task planning |
| parallel-implementation | `/parallel-implementation` | `parallel-implementation` | `parallel-implementation` | Wave-based parallel execution |
| publication-figure-qc | `/publication-figure-qc` | `publication-figure-qc` | `publication-figure-qc` | Publication figure verification |
| deep-research-browser | `/deep-research-browser` | — | — | ChatGPT Deep Research via browser |

## Tap suite

- **`/tap`** — You mark spans with `[[...]]`; model iterates adversarial review until convergence.
- **`/immune`** — Auto-selects 3–6 immunology spans, shows `Auto-tapped (immune): …`, then runs full `tap`.

Specs: `skills/tap/codex/SKILL.md`, `skills/immune/codex/SKILL.md`  
Calibration: `docs/calibration/calibration-v1.md`
