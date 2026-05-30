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

Top **3–6** spans → `[[...]]` in working copy. Merge overlaps.

### Step 5 — Show before answer (mandatory)

**First line** of every gated response:

`Auto-tapped (immune): "span1"; "span2"; … (scores: 4, 5, …)`

If zero auto spans (manual-only): `Auto-tapped (immune): none (M manual tap(s))`

Never skip this line. Do not print internal `R1…Rn` lists.

### Step 6 — Full tap

Run complete **tap** workflow on augmented prompt (`tap.md` command): draft → ≥2 adversarial passes → convergence. Objections cite **draft + tap text** only.

If prompt cites `submission/…` or a concrete file path: **Read** before claims about file contents.

Deliver per **tap** Step 5 user-visible structure — adversarial work stays internal.

### Step 7 — Footers

After answer body, **two separate plain-text lines** (never merge):

1. `— immune · N auto (M manual)`
2. `— tap · …` (from tap skill)

Full spec: `skills/immune/codex/SKILL.md`.
