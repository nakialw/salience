---
name: immune
description: >-
  Auto-select and [[bracket]] immunology spans using structural tap_priority
  scoring, show Auto-tapped line, then chain into tap for adversarial review.
  Use for /immune, immune on, or immune+tap on immunology prompts.
---

# immune

Lens skill: structural auto-`[[tap]]` on immunology spans (cap 3–6), then full **tap** workflow. No neglect-pattern critic scripts.

## Workflow

0. Respect manual `[[...]]`
1. **Gate** — no immuno context → normal answer, `— immune · 0 auto (0 manual) (no immuno gate)`
1b. **Schema/admin bypass** — file/column/git tasks with metadata-only glossary hits → skip gate; verifiability-only → ≤2 spans on file/stat claims, not cell-type headers
2. **Segment** candidates (clauses, immuno NPs, causal/comparative phrases)
3. **Score** tap_priority (+1 each: interactivity, decomposability, verifiability, causal/comparative, conceptual density)
4. **Select** top 3–6, merge overlaps, bracket in working copy
5. **Show** (mandatory line 1): `Auto-tapped (immune): … (scores: …)` or `none (M manual tap(s))`
6. **Chain tap** — span-anchored adversarial review; Read repo paths before file claims
7. **Footers** — `— immune · N auto (M manual)` then `— tap · …` on **separate plain-text lines**

## Resources

- `references/span-selection.md` — literature + honesty notes
- `references/immuno-glossary.md` — marking gate only
- `references/examples.md` — test prompts
- `../immune/codex/SKILL.md` — full spec
