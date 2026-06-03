---
argument-hint: <immunology prompt to auto-tap and answer>
description: Auto-tap immunology spans (structural score), show selections, then full tap review.
---

Apply the **immune** skill (tap suite v1.1), then chain into **tap**, for:

$ARGUMENTS

## Instructions

`immune` marks *where* to emphasize; `tap` enforces *how hard* to review. No domain failure checklists.

### Step 0

Respect existing `[[...]]` — never double-wrap.

### Step 1 — Immunology gate

Use glossary patterns in `references/immune/immuno-glossary.md` as a filter only.

**No immuno signal** → answer normally; footer `— immune · 0 auto (0 manual) (no immuno gate)`; **skip tap**.

### Step 1b — Schema/admin bypass

**Skip immuno gate** (same as Step 1 fail) when **all** hold:

- Primary task is repo/file/schema admin: list columns, file format, git workflow, naming scheme, path enumeration
- No interpretive biological claim (no mechanism, trial contrast, responder/non-responder, "implies", "drives", etc.)
- Glossary hits are metadata-only (column headers, enum labels, paths) — not the analytic subject

**Verifiability-only** (when prompt asks statistical/file meaning but not biology): gate passes; auto-tap **at most 1–2** spans on file/statistical claims only; **do not** auto-tap bare cell-type header names; chain to `tap`.

### Step 2–4 — Segment, score, select

Score candidates +1 each for: interactivity (≥2 constraints), decomposability, verifiability, causal/comparative language, conceptual density (≥2 glossary entities in span).

Penalties: already tapped; tiny generic-only phrases; metadata-only cell-type labels in schema prompts.

**Tier by checkability (v1.2):** split candidates into a **checkable tier** (≥1 on verifiability OR decomposability — has an external check) and an **interpretive tier** (0 on both — dense/causal but unfalsifiable). Fill the 3–6 cap from the **checkable tier first**; pull interpretive spans only if slots remain. Demotion, not exclusion. This stops the densest-but-uncheckable spans from crowding out the ones `tap`/`clarify` handle reliably (Huang: introspection fails without an external signal; Kamoi: it works when verifiable).

Top spans → `[[...]]` in working copy. Merge overlaps.

### Step 5 — Show before answer (mandatory)

**First line** of every gated response:

`Auto-tapped (immune): "span1"; "span2"; … (scores: 4, 5, …)`

If zero auto spans (manual-only): `Auto-tapped (immune): none (M manual tap(s))`

Never skip this line. Do not print internal `R1…Rn` lists.

### Step 6 — Full tap

Run complete **tap** workflow on augmented prompt (`tap.md` command): draft → ≥2 adversarial passes → convergence. Objections cite **draft + tap text** only.

If prompt cites `submission/…` or a concrete file path: **Read** before claims about file contents.

**Route literature-checkable taps to `clarify` (v1.2):** for a checkable-tier tap, if the check is a **local file/stat** → stays in `tap` (read the file, red-team against it). If it's an **empirical biological claim** checkable against published evidence (mechanism, trial outcome, not a local file) → route to `clarify.md` on that claim; `tap`'s red-team reconciles the draft against `clarify`'s retrieved verdict instead of introspecting. Note it inline, e.g. `(clarify: SUPPORTS/Strong)`. If `clarify` returns Contested/NEI, the draft must represent that uncertainty faithfully. Interpretive-tier taps stay on `tap` introspection.

Deliver per **tap** Step 5 user-visible structure — adversarial work stays internal.

### Step 7 — Footers

After answer body, **separate plain-text lines** (never merge):

1. `— immune · N auto (M manual)`
2. `— clarify · …` (only if a span was routed to clarify)
3. `— tap · …` (from tap skill)

Full spec: `skills/immune/codex/SKILL.md`.
