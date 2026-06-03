# anterospect — sources and lineage

`anterospect` (executor) and [`introspect`](../../introspect/claude/introspect.md) (scoper) are a loop pair sharing one artifact (`plans/<task>/cached-objectives.md`) and one core risk (degenerate self-iteration). The full design rationale and citations live in the shared lineage:

→ **[introspect/references/sources.md](../../introspect/references/sources.md)**

Load-bearing points for `anterospect` specifically:

- **Degeneration-of-Thought** (Liang et al., MAD, EMNLP 2024, arXiv:2305.19118) — a confident model can't self-correct via introspection. `anterospect`'s **hard stall/convergence stop** is the "adaptive break" that bounds this, and the **external `clarify` signal** at decision points is what breaks self-reinforcing confidence.
- **Bounded iteration** (ART, Shridhar et al., NAACL 2024, arXiv:2311.07961; Du et al., ICML 2024, arXiv:2305.14325) — iteration count is a *ceiling*, not a quota; stop on no-progress, and verify selectively (decision-driving claims only), because iteration and verification both cost.
- **External signal beats introspection** (Kamoi et al., arXiv:2406.01297; Huang et al., ICLR 2024, arXiv:2310.01798) — the loop's confidence is checked against retrieval (`clarify`), not against itself, at the points that determine direction.

See the shared file for the full design-mapping table and caveats.
