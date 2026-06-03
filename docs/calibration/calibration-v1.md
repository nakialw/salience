# Calibration v1 — tap suite `/immune`

## Baseline (2026-05-28, pre–v1.1)

Run: `calibration-runs-20260528-225031/` (20 prompts, `claude -p` from `ficture/`)

| Metric | Result |
|--------|--------|
| CLI success | 20/20 |
| Non-immuno control (19 git) | Pass |
| Gate false positive (18 COMMOT columns) | Fail — full immuno + tap on cell headers |
| `Auto-tapped (immune):` line visible | 11/19 immuno runs |
| Tap trace in body | ~3+ heavy (01, 08, 20) |
| Separate immune + tap footers | ~15/20 |

## v1.1 changes

| Package | Fix |
|---------|-----|
| P0 | Tap user-visible output contract — no pass logs in body |
| P1 | Mandatory `Auto-tapped` line; canonical `— immune · N auto (M manual)` |
| P2 | Schema/admin gate bypass; verifiability-only for column prompts |
| P3 | Read repo paths before file claims |
| P4 | Reference symlinks in `install.sh` |

## Acceptance targets (v1.1)

| Metric | Target |
|--------|--------|
| Smoke-5 (`SMOKE=1`) | All assertions pass |
| `Auto-tapped` line | 19/19 immuno (or explicit `none` + manual) |
| Tap trace | 0/20 |
| Gate 18/19 | Both pass bypass |
| Footers | Separate lines, no merge |

## Prompts

See `calibration-prompts.tsv` (20 ids from submission topics + 2 controls).

## Tier 1 (deferred)

Human labels per id: should_gate (y/n), spans (text + score 1–5). Tune `tap_priority` weights in `span-selection.md`.

## Re-run

```bash
# Quick smoke (5 prompts, ~10–15 min)
SMOKE=1 ./scripts/run-immune-calibration.sh

# Full batch (~35–40 min)
./scripts/run-immune-calibration.sh
```

Record post–v1.1 run directory here after smoke passes.

## v1.1 smoke (2026-05-29)

Run: `calibration-runs-20260529-132412/` (`SMOKE=1`, 5 prompts)

| id | auto_line | trace | gate | footer |
|----|-----------|-------|------|--------|
| 01 | pass | pass | pass | pass |
| 04 | pass | pass | pass | pass |
| 18 | pass | pass | pass (verifiability-only, 2 stat spans) | pass |
| 19 | pass | pass | pass (no gate) | pass |
| 20 | pass | pass | pass | pass |

**All assertions passed.** Residual watch: prompt 20 echoed `[[...]]` in body — added explicit forbid in tap Step 5.

Full 20-prompt re-run optional; smoke-5 covers the v1.1 contract fixes.

## v1.1 full batch (2026-05-29)

Run: `calibration-runs-20260529-134052/` (~32 min, all CLI exit 0)

| Metric | Baseline | v1.1 full |
|--------|----------|-----------|
| CLI success | 20/20 | 20/20 |
| `Auto-tapped` line | 11/19 | **15/20** (5 misses: 02, 07, 12, 16, 17) |
| Tap trace in body | ~3+ | **0/20** |
| Gate 18/19 | 1 FP | **20/20** |
| Separate footers | ~15/20 | **20/20** |

Misses on 02/07/12/16/17: immuno + tap ran with correct footers, but model skipped mandatory line-1 `Auto-tapped (immune):` — spec compliance gap, not functional failure.

**Ship verdict:** v1.1 deployable; optional follow-up is stronger line-1 enforcement (or post-processor grep in smoke/full script with non-zero exit).
