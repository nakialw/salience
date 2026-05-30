# Span selection — literature lineage

`immune` selects spans using **structural** signals, not immunology “typical mistake” themes. Dimensions below motivate the scoring rubric; **+1 weights are heuristic** until calibrated on lab-annotated prompts.

## When extra review helps (output-level → informs cap and selectivity)

| Source | Finding | Implication for `immune` |
|--------|---------|---------------------------|
| Shridhar et al., ART ([arXiv:2311.07961](https://arxiv.org/abs/2311.07961)) | Always refining hurts; ~30–35% selective refinement wins | Cap auto-taps at 3–6; do not bracket whole prompts |
| Huang et al. ([arXiv:2310.01798](https://arxiv.org/abs/2310.01798)) | Intrinsic self-correction often fails without external signal | `tap` after marking; use tools when verifiable |
| Kamoi et al. ([arXiv:2406.01297](https://arxiv.org/abs/2406.01297)) | Self-correction works when feedback is reliable or tasks are decomposable/verifiable | Score decomposability + verifiability on spans |

## Complexity of text (input-level → motivates dimensions)

| Source | Measure | Maps to `tap_priority` |
|--------|---------|----------------------|
| Sweller, element interactivity ([review](https://link.springer.com/article/10.1007/s10648-023-09782-w)) | Interacting elements in a claim | **Interactivity** (+1 if ≥2 constraints) |
| Hulpus et al. / CoCo ([ACL 2018](https://aclanthology.org/C18-1027/), [LREC 2020](https://aclanthology.org/2020.lrec-1.887/)) | KG-based conceptual complexity | **Conceptual density** (+1 if multiple linked immuno concepts) |
| Lexical density (linguistics) | Content-word ratio | Weak alone; subsumed by density + span length |

## Decomposability and verification (span-level → pairs with `tap`)

| Source | Idea | Maps to |
|--------|------|---------|
| Dhuliawala et al., CoVe ([arXiv:2309.11495](https://arxiv.org/abs/2309.11495)) | Break claims into independent checks | **Decomposability**; `tap` Step 1b |
| Kamoi survey | Verification easier than generation for decomposable responses | Prefer multi-claim spans for auto-tap |

## Prompt importance (future — Phase B, not v1)

| Source | Idea | Deferred |
|--------|------|----------|
| Sequence Salience ([arXiv:2404.07498](https://arxiv.org/html/2404.07498)) | Which prompt segments influence output | Post-draft attribution auto-tap |
| JoPA ([ACL 2025](https://aclanthology.org/2025.acl-long.1074/)) | Counterfactual prompt component importance | Same |
| Farquhar et al., semantic entropy ([Nature 2024](https://www.nature.com/articles/s41586-024-07421-0)) | Uncertainty over meanings | Post-draft high-uncertainty spans |

## Calibration path

1. Collect 30–50 real lab prompts.
2. Annotate “should auto-tap” spans (human gold).
3. Tune dimension weights or thresholds to maximize precision/recall.
4. Document version in this file.

See [docs/calibration/calibration-v1.md](../../docs/calibration/calibration-v1.md) for the first 20-prompt batch and v1.1 acceptance targets.

## Schema/admin gate bypass (v1.1)

Skip immuno gate when the primary task is file/schema/repo admin and glossary hits are metadata-only (column headers, paths). For statistical column meaning without biological interpretation, use **verifiability-only** mode: ≤2 auto-taps on file/stat claims; do not bracket bare cell-type header names.

Until Tier 1 human labels: treat scores as **ordinal ranking**, not calibrated probabilities.

## What we explicitly avoid

- Theme-based neglect tables (cherry-picked objections)
- `immune-lens:` metadata fed to the critic
- Flesch/readability as “needs tap” (wrong direction for depth)
