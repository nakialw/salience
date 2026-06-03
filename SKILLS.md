# Skill index

| Skill | Claude (`/command`) | Codex | Gemini | Purpose |
|-------|---------------------|-------|--------|---------|
| **tap** | `/tap` | `tap` | `tap` | Adversarial review on `[[tapped]]` spans until convergence |
| **immune** | `/immune` | `immune` | `immune` | Auto-tap immunology spans → chain to `tap` (routes literature-checkable spans to `clarify`) |
| **clarify** | `/clarify` | — | — | Verify a claim against retrieved peer-reviewed literature (3-way verdict + strength) |
| **note** | `/note` | — | — | Append a structured lab-notebook entry after a substantial change (manual or git post-commit hook) |
| **introspect** | `/introspect` | — | — | Scope the next stage + write the cached-objectives doc the loop runs against |
| **anterospect** | `/anterospect` | — | — | Bounded iterate-to-convergence executor over the cached-objectives doc (halts on stall) |
| ensemble | `/ensemble` | `ensemble-check` | `ensemble` | Multi-perspective ensemble analysis |
| task-plan | `/task-plan` | `task-plans` | `task-plan` | Structured serial task planning |
| parallel-implementation | `/parallel-implementation` | `parallel-implementation` | `parallel-implementation` | Wave-based parallel execution |
| publication-figure-qc | `/publication-figure-qc` | `publication-figure-qc` | `publication-figure-qc` | Publication figure verification |
| deep-research-browser | `/deep-research-browser` | — | — | ChatGPT Deep Research via browser |

## Tap suite

- **`/tap`** — You mark spans with `[[...]]`; model iterates adversarial review until convergence.
- **`/immune`** — Auto-selects 3–6 immunology spans, shows `Auto-tapped (immune): …`, then runs full `tap`. v1.2 tiers spans by checkability (verifiable spans fill slots first) and routes literature-checkable spans to `clarify`.
- **`/clarify`** — Retrieves real PubMed/Clinical Trials/preprint/Consensus evidence and returns a 3-way SUPPORTS / REFUTES / NEI verdict with a strength tier. A literature-verified claim is the canonical *verifiable tap*; `immune` can route to it, and a Contested/NEI result hands the claim back to `tap` to represent the uncertainty faithfully. Claude-command only.

Specs: `skills/tap/codex/SKILL.md`, `skills/immune/codex/SKILL.md`, `skills/clarify/claude/clarify.md`
Lineage: `skills/clarify/references/sources.md` (32-source design rationale)
Calibration: `docs/calibration/calibration-v1.md`

## Lab workflow

- **`/note`** — Appends a six-field entry (date, title, goal, result, next step, pitfalls) to `docs/lab-notebook.md`, recording what a change did and what's risky about it. Run manually, or auto-fire on large commits via the hook.

Auto-fire setup (per repo where you want it):

```bash
ln -s /path/to/salience/skills/note/scripts/note-hook.sh .git/hooks/post-commit
chmod +x .git/hooks/post-commit
# tune: NOTE_THRESHOLD (default 200), NOTE_NOTEBOOK, NOTE_DISABLE=1
```

Spec: `skills/note/claude/note.md` · Hook: `skills/note/scripts/note-hook.sh`

## Staged execution loop (Claude Code)

- **`/introspect`** — Scopes the next stage (necessary tests, context, done-criterion), verifies the prior stage's load-bearing claims at the boundary (via `clarify`), and writes `plans/<task>/cached-objectives.md`.
- **`/anterospect`** — Bounded executor loop (default 5 iterations) over that cache: pick a tractable step + 3 reasons → check for inconsistencies → run two controlled experiments → tick completed objectives → update the cache. **Halts early** on done/convergence/stall (Degeneration-of-Thought guard), and routes only *decision-driving* empirical claims to `clarify` mid-loop.

Run `/introspect` first to create the cache, then `/anterospect` to execute it; loop back to `/introspect` at the next stage boundary. Specs: `skills/introspect/claude/introspect.md`, `skills/anterospect/claude/anterospect.md` · Shared lineage: `skills/introspect/references/sources.md`
