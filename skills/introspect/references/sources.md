# introspect + anterospect — sources and lineage

Design rationale for the scoper/executor loop pair. The shared artifact is `plans/<task>/cached-objectives.md`; the shared risk is degenerate self-iteration. (This file is the primary lineage for both skills; `anterospect/references/sources.md` points here.)

## The core risk: Degeneration-of-Thought

- Liang, He, Jiao et al. (2024). *Encouraging Divergent Thinking in LLMs through Multi-Agent Debate (MAD).* EMNLP. arXiv:2305.19118. Names **Degeneration-of-Thought (DoT)**: once an LLM is confident in its answer, self-reflection cannot generate novel correction even when the answer is wrong. Mitigated by role separation, an external/adversarial signal, an **adaptive break**, and *modest* (not extreme) disagreement. → This is exactly the failure mode of `anterospect` running self-directed iterations. The defenses are baked in: a **hard stall/convergence stop** (adaptive break), an **external `clarify` signal** at decision points (breaks self-confidence), and a separate scoper (`introspect`) vs executor (`anterospect`) role split.

## Knowing when to stop (bounded iteration)

- Shridhar et al. (2024). *ART: Ask, Refine, and Trust.* NAACL. arXiv:2311.07961. Refining/acting on *everything* over-refines and can flip correct results to incorrect; a gate decides when to act and a ranker decides whether to trust the result. → Iteration count is a **ceiling**, not a quota; stop on no-progress. Verify (via `clarify`) only **decision-driving** claims, not every result. (Shared with `tap`, `clarify`, `note`.)
- Du, Li, Torralba, Tenenbaum & Mordatch (2024). *Improving Factuality and Reasoning in Language Models through Multiagent Debate.* ICML. arXiv:2305.14325. Debate/iteration improves factuality but is **compute-bounded** (3 agents × 2 rounds for cost). → Keep loops bounded (default 5) and verification selective; iteration is not free.

## External signal beats introspection (why clarify is wired in)

- Kamoi et al. (2024). *When Can LLMs Actually Correct Their Own Mistakes?* arXiv:2406.01297. Self-correction is reliable when feedback is reliable or tasks are decomposable/verifiable; unreliable from pure introspection. → Decision-driving empirical claims get an **external check** (`clarify` retrieval), not self-review. (Shared rationale with `tap` and the `immune` checkability tiering.)
- Huang et al. (2024). *Large Language Models Cannot Self-Correct Reasoning Yet.* ICLR. arXiv:2310.01798. Intrinsic self-correction often fails to improve (and can harm) without an external signal. → Same conclusion: the loop's confidence must be checked against something outside itself at the points that matter.

## Build on a durable, honest record (the cache)

- task-plan convention (this repo): a single plan file as source of truth, updated phase by phase. → `cached-objectives.md` **extends** this: same durable-artifact discipline, plus iterate-to-convergence execution and carried-forward verified claims. Objectives are checkboxes so completion is unambiguous and machine-parseable.
- CoVe (Dhuliawala et al., 2024, arXiv:2309.11495) — verify independently of the draft. → `introspect`'s stage-boundary verification checks claims *before* they become foundations, not after the next stage assumes them.

## Design mapping

| Loop-pair feature | Basis |
|-------------------|-------|
| Separate scoper (`introspect`) vs executor (`anterospect`) | MAD role separation (anti-DoT) |
| Hard stall/convergence stop; cap is a ceiling | MAD adaptive break; ART stop-when-done |
| Mid-loop `clarify` only on decision-driving claims | ART selective verification; Kamoi/Huang (external signal) |
| Stage-boundary verification before claims become foundations | CoVe (verify independently); Kamoi |
| Carry verified claims forward in the cache | avoid re-litigating settled facts / building on refuted ones |
| Checkbox objectives, durable cache file | task-plan convention (single source of truth) |
| Mandatory "open risks" field | honest record; surfaces the assumption most likely wrong |
| Two controlled experiments per iteration | interpretability (isolate one variable); tractability |

## Caveats

- This pair is an **execution pattern**, not a benchmarked system — the design is principled (anti-DoT, bounded, selectively verified) but its value depends on the executor's honesty about progress and risk. The hard stop and external check reduce, not eliminate, the risk of a confident-but-wrong loop.
- The DoT and bounded-debate findings come from multi-agent debate research; applying them to a single-agent iterate-to-convergence loop is a reasoned extrapolation, not a direct result.
- `clarify`'s mid-loop value is capped by retrieval quality (the SciFact-Open lesson) and only applies to claims with external literature — local codebase/dataset claims are verified by experiment, not `clarify`.
