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


### Step 3b — Tier by checkability (re-weighting, v1.2)

A high `tap_priority` can come purely from **Conceptual density + Interactivity + Causal/comparative** — but those reward spans that are *intellectually heavy*, not spans that can be *externally checked*. The heaviest, most causal claims ("CD8 programming **drives** responder outcomes") are often the **least** verifiable, and those are exactly where `tap`'s introspective review is weakest (Huang et al.: intrinsic self-correction fails without an external signal). Flat additive scoring therefore steers the suite toward its blind spot.

Fix: after scoring, split candidates into two tiers:

- **Checkable tier** — scored **≥1 on Verifiability OR Decomposability**. These have an external check (data, repo file, named method, or the literature), so `tap`'s adversarial review is reliable on them (Kamoi et al.).
- **Interpretive tier** — scored **0 on both** Verifiability and Decomposability (dense/causal but not externally checkable).

**Fill the auto-tap cap from the checkable tier first**, in `tap_priority` order. Only if slots remain (and any candidate clears the threshold) pull from the interpretive tier. This is a **demotion, not exclusion** — a dense-but-uncheckable span can still be tapped if room is left, but never displaces a checkable one. Effect: `immune` hands `tap` (and `clarify`) the spans they handle best, instead of impressive-but-unfalsifiable ones.

## Step 4 — Select spans

1. Sort candidates by `tap_priority` (descending) **within each tier** (Step 3b).
2. Fill the **top 3–6** slots (hard cap) from the **checkable tier first**, then the interpretive tier only if slots remain.
3. Merge overlapping spans if scores within 1 point — keep the superset.
4. Wrap selected text in `[[...]]` in the **working copy** of the prompt only.

If no candidate scores ≥2, auto-tap **at most 1** highest span or none — prefer under-tapping to bracketing the whole prompt. A checkable-tier span is preferred for that single slot even if an interpretive span scores equal.

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


### Step 6b — Route literature-checkable spans to `clarify` (v1.2)

For each **checkable-tier** tap, decide *what kind* of check applies:

- **Repo/file or stats check** (claim is verifiable against a named file, dataset, or method in the prompt) → stays in `tap`: read the file / inspect the data, then red-team the draft against it. This is the existing read-before-Pass-1 path.
- **Literature check** (an empirical biological claim checkable against published evidence — e.g. "IL-18 armoring enhances CAR-T persistence", a mechanism or trial-outcome assertion not tied to a local file) → route to [`clarify`](../../clarify/claude/clarify.md) on that claim. `clarify` retrieves real PubMed/trial/preprint evidence and returns a 3-way verdict + strength tier; `tap`'s red-team then reconciles the draft against that verdict instead of introspecting.

This is the canonical **verifiable tap**: the external check (retrieval) is exactly the regime where adversarial review is reliable rather than guesswork. Note the verdict inline on the tap, e.g. `(clarify: SUPPORTS/Strong)` or `(clarify: NEI/Contested)`. When `clarify` returns **Contested/NEI** on a claim that must still appear in the answer, the draft must represent that uncertainty faithfully (hedge, attribute, state the split) rather than asserting it.

Interpretive-tier taps (no external check) remain on `tap`'s introspective review — but they were filled last and only if slots remained, so they no longer crowd out the checkable ones.

## Step 7 — Footers (order, separate lines)

After the final answer body:

1. `— immune · N auto (M manual)` — plain text, **never** append tap info
2. `— clarify · …` — one line, only if a span was routed to `clarify` (Step 6b); plain text
3. `— tap · …` — one line per tap skill; plain text, no bold

Keep each footer on its **own line** — never merge `— immune ·`, `— clarify ·`, and `— tap ·` into one.

## Worked flow (abbreviated, v1.2)

**Prompt:** `Explain whether post-infusion CD8 cytotoxic programming explains responder outcomes in huCART19-IL18 and how IFNg-myeloid spatial gradients relate to IL-18 armoring.`

- Gate: pass (trial + cell + spatial terms).
- Candidates + tiering:
  - `[[IL-18 armoring]]` → enhances persistence: an empirical, **literature-checkable** claim → checkable tier.
  - `[[IFNg-myeloid spatial gradients]]` → checkable vs the spatial data/files if named → checkable tier.
  - `[[post-infusion CD8 cytotoxic programming explains responder outcomes]]` → dense + causal but **interpretive** (no external check) → interpretive tier; filled only if slots remain.
- Fill cap from checkable tier first → the verifiable spans take the slots; the heavy "explains responder outcomes" span is demoted (still tappable if room).
- Route (Step 6b): `IL-18 armoring → CAR-T persistence` goes to **`clarify`** (retrieval → e.g. `SUPPORTS/Moderate`); the spatial-gradient span stays in `tap` and is read against the data file; the interpretive CD8 span, if tapped, stays on `tap` introspection.
- Show Auto-tapped line → run `tap` (+ `clarify` where routed) → answer + footers (`— immune`, then `— clarify` if a span routed, then `— tap`).

## Additional resources

- [references/span-selection.md](references/span-selection.md) — literature lineage, Phase B deferred
- [references/immuno-glossary.md](references/immuno-glossary.md) — marking gate only
- [references/examples.md](references/examples.md) — calibration examples and test prompts
- [docs/calibration/calibration-v1.md](../../docs/calibration/calibration-v1.md) — batch results
