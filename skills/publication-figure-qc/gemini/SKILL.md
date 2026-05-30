---
name: publication-figure-qc
description: Vector-first publication figure verification for scientific panels and multi-panel composites. Use when a user wants publication-quality QC of PDFs, PNGs, Illustrator/AI exports, panel layouts, typography, whitespace, clipping, or explicit visual confirmation that reported defects are fixed and no new defects were introduced.
---

# Publication Figure QC

## Overview

Use this skill when figure work must be publication-ready and visually verified, not just rebuilt. The core rule is vector first, then explicit PNG inspection at every stage: source pane, composite, packet deliverable, and any user-requested crop.

Gemini is multimodal — view PNG files directly to visually inspect them. This is your primary verification mechanism.

## Hard Rules

- Do not claim a figure is fixed until you have personally viewed the rebuilt PNG output.
- Verify the final composite PNG, not just the source pane PNGs.
- Verify the exact final delivered PNG path after the last rebuild. Do not rely on stale temp files or memory of a previous pass.
- Do not run a dependent composite rebuild in parallel with an upstream source rebuild. Finish source first, then composite, then verify.
- Do not trust file-size probes or previews captured before the producing process has exited.
- If the reported defect is local to a panel letter, gutter, title, legend, or crop region, also inspect a zoomed crop of that exact region from the final delivered PNG.
- If a canonical prior render exists, compare the rebuilt output against it before closing.
- Always inspect at least one review-scale raster (downscaled full PNG that approximates on-screen review). Full-resolution alone is not sufficient for typography acceptance.
- Compare against both the original reported defects AND newly introduced defects.
- Fix defects at the highest-fidelity upstream source that can realistically remove them.
- Preserve editable/vector outputs whenever the pipeline supports them.
- Keep issue classes separate. A figure can be data-correct and still fail typography, spacing, clipping, or export quality.
- Every closeout must include a numeric publication-quality rating as N/10.
- Every closeout must list exact remaining issues that keep the figure below 10/10.
- Every closeout must include a numbered issue ledger with final status per item.
- Do not stop iterating while any open issue is still visible in the final delivered PNG.
- If a layout/typography defect survives one rebuild, enter **sweep mode**: generate and compare at least ten labeled candidate variants before closing.
- A 10/10 rating is only allowed when a durable markdown issue ledger exists and every listed issue is marked `verified closed`.
- Do not use "materially better" or "good enough" as closure criteria for publication-quality work.
- Never call a figure "perfect", "publication-ready", or "10/10" if it still looks globally assembled rather than designed.
- **10/10 is the required outcome.** Keep iterating until 10/10 is reached. The only acceptable reason to stop below 10/10 is an extreme blocker such as missing raw data that cannot be regenerated.
- **Every issue requires a verification crop region.** Record `crop-frac` coordinates when adding to ledger. At closeout, every issue must have a before/after comparison strip. An issue cannot be marked `verified closed` without a viewed comparison strip.
- **Adversarial fresh-eyes inspection is MANDATORY before any closeout.** See section 7b below.
- **Never verify by coordinate math alone.** If you calculate that a label "should be visible" based on x/y positions, you MUST ALSO visually confirm it by viewing a tight 600 DPI crop of that exact area.
- **Seam/boundary crops are mandatory.** Whenever content from different sources is composited, generate a 600 DPI crop of every seam/boundary area.
- **Side-by-side comparison for consistency.** When multiple similar elements should match, generate a side-by-side strip. Do not inspect them in isolation.
- **Whitespace audit for every panel.** If data occupies < 60% of the panel area, flag as excessive whitespace.

## Workflow

### 1. Baseline render and independent audit

Before any other step, create a high-res PNG from the current source, run spatial analysis, and independently identify all issues:

1. **Render the baseline PNG** at minimum 300 DPI.
2. **Render 600 DPI regional crops** — divide the figure into quadrants and render each at 600 DPI.
   ```bash
   python3 scripts/qc_views.py render input.pdf crop_TL.png --dpi 600 --crop-frac 0.0,0.0,0.5,0.5
   python3 scripts/qc_views.py render input.pdf crop_TR.png --dpi 600 --crop-frac 0.5,0.0,1.0,0.5
   python3 scripts/qc_views.py render input.pdf crop_BL.png --dpi 600 --crop-frac 0.0,0.5,0.5,1.0
   python3 scripts/qc_views.py render input.pdf crop_BR.png --dpi 600 --crop-frac 0.5,0.5,1.0,1.0
   ```
3. **Run spatial analysis** to measure margins, gutters, whitespace ratios.
   ```bash
   python3 scripts/qc_views.py spatial input.pdf
   ```
   Flag: margin asymmetry > 2pt, gutter std > 5px, quadrant whitespace variance > 5%, overall whitespace > 40%.
4. **Run font audit** (PDF sources).
   ```bash
   python3 scripts/qc_views.py fonts input.pdf
   ```
   Flag: > 2 font families, near-duplicate sizes < 0.5pt, > 5 distinct sizes.
5. **Render alignment guides overlay** (PDF sources).
   ```bash
   python3 scripts/qc_views.py guides input.pdf guides_overlay.png --dpi 300
   ```
