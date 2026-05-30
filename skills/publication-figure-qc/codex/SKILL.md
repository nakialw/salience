---
name: publication-figure-qc
description: Vector-first publication figure verification for scientific panels and multi-panel composites. Use when a user wants publication-quality QC of PDFs, PNGs, Illustrator/AI exports, panel layouts, typography, whitespace, clipping, or explicit visual confirmation that reported defects are fixed and no new defects were introduced.
---

# Publication Figure QC

## Overview

Use this skill when figure work must be publication-ready and visually verified, not just rebuilt. The core rule is vector first, then explicit PNG inspection at every stage: source pane, composite, packet deliverable, and any user-requested crop.

## Hard Rules

- Do not claim a figure is fixed until you have personally viewed the rebuilt PNG output.
- Verify the final composite PNG, not just the source pane PNGs.
- Verify the exact final delivered PNG path after the last rebuild iteration. Do not rely on a stale temp file, an earlier QC render, or memory of a previous pass.
- Do not run a dependent composite rebuild in parallel with an upstream source rebuild. Finish the source rebuild first, then rebuild the dependent composite, then verify.
- Do not trust packet mirrors, copied QC mirrors, file-size probes, or previews captured before the producing process has exited successfully.
- If the reported defect is local to a panel letter, gutter, title band, legend, or crop region, you must also inspect a zoomed crop from the final delivered PNG that reproduces that exact region.
- If a canonical prior render exists, compare the rebuilt output against it before closing.
- Always inspect at least one review-scale raster of the final figure (for example, a downscaled full PNG that approximates how a human will actually review the page on screen). Full-resolution renders alone are not sufficient for typography or panel-letter acceptance.
- Compare against both the original reported defects and newly introduced defects from the verification pass.
- Fix defects at the highest-fidelity upstream source that can realistically remove them.
- Preserve editable/vector outputs whenever the current pipeline supports them.
- Keep issue classes separate. A figure can be data-correct and still fail typography, spacing, clipping, or export quality.
- Every closeout must include a numeric publication-quality rating in the form `N/10`.
- Every closeout must list the exact remaining issues that keep the figure below `10/10`.
- Every closeout must include a numbered issue ledger with one line per issue and a final status for each line.
- Do not stop iterating while any open issue in the ledger is still visible in the final delivered PNG or the required defect crop.
- If a layout / typography defect survives one rebuild, enter **sweep mode**: generate and compare at least ten labeled candidate variants or ten explicitly logged refinement iterations before closing.
- A `10/10` rating is only allowed when a durable markdown issue ledger exists and every listed issue is marked `verified closed`.
- Do not use `materially better` or `good enough` as closure criteria for publication-quality work.
- Never call a figure `perfect`, `publication-ready`, or `10/10` if it still looks globally assembled rather than designed.
- **10/10 is the required outcome.** Keep iterating until 10/10 is reached, no matter how many loops are required. The only acceptable reason to stop below 10/10 is an extreme blocker such as missing raw data that cannot be regenerated.
- **Every issue requires a verification crop region.** When an issue is added to the ledger, record the `crop-frac` coordinates that isolate the defect area. At closeout, every issue must have a before/after comparison strip generated from these coordinates. An issue cannot be marked `verified closed` without a viewed comparison strip showing the defect is gone.
- **Adversarial fresh-eyes inspection is MANDATORY before any closeout.** After all fixes, run a separate ephemeral session to inspect the final delivered PNG. The session has NO context about what was changed or what issues existed. If it finds issues you missed, add them to the ledger and fix them. See the "Adversarial Fresh-Eyes Inspection" section below.
- **Never verify by coordinate math alone.** If you calculate that a label "should be visible" based on x/y positions, you MUST ALSO visually confirm it by viewing a tight 600 DPI crop of that exact area. Coordinate math tells you what SHOULD happen; visual inspection tells you what DID happen.
- **Seam/boundary crops are mandatory.** Whenever content from different sources is composited (repair overlays, clip boundaries, multi-source assembly), generate a 600 DPI crop of every seam/boundary area. Common artifacts: white strips at clip edges, rendering order occlusion, font mismatch at source transitions.
- **Side-by-side comparison for consistency.** When multiple similar elements should match (e.g., x-axis labels across subplots, font weights across panels), generate a side-by-side strip of corresponding areas from different panels. Do not inspect them in isolation — inconsistencies are only visible in comparison.
- **Whitespace audit for every panel.** After placing each panel, calculate what fraction of the allocated area is occupied by actual data content (not margins/padding). If data occupies < 60% of the panel area, flag as excessive whitespace.

## Escalated Mode

Enter **escalated mode** if any of the following are true:

