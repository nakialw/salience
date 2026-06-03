# note — sources and lineage

Design rationale for an auto/manual lab-notebook skill that records the reasoning behind substantial changes.

## Structured provenance beats free text

- Schröder, Staehlke, Groth, Nebe, Spors & Krüger (2022). *Structure-based knowledge acquisition from electronic lab notebooks for research data provenance documentation.* J Biomedical Semantics 13:4. doi:10.1186/s13326-021-00257-x. ELN protocols can be converted into machine-interpretable provenance (RO-Crate, FAIR). → **Emit consistent, parseable field headers** so entries can later become structured provenance.

## Capture null results and rejected approaches (the "pitfalls" field)

- Schapira et al. / The Open Lab Notebook Consortium (2019). *Electronic lab notebooks: good for science, good for society, good for scientists.* F1000Research 8:87. ELNs improve provenance, prevent data loss, aid reproducibility. The highest-value, most-often-lost content is failed attempts and dead ends. → **Make "pitfalls / rejected approaches" mandatory and substantive**; record what didn't work and why.

## Selective triggering (don't log everything)

- Shridhar et al. (2024). *ART: Ask, Refine, and Trust.* NAACL. arXiv:2311.07961. Acting on *everything* is wasteful; gate on a worth-it signal. → The 200-line diff threshold is a "is this substantial enough to record?" gate, analogous to ART's selective-action principle. (Shared rationale with `tap`/`clarify`.)

## Honesty caveat (do not repeat the productivity myth)

- The widely-cited "ELN saves ~9 hours/week" figure originates from a **vendor (SciNote) ROI study based on only 7 users** — not the peer-reviewed F1000Research paper, and not generalizable evidence. `note` is justified by **provenance and reproducibility**, not time savings. The skill explicitly instructs against repeating the 9-hours figure.

## Design mapping

| note feature | Basis |
|--------------|-------|
| Six fixed fields, consistent headers (parseable) | Schröder et al. (RO-Crate/FAIR provenance) |
| Mandatory, substantive "pitfalls" field | Schapira et al. (null results / dead ends are high-value, usually lost) |
| Result must state failure honestly | reproducibility value of negative results |
| Facts gathered from git, not memory | provenance integrity (no invented intent) |
| 200-line threshold to trigger | ART selective-action; "substantial change" heuristic |
| Hook never blocks the commit; degrades if no CLI | operational safety (post-commit hooks must not fail commits) |
| Recursion guard (skip notebook-only commits) | operational correctness |
| Provenance framing, not productivity claims | honesty re: the 7-user vendor "9h/week" figure |

## Caveats

- The provenance/reproducibility literature for ELNs is thinner and less quantitative than, e.g., the claim-verification literature; treat the design as principled-but-not-benchmarked.
- The 200-line threshold is a heuristic, not an evidence-based cutoff — tune per project.
- Auto-generated entries are only as honest as the diff + commit message; a misleading commit message yields a misleading "inferred goal" (hence the explicit `(inferred)` marker).