6. **Visually inspect all renders** — full 300 DPI PNG, every 600 DPI crop, guides overlay.
7. **Independently enumerate every defect** — combine visual inspection with spatial analysis, font audit, and guides overlay. Check against [references/issue-taxonomy.md](references/issue-taxonomy.md) and [references/sequential-checklist.md](references/sequential-checklist.md). Include:
   - Typography, spacing/layout, data/legend, export quality, color
   - **Seam artifacts**: 600 DPI crops at every multi-source boundary
   - **Consistency comparison**: side-by-side strips of equivalent elements
   - **Whitespace fill ratio**: flag panels with < 60% data occupancy
   - **Label rendering order**: verify panel labels render on top of content
8. **Merge with user-reported issues** into a single unified ledger.

### 2. Capture the issue ledger

- Number items; keep numbering stable across iterations.
- Tag each item as `[user-reported]` or `[independent]`.
- **Record `crop-frac` coordinates** for each issue's verification window.
- **Generate baseline crop PNGs** at 600 DPI (`baseline_issueN.png`).
  ```bash
  python3 scripts/qc_views.py render input.pdf baseline_issue3.png --dpi 600 --crop-frac 0.5,0.0,1.0,0.4
  ```
- Status per item: `open`, `fixed pending visual check`, or `verified closed`.
- Ledger format:
  ```
  | # | Issue | Tag | Crop region | Baseline crop | Status |
  |---|-------|-----|-------------|---------------|--------|
  | 1 | Panel B label misaligned | [independent] | 0.45,0.0,0.75,0.15 | baseline_issue1.png | open |
  ```

### 3. Map the source chain

Find the highest-fidelity live source for each panel. Decide canonical deliverables.

### 4. Rebuild vector first

Regenerate source panes first, rebuild composite from vector parts, respect dependency order. Verify PDF stayed vector with `pdfinfo` if editability is required.

### 5. Generate QC views

```bash
python3 scripts/qc_views.py render input.pdf output.png --dpi 300
python3 scripts/qc_views.py render input.pdf crop.png --dpi 600 --crop-frac 0.0,0.65,1.0,1.0
python3 scripts/qc_views.py spatial input.pdf
python3 scripts/qc_views.py fonts input.pdf
python3 scripts/qc_views.py guides input.pdf guides.png --dpi 300
python3 scripts/qc_views.py diff before.pdf after.pdf diff.png --dpi 300
python3 scripts/qc_views.py strip strip.png img1.png img2.png --orientation horizontal
```

Generate at minimum: full composite PNG, 600 DPI regional crops, review-scale PNG, source pane PNGs, defect-area crops, spatial/font/guides analysis, **before/after diff PNG**.

### 6. Run the sequential visual check

Run [references/sequential-checklist.md](references/sequential-checklist.md) in order. Accept typography from both the final delivered PNG and a review-scale raster.

Adversarial question: "If I had not made these edits myself, would I still reject this page?"

### 7. Iterate upstream

Fix defects upstream and rebuild. **Generate before/after diff after every rebuild.**
```bash
python3 scripts/qc_views.py diff previous.png rebuilt.png diff.png
```

### 7b. Adversarial fresh-eyes inspection

**Purpose:** Defeat confirmation bias. A fresh session catches defects you are blind to.

**When to run:** After EVERY rebuild cycle.

**How to run:** Spawn a fresh headless session with ONLY the PNG path and a defect-hunting prompt:

```bash
gemini -p "You are a publication figure quality reviewer. You have NEVER seen this figure before.

Inspect this PNG file: {final_png_path}

For EACH panel, check for and report:
1. WHITE STRIPS or SEAMS
2. LABEL OCCLUSION
3. FONT/SPACING INCONSISTENCY
4. WHITESPACE (estimate data fill percentage)
5. ALIGNMENT
6. CLIPPING
7. RENDERING ARTIFACTS

Report EVERY defect with: exact location, severity (blocking/minor/cosmetic), suggested crop-frac region.
Be adversarial. Assume defects exist." \
  --approval-mode plan \
  --output-format text > adversarial_review.md
```

If `gemini` is unavailable for self-invocation, use `claude -p --permission-mode plan` or `codex exec --ephemeral --sandbox read-only` as alternatives.

**Gate rule:** If ANY blocking or minor defect is found, add to ledger and return to step 7.

### 8. Final per-item visual verification

For **each** ledger item:

1. Generate final crop at 600 DPI using recorded `crop-frac`.
2. Generate before/after comparison strip.
   ```bash
   python3 scripts/qc_views.py strip compare_issue3.png baseline_issue3.png final_issue3.png --orientation horizontal
   ```
3. Visually inspect the comparison strip.
4. Record verdict: `verified closed`, `improved but open`, or `still open`. Include comparison strip path as evidence.

**Gate rule:** If any item is not `verified closed`, return to step 7.

### 9. Report precisely

Closeout must name: exact files rebuilt, exact PNGs viewed, issue classes checked, residual risk, numeric rating (N/10), numbered issue ledger with crop regions and comparison strip paths, and whether ensemble review was used.

## References

- [references/sequential-checklist.md](references/sequential-checklist.md): ordered QC procedure
- [references/issue-taxonomy.md](references/issue-taxonomy.md): defect classes to check separately
- [scripts/qc_views.py](scripts/qc_views.py): render/crop/strip/spatial/fonts/guides/diff helper