- the user asks for publication-quality signoff, perfection, or maximum rigor
- the figure is a multi-panel main or extended-data figure
- you previously overrated the figure or falsely claimed closure
- the user explicitly asks for an issue ledger, external cross-check, or repeated iteration

Escalated mode minimum process:

1. durable markdown issue ledger
2. sequential per-issue status tracking
3. durable iteration log
4. exact delivered PNG inspection after every rebuild
5. localized crop inspection for the changed defect area
6. external ensemble review before final closure

## Workflow

### 1. Baseline render and independent audit

Before any other step, create a high-res PNG from the current source, run spatial analysis, and independently identify all issues:

1. **Render the baseline PNG.** Convert the vector source (PDF, AI, etc.) to a high-res PNG (minimum 300 DPI) using the QC helper script. If the input is already a PNG, render a review-scale copy as well.
2. **Render 600 DPI regional crops.** Divide the figure into quadrants (or logical panel regions) and render each at 600 DPI. These high-density crops are essential for catching subtle spacing, typography, and alignment issues that are invisible in a full-page 300 DPI render.
   ```bash
   python3 scripts/qc_views.py render input.pdf crop_TL.png --dpi 600 --crop-frac 0.0,0.0,0.5,0.5
   python3 scripts/qc_views.py render input.pdf crop_TR.png --dpi 600 --crop-frac 0.5,0.0,1.0,0.5
   python3 scripts/qc_views.py render input.pdf crop_BL.png --dpi 600 --crop-frac 0.0,0.5,0.5,1.0
   python3 scripts/qc_views.py render input.pdf crop_BR.png --dpi 600 --crop-frac 0.5,0.5,1.0,1.0
   ```
3. **Run spatial analysis.** Use the `spatial` subcommand to programmatically measure margins, gutters, whitespace ratios, and element positions.
   ```bash
   python3 scripts/qc_views.py spatial input.pdf
   ```
   Review the JSON output for:
   - **Margin asymmetry** > 2pt (PDF) or > 1% (raster) — flag as spacing issue
   - **Gutter std_px** > 5px — flag as inconsistent panel spacing
   - **Quadrant whitespace** varying > 5% between quadrants — flag as unbalanced layout
   - **Overall whitespace** > 40% — flag as excessive white space
4. **Run font audit** (PDF sources). Use the `fonts` subcommand to extract every text span's font family, size, and weight.
   ```bash
   python3 scripts/qc_views.py fonts input.pdf
   ```
   Flag:
   - **> 2 font families** — likely inconsistency unless intentional (e.g., serif title + sans body)
   - **Near-duplicate sizes** differing by < 0.5pt — unintentional mismatch
   - **> 5 distinct sizes** — consider consolidating
5. **Render alignment guides overlay** (PDF sources). Use the `guides` subcommand to render the figure with red guide lines at every element edge.
   ```bash
   python3 scripts/qc_views.py guides input.pdf guides_overlay.png --dpi 300
   ```
   Inspect the overlay PNG for element edges that should be collinear but aren't.
6. **Visually inspect all renders** — the full 300 DPI PNG, every 600 DPI regional crop, and the guides overlay. Do not skip this step or defer it.
7. **Independently enumerate every publication-quality defect** you can see or measure — do not limit yourself to what the user reported. Combine visual inspection of the 600 DPI crops with the spatial analysis measurements, font audit warnings, and guides overlay. Systematically check against the issue taxonomy ([references/issue-taxonomy.md](references/issue-taxonomy.md)) and the sequential checklist ([references/sequential-checklist.md](references/sequential-checklist.md)). Common independently-caught issues include:
   - Typography: inconsistent fonts, sizes, weights across panels; aliased or rasterized text; missing or misaligned panel letters (use font audit output)
   - Spacing/layout: uneven gutters, misaligned axes, inconsistent margins, crowded or orphaned elements, excessive white space (use spatial analysis + guides overlay)
   - Data/legend: truncated labels, clipped data points, legend overlap, missing units
   - Export quality: rasterization artifacts, low-res embedded images, white-line seams, moire patterns
   - Color: inconsistent palettes across panels, poor contrast, non-colorblind-safe schemes
   - **Seam artifacts** (CRITICAL): At every boundary where content from different sources meets, generate a tight 600 DPI crop and inspect for white strips, rendering gaps, or misaligned content. These are the #1 missed defect class.
   - **Consistency comparison**: For every set of equivalent elements (e.g., x-axis labels across 4 subplot panels), generate a side-by-side strip and compare. Do NOT inspect them individually.
   - **Whitespace fill ratio**: For each panel, estimate what percentage of the allocated area is filled by actual data content. Flag any panel where data occupies < 60% of the area.
   - **Label rendering order**: Verify that all panel labels (a, b, c, ...) are rendered ON TOP of panel content, not behind it. Check by inspecting tight 600 DPI crops of each label.
