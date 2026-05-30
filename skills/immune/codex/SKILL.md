---
name: immune
description: >-
  Auto-select and [[bracket]] immunology spans in a prompt using structural
  tap_priority scoring, then chain into the tap skill for adversarial review.
  Use when the user invokes /immune, immune on, or immune+tap on immunology
  writing, interpretation, or analysis prompts. Does not use domain failure
  checklists — only span marking; tap handles critique.
metadata:
  short-description: Auto-tap immunology spans and chain to tap
---

# immune

`immune` is a **tap-suite lens**: it decides *where* to emphasize immunology content in a prompt, then hands off to [`tap`](../tap/codex/SKILL.md) for *how hard* to review.

- **`immune`** — structural scoring → auto `[[...]]` on selected spans (cap 3–6)
- **`tap`** — adversarial convergence on all taps (manual + auto)

**No** neglect-pattern tables, **no** `immune-lens:` theme metadata for the critic. Objections during `tap` must cite **draft sentence + tap text** only.

Scoring dimensions are literature-motivated but **heuristic until lab-calibrated** — see [references/span-selection.md](references/span-selection.md). The glossary is for **marking only** — see [references/immuno-glossary.md](references/immuno-glossary.md).

## Step 0 — Enable and respect manual taps

Run when the user invokes `/immune`, says `immune on`, or `immune+tap`.

- **Never** double-wrap existing `[[...]]`; treat manual taps as already selected.
- Preserve manual tap count for the footer (`M manual`).

## Step 1 — Immunology gate (prompt-level)

If the prompt has **no** immunology signal (no match to [immuno-glossary.md](references/immuno-glossary.md) and no clear immuno context in the task):

- Answer the prompt **normally** — do **not** run the `tap` loop.
- Footer only: `— immune · 0 auto (0 manual) (no immuno gate)`

The glossary is a **filter for candidates**, not a checklist of mistakes to hunt.

## Step 1b — Schema/admin bypass

**Skip immuno gate** (same behavior as Step 1 fail) when **all** hold:

- Primary task is **repo/file/schema admin**: list columns, describe file format, git workflow, naming scheme, path enumeration
- **No** interpretive biological claim requested (no "implies", "drives", "mechanism", trial contrast, responder vs non-responder, etc.)
- Glossary hits are **metadata-only** (column headers, enum labels, paths) — not the analytic subject

**Verifiability-only mode** (prompt asks statistical/file meaning but not biology — e.g. "what each column means statistically"):

- Gate passes; auto-tap **at most 1–2** spans on file/statistical claims (`what each column means statistically`, file path)
- **Do not** auto-tap bare cell-type header names as immuno spans
- Chain to `tap` with the reduced span set

## Step 2 — Segment candidates

From the user prompt, extract candidate spans:

- Coordinated clauses and noun phrases with modifiers
- Lists of cell types, pathways, or trial contrasts
- Phrases with comparative or causal language

**Exclude** as auto-tap candidates:

- Bare generic terms alone (`immune`, `inflammation`, `cytokines` without mechanism)
- Pure methods/stats boilerplate unless tied to immuno mechanism in the same span
- Text already inside `[[...]]`
- Bare cell-type names appearing only as column headers or enum labels in schema/admin prompts

## Step 3 — Score each candidate (`tap_priority`, internal)

For each candidate, add **+1** per dimension satisfied (max 5). Document scores internally; optional in the Auto-tapped line.

| Dimension | +1 when |
|-----------|---------|
| **Interactivity** | ≥2 interacting constraints (e.g. cell/state + process, spatial + ligand, trial arm + mechanism) |
| **Decomposability** | Span splits into ≥2 checkable sub-claims (pairs with `tap` Step 1b) |
| **Verifiability** | Claims checkable vs data, repo files, or methods named in the prompt |
| **Causal/comparative** | e.g. drives, reprograms, mediates, vs, without, post- vs pre-, responder vs non-responder |
| **Conceptual density** | ≥2 distinct immuno entities/relations per [glossary](references/immuno-glossary.md) in one span |

**Penalties:**

- Already `[[tapped]]`: exclude from auto selection (manual wins)
- &lt;3 words and only one generic glossary term: −2 (usually skip)

## Step 4 — Select spans

1. Sort candidates by `tap_priority` (descending).
2. Take **top 3–6** spans (hard cap).
3. Merge overlapping spans if scores within 1 point — keep the superset.
4. Wrap selected text in `[[...]]` in the **working copy** of the prompt only.

If no candidate scores ≥2, auto-tap **at most 1** highest span or none — prefer under-tapping to bracketing the whole prompt.

## Step 5 — Report (visibility, mandatory)

**First line** of every gated response — never skip:

`Auto-tapped (immune): "span1"; "span2"; … (scores: 4, 5, …)`

If zero auto spans (manual-only): `Auto-tapped (immune): none (M manual tap(s))`

List manual `[[...]]` taps in the same line when helpful.

Do **not** print internal `R1…Rn` decomposition lists (that is `tap` Step 1b, internal only).

## Step 6 — Chain to `tap`

Apply the full **`tap`** workflow from [../tap/codex/SKILL.md](../tap/codex/SKILL.md) on the augmented prompt (manual + auto taps):

- Step 1: all `[[...]]` are tap targets
- Step 1b: compound taps decompose automatically
- Steps 2–5: draft, adversarial review (span-anchored), convergence, clean answer per **tap** user-visible output rules

**Critique rules (inherited from `tap`):**

- Factored check and red-team use **tap text + draft** only
- Each objection cites a draft sentence and what the tap requires
- No immunology “typical failure” templates

If the prompt cites a **repo path** (`submission/…`, concrete filename): **Read** the file before Pass 1 claims about its contents.

## Step 7 — Footers (order, separate lines)

After the final answer body:

1. `— immune · N auto (M manual)` — plain text, **never** append tap info
2. `— tap · …` — one line per tap skill; plain text, no bold

## Worked flow (abbreviated)

**Prompt:** `Explain whether post-infusion CD8 cytotoxic programming explains responder outcomes in huCART19-IL18 and how IFNg-myeloid spatial gradients relate to IL-18 armoring.`

- Gate: pass (trial + cell + spatial terms).
- Auto-tap examples: `[[post-infusion CD8 cytotoxic programming]]`, `[[responder outcomes]]`, `[[IFNg-myeloid spatial gradients]]`, `[[IL-18 armoring]]` — scores ~4–5; cap may drop one borderline span.
- Show Auto-tapped line → run `tap` → answer + both footers.

## Additional resources

- [references/span-selection.md](references/span-selection.md) — literature lineage, Phase B deferred
- [references/immuno-glossary.md](references/immuno-glossary.md) — marking gate only
- [references/examples.md](references/examples.md) — calibration examples and test prompts
- [docs/calibration/calibration-v1.md](../../docs/calibration/calibration-v1.md) — batch results