8. **Merge with user-reported issues.** Combine your independently found issues with any user-reported defects into a single unified issue ledger.

### 2. Capture the issue ledger

- Include both user-reported defects AND independently identified defects from the baseline audit.
- Number the items; keep numbering stable across iterations.
- Tag each item as `[user-reported]` or `[independent]`.
- **Record a verification crop region for each issue** — the `--crop-frac` coordinates (left,top,right,bottom as 0-1 fractions) that isolate the area where the defect is visible. This crop region is the issue's "verification window" and will be used at closeout to confirm the fix. For whole-figure issues (e.g., overall whitespace), use `0.0,0.0,1.0,1.0`.
- **Generate and save a baseline crop PNG** for each issue at 600 DPI. Name it `baseline_issueN.png`.
  ```bash
  python3 scripts/qc_views.py render input.pdf baseline_issue3.png --dpi 600 --crop-frac 0.5,0.0,1.0,0.4
  ```
- Add likely regression checks from [references/issue-taxonomy.md](references/issue-taxonomy.md) (read it).
- Give each item status: `open`, `fixed pending visual check`, or `verified closed`.
- Write the ledger to a durable markdown file. Each entry must include: number, description, tag, crop-frac, baseline crop path, status.
- Example ledger entry format:
  ```
  | # | Issue | Tag | Crop region | Baseline crop | Status |
  |---|-------|-----|-------------|---------------|--------|
  | 1 | Panel B label misaligned 3pt left | [independent] | 0.45,0.0,0.75,0.15 | baseline_issue1.png | open |
  | 2 | Gutter between rows inconsistent | [independent] | 0.0,0.4,1.0,0.6 | baseline_issue2.png | open |
  ```
- In sweep mode, keep a numbered iteration log (change, intent, PNGs reviewed, rating, accepted/rejected).

### 3. Map the source chain

- Find the highest-fidelity live source for each panel: R/Python plot script, vector PDF, Illustrator/AI source, upstream data export.
- Decide the canonical vector deliverables (source pane PDFs, composite PDF, packet PDF).
- Decide the canonical raster deliverables (source pane PNGs, final composite PNG, crops).

### 4. Rebuild vector first

- Regenerate the source panes first whenever possible.
- Rebuild the composite from vector parts, not screenshots.
- Render PNGs only from the rebuilt live outputs.
- Respect dependency order: source pane rebuild, then dependent composite, then packet, then canonical delivered PNG.
- If the figure must remain editable, verify the PDF stayed vector with `pdfinfo`.

### 5. Generate QC views

Use `scripts/qc_views.py` for deterministic verification artifacts:

```bash
python3 scripts/qc_views.py render input.pdf output.png --dpi 300
python3 scripts/qc_views.py render input.pdf crop.png --dpi 600 --crop-frac 0.0,0.65,1.0,1.0
python3 scripts/qc_views.py spatial input.pdf
python3 scripts/qc_views.py fonts input.pdf
python3 scripts/qc_views.py guides input.pdf guides.png --dpi 300
python3 scripts/qc_views.py diff before.pdf after.pdf diff.png --dpi 300
python3 scripts/qc_views.py strip strip.png img1.png img2.png --orientation horizontal
```

Generate at minimum:

- Full composite PNG (300 DPI)
- 600 DPI regional crops for each panel or defect area
- Review-scale full composite PNG
- Source pane PNGs for changed panels
- Crop focused on the region where the user reported the defect
- Spatial analysis JSON for the rebuilt output
- Font audit JSON for the rebuilt output (PDF sources)
- Guides overlay PNG for the rebuilt output (PDF sources)
- **Before/after diff PNG** comparing the previous iteration to the current rebuild
- Optional side-by-side strips when comparing panes

### 6. Run the sequential visual check

Run the ordered checklist in [references/sequential-checklist.md](references/sequential-checklist.md). Do not skip directly to "looks fine overall." The sequence matters because many regressions are only obvious after the basic structural checks pass.

For typography, panel-letter, and layout issues, the acceptance call must be made from both:
- the canonical final delivered PNG
- a review-scale raster where undersized text would actually be obvious

Then force one adversarial whole-figure question:
- "If I had not made these edits myself, would I still reject this page for hierarchy, spacing, font inconsistency, or looking assembled rather than designed?"

If the honest answer is yes, keep iterating.

### 7. Iterate upstream

- Fix defects upstream and rebuild again.
- **After every rebuild, generate a before/after diff** comparing the previous render to the new one. Visually inspect the diff PNG to confirm intended changes landed and no regressions appeared elsewhere.
  ```bash
  python3 scripts/qc_views.py diff previous.png rebuilt.png diff.png
  ```
- If a fix introduces a new issue, add it to the ledger and keep iterating.
- Prefer multiple small rebuild/QC loops over a single large blind rebuild.
- In sweep mode, record each candidate with: parameter change, intended improvement, visual result, accepted/rejected.
- For persistent panel-letter defects, prefer a parameter sweep over generic anchor heuristics.

### 7b. Adversarial fresh-eyes inspection

**Purpose:** Defeat confirmation bias. After making fixes, you are biased toward believing they worked. A fresh session with no knowledge of your changes will catch defects you are blind to.

**When to run:** After EVERY rebuild cycle (not just at closeout).

**How to run:** Spawn an ephemeral one-shot session with ONLY the PNG path and a defect-hunting prompt. Do NOT tell it what was changed, what issues existed, or what to look for.

```bash
codex exec \
  --ephemeral \
  --sandbox read-only \
  --skip-git-repo-check \
  "You are a publication figure quality reviewer. You have NEVER seen this figure before and have NO context about its creation.

Inspect this PNG file: {final_png_path}

For EACH panel in the figure, check for and report:
1. WHITE STRIPS or SEAMS — any thin white lines/gaps that interrupt plot content
2. LABEL OCCLUSION — any panel letter that is partially covered, faded, or obscured
3. FONT/SPACING INCONSISTENCY — compare equivalent elements across panels
4. WHITESPACE — does each panel's data fill its allocated area? Estimate data fill percentage.
5. ALIGNMENT — are corresponding elements aligned across adjacent panels?
6. CLIPPING — are any data points, labels, or axis elements cut off?
7. RENDERING ARTIFACTS — any blurring, moire patterns, rasterization edges, or color banding?

Report EVERY defect with: exact location, severity (blocking/minor/cosmetic), suggested crop-frac region.
Be adversarial. Assume defects exist and search for them."
```

If `codex` is unavailable, use `claude -p --permission-mode plan` or `gemini -p --approval-mode plan` as alternatives.

**Gate rule:** If the subprocess finds ANY blocking or minor defect, add it to the issue ledger and return to step 7. Do not dismiss subprocess findings.

### 8. Final per-item visual verification

Before closeout, verify **every numbered item** in the issue ledger using the crop regions recorded in step 2. For **each** ledger item:

1. **Generate the final crop** at 600 DPI using the issue's recorded `crop-frac` from the final delivered PDF/PNG.
   ```bash
   python3 scripts/qc_views.py render final.pdf final_issue3.png --dpi 600 --crop-frac 0.5,0.0,1.0,0.4
   ```
2. **Generate a before/after comparison strip** placing the baseline crop next to the final crop.
   ```bash
   python3 scripts/qc_views.py strip compare_issue3.png baseline_issue3.png final_issue3.png --orientation horizontal
   ```
3. **Visually inspect the comparison strip.** The baseline (left) should show the defect; the final (right) should not.
4. **Record the verdict** in the ledger: `verified closed` (defect gone), `improved but open` (reduced but still visible), or `still open` (unchanged or regressed). Include the path to the comparison strip PNG as evidence.
5. For issues detectable by programmatic analysis (spatial, fonts), also re-run the relevant analysis on the final output and confirm the measurement is now within threshold.

**Gate rule:** If any item is not `verified closed`, return to step 7. Do not proceed to closeout.

After all items pass, also view the **full final PNG** at 300 DPI to check for any new issues introduced that were not in the original ledger. If new issues are found, add them to the ledger and return to step 7.

### 9. Report precisely

Closeout must name:

- the exact files rebuilt
- the exact PNGs you personally viewed, including the canonical final delivered PNG path
- the issue classes you explicitly checked
- any residual risk that remains
- the numeric publication-quality rating (N/10)
- the numbered issue ledger with final per-item status, including for each item:
  - the crop region used for verification
  - the path to the before/after comparison strip PNG
  - the explicit verdict from step 8
- the exact issues that remain if the rating is below `10/10`
- whether external ensemble review was used and what it added

Use direct language: "I viewed comparison strip compare_issue3.png (baseline left, final right) and confirmed the defect is no longer visible." Do not say `verified` if you only ran code or text extraction.

## References

- [references/sequential-checklist.md](references/sequential-checklist.md): ordered QC procedure
- [references/issue-taxonomy.md](references/issue-taxonomy.md): defect classes to check separately
- [scripts/qc_views.py](scripts/qc_views.py): render/crop/strip/spatial/fonts/guides/diff helper
