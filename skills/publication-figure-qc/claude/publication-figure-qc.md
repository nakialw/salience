---
argument-hint: <figure path or description of figure QC task>
---

Run publication-quality figure QC on:

$ARGUMENTS

## Instructions

You are performing vector-first publication figure verification. The core rule: rebuild from vector sources, then explicitly view every PNG output at every stage. Do not claim a figure is fixed until you have personally viewed the rebuilt PNG.

Claude Code can read images natively — use the Read tool on PNG files to visually inspect them. This is your primary verification mechanism.

### Hard Rules

- Do not claim a figure is fixed until you have viewed the rebuilt PNG output with the Read tool.
- Verify the final composite PNG, not just individual source panes.
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
- **10/10 is the required outcome.** Keep iterating until 10/10 is reached, no matter how many loops are required. The only acceptable reason to stop below 10/10 is an extreme blocker such as missing raw data that cannot be regenerated. Needing to search for source code, regenerate a figure in R/Python, rebuild a composite, or run additional sweep iterations are NOT blockers — they are expected parts of the process.
- **Every issue requires a verification crop region.** When an issue is added to the ledger, record the `crop-frac` coordinates that isolate the defect area. At closeout, every issue must have a before/after comparison strip generated from these coordinates. An issue cannot be marked `verified closed` without a viewed comparison strip showing the defect is gone.
- **Adversarial fresh-eyes inspection is MANDATORY before any closeout.** After all fixes, spawn a separate Agent subprocess (subagent_type="general-purpose") to inspect the final delivered PNG. The subprocess has NO context about what was changed or what issues existed — it receives ONLY the PNG path and instructions to find every defect. If the subprocess finds issues you missed, add them to the ledger and fix them. This catches confirmation bias where you assume your fix worked without truly seeing the result. See the "Adversarial Fresh-Eyes Inspection" section below.
- **Never verify by coordinate math alone.** If you calculate that a label "should be visible" based on x/y positions, you MUST ALSO visually confirm it by reading a tight 600 DPI crop of that exact area. Coordinate math tells you what SHOULD happen; visual inspection tells you what DID happen.
- **Seam/boundary crops are mandatory.** Whenever content from different sources is composited (repair overlays, clip boundaries, multi-source assembly), generate a 600 DPI crop of every seam/boundary area. Common artifacts: white strips at clip edges, rendering order occlusion, font mismatch at source transitions.
- **Side-by-side comparison for consistency.** When multiple similar elements should match (e.g., x-axis labels across subplots, font weights across panels), generate a side-by-side strip of corresponding areas from different panels. Do not inspect them in isolation — inconsistencies are only visible in comparison.
- **Whitespace audit for every panel.** After placing each panel, calculate what fraction of the allocated area is occupied by actual data content (not margins/padding). If data occupies < 60% of the panel area, flag as excessive whitespace.

### Escalated Mode

Enter escalated mode if any of these are true:
- The user asks for publication-quality signoff, perfection, or maximum rigor
- The figure is a multi-panel main or extended-data figure
- You previously overrated the figure or falsely claimed closure
- The user explicitly asks for an issue ledger, external cross-check, or repeated iteration

Escalated mode minimum process:
1. Durable markdown issue ledger
2. Sequential per-issue status tracking
3. Durable iteration log
4. Exact delivered PNG inspection after every rebuild
5. Localized crop inspection for the changed defect area
6. External ensemble review before final closure (use `/ensemble` with dissent-first posture)

### Workflow

#### 1. Baseline render and independent audit

Before any other step, create a high-res PNG from the current source, run spatial analysis, and independently identify all issues:

1. **Render the baseline PNG.** Convert the vector source (PDF, AI, etc.) to a high-res PNG (minimum 300 DPI) using the QC helper script. If the input is already a PNG, render a review-scale copy as well.
2. **Render 600 DPI regional crops.** Divide the figure into quadrants (or logical panel regions) and render each at 600 DPI. These high-density crops are essential for catching subtle spacing, typography, and alignment issues that are invisible in a full-page 300 DPI render.
   ```bash
   # Example: four quadrant crops at 600 DPI
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py render input.pdf crop_TL.png --dpi 600 --crop-frac 0.0,0.0,0.5,0.5
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py render input.pdf crop_TR.png --dpi 600 --crop-frac 0.5,0.0,1.0,0.5
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py render input.pdf crop_BL.png --dpi 600 --crop-frac 0.0,0.5,0.5,1.0
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py render input.pdf crop_BR.png --dpi 600 --crop-frac 0.5,0.5,1.0,1.0
   ```
3. **Run spatial analysis.** Use the `spatial` subcommand to programmatically measure margins, gutters, whitespace ratios, and element positions. This catches issues that are hard to see but easy to measure (e.g., 3pt margin asymmetry, inconsistent gutter widths, excessive quadrant whitespace).
   ```bash
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py spatial input.pdf
   ```
   Review the JSON output for:
   - **Margin asymmetry** > 2pt (PDF) or > 1% (raster) — flag as spacing issue
   - **Gutter std_px** > 5px — flag as inconsistent panel spacing
   - **Quadrant whitespace** varying > 5% between quadrants — flag as unbalanced layout
   - **Overall whitespace** > 40% — flag as excessive white space
4. **Run font audit** (PDF sources). Use the `fonts` subcommand to extract every text span's font family, size, and weight. This catches mixed font families, near-duplicate sizes (e.g., 7.5pt vs 8pt), and inconsistent weights that are invisible at review scale.
   ```bash
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py fonts input.pdf
   ```
   Flag:
   - **> 2 font families** — likely inconsistency unless intentional (e.g., serif title + sans body)
   - **Near-duplicate sizes** differing by < 0.5pt — unintentional mismatch
   - **> 5 distinct sizes** — consider consolidating
5. **Render alignment guides overlay** (PDF sources). Use the `guides` subcommand to render the figure with red guide lines at every element edge. This makes subtle misalignment (2–3pt) visually obvious.
   ```bash
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py guides input.pdf guides_overlay.png --dpi 300
   ```
   Inspect the overlay PNG for element edges that should be collinear but aren't.
6. **Visually inspect all renders** using the Read tool — the full 300 DPI PNG, every 600 DPI regional crop, and the guides overlay. Do not skip this step or defer it.
7. **Independently enumerate every publication-quality defect** you can see or measure — do not limit yourself to what the user reported. Combine visual inspection of the 600 DPI crops with the spatial analysis measurements, font audit warnings, and guides overlay. Systematically check against the issue taxonomy (`~/.claude/commands/references/publication-figure-qc/issue-taxonomy.md`) and the sequential checklist (`~/.claude/commands/references/publication-figure-qc/sequential-checklist.md`). Common independently-caught issues include:
   - Typography: inconsistent fonts, sizes, weights across panels; aliased or rasterized text; missing or misaligned panel letters (use font audit output)
   - Spacing/layout: uneven gutters, misaligned axes, inconsistent margins, crowded or orphaned elements, excessive white space (use spatial analysis + guides overlay)
   - Data/legend: truncated labels, clipped data points, legend overlap, missing units
   - Export quality: rasterization artifacts, low-res embedded images, white-line seams, moire patterns
   - Color: inconsistent palettes across panels, poor contrast, non-colorblind-safe schemes
   - **Seam artifacts** (CRITICAL): At every boundary where content from different sources meets (repair overlays, clip edges, multi-source composites), generate a tight 600 DPI crop and inspect for white strips, rendering gaps, or misaligned content. These are the #1 missed defect class.
   - **Consistency comparison**: For every set of equivalent elements (e.g., x-axis labels across 4 subplot panels), generate a side-by-side strip and compare. Do NOT inspect them individually — inconsistencies in font weight, spacing, and sizing are ONLY visible in direct comparison.
   - **Whitespace fill ratio**: For each panel, estimate what percentage of the allocated area is filled by actual data content. Flag any panel where data occupies < 60% of the area.
   - **Label rendering order**: Verify that all panel labels (a, b, c, ...) are rendered ON TOP of panel content, not behind it. Check by inspecting tight 600 DPI crops of each label — if any part of the letter appears faded, blurred, or cut off, the label is being occluded by panel content drawn after it.
8. **Merge with user-reported issues.** Combine your independently found issues with any user-reported defects into a single unified issue ledger. Flag which issues were user-reported vs. independently identified.

#### 2. Capture the issue ledger

- Include both user-reported defects AND independently identified defects from the baseline audit.
- Number the items; keep numbering stable across iterations.
- Tag each item as `[user-reported]` or `[independent]`.
- **Record a verification crop region for each issue** — the `--crop-frac` coordinates (left,top,right,bottom as 0–1 fractions) that isolate the area where the defect is visible. This crop region is the issue's "verification window" and will be used at closeout to confirm the fix. For whole-figure issues (e.g., overall whitespace), use `0.0,0.0,1.0,1.0`.
- **Generate and save a baseline crop PNG** for each issue at 600 DPI. Name it `baseline_issueN.png`. These baseline crops are the "before" reference for closeout comparison.
  ```bash
  # Example: issue #3 is in the top-right area
  python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py render input.pdf baseline_issue3.png --dpi 600 --crop-frac 0.5,0.0,1.0,0.4
  ```
- Add likely regression checks from `~/.claude/commands/references/publication-figure-qc/issue-taxonomy.md` (read it).
- Give each item status: `open`, `fixed pending visual check`, or `verified closed`.
- Write the ledger to a durable markdown file. Each entry must include: number, description, tag, crop-frac, baseline crop path, status.
- Example ledger entry format:
  ```
  | # | Issue | Tag | Crop region | Baseline crop | Status |
  |---|-------|-----|-------------|---------------|--------|
  | 1 | Panel B label misaligned 3pt left | [independent] | 0.45,0.0,0.75,0.15 | baseline_issue1.png | open |
  | 2 | Gutter between rows inconsistent (12px vs 18px) | [independent] | 0.0,0.4,1.0,0.6 | baseline_issue2.png | open |
  ```
- In sweep mode, keep a numbered iteration log (change, intent, PNGs reviewed, rating, accepted/rejected).

#### 3. Map the source chain

Find the highest-fidelity live source for each panel:
- R/Python plot script
- vector PDF
- Illustrator/AI source
- upstream data export

Decide canonical deliverables (source pane PDFs, composite PDF, packet PDF, QC PNGs).

#### 4. Rebuild vector first

- Regenerate source panes first whenever possible.
- Rebuild composite from vector parts, not screenshots.
- Render PNGs only from rebuilt live outputs.
- Respect dependency order: source pane → composite → packet → delivered PNG.
- If figure must stay editable, verify PDF stayed vector with `pdfinfo`.

#### 5. Generate QC views

Use the QC helper script for deterministic verification artifacts:

```bash
python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py render input.pdf output.png --dpi 300
python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py render input.pdf crop.png --dpi 600 --crop-frac 0.0,0.65,1.0,1.0
python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py spatial input.pdf
python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py fonts input.pdf
python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py guides input.pdf guides.png --dpi 300
python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py diff before.pdf after.pdf diff.png --dpi 300
python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py strip strip.png img1.png img2.png --orientation horizontal
```

Note: requires `pymupdf`, `pillow`, and `numpy` (`pip install pymupdf pillow numpy`).

Generate at minimum:
- Full composite PNG (300 DPI)
- 600 DPI regional crops for each panel or defect area
- Review-scale full composite PNG
- Source pane PNGs for changed panels
- Crop focused on the region where the user reported the defect
- Spatial analysis JSON for the rebuilt output
- Font audit JSON for the rebuilt output (PDF sources)
- Guides overlay PNG for the rebuilt output (PDF sources)
- **Before/after diff PNG** comparing the previous iteration to the current rebuild — inspect this to catch regressions
- Optional side-by-side strips when comparing panes

Then use the Read tool to visually inspect each generated PNG.

#### 6. Run the sequential visual check

Read `~/.claude/commands/references/publication-figure-qc/sequential-checklist.md` and run the ordered checklist. Do not skip directly to "looks fine overall." The sequence matters because many regressions are only obvious after basic structural checks pass.

For typography, panel-letter, and layout issues, accept from both:
- The canonical final delivered PNG
- A review-scale raster where undersized text would be obvious

Then force one adversarial whole-figure question:
- "If I had not made these edits myself, would I still reject this page for hierarchy, spacing, font inconsistency, or looking assembled rather than designed?"

If yes, keep iterating.

#### 7. Iterate upstream

- Fix defects upstream and rebuild again.
- **After every rebuild, generate a before/after diff** comparing the previous render to the new one. Visually inspect the diff PNG to confirm intended changes landed and no regressions appeared elsewhere.
  ```bash
  python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py diff previous.png rebuilt.png diff.png
  ```
- If a fix introduces a new issue, add it to the ledger and keep iterating.
- Prefer multiple small rebuild/QC loops over a single large blind rebuild.
- In sweep mode, record each candidate with: parameter change, intended improvement, visual result, accepted/rejected.
- For persistent panel-letter defects, prefer a parameter sweep over generic anchor heuristics.

#### 7b. Adversarial Fresh-Eyes Inspection

**Purpose:** Defeat confirmation bias. After making fixes, you are biased toward believing they worked. A fresh subprocess with no knowledge of your changes will catch defects you're blind to.

**When to run:** After EVERY rebuild cycle (not just at closeout). This is the single most important step for catching the class of defects documented in the QC blindspots memory (white strip artifacts, label occlusion, whitespace issues).

**How to run:** Spawn a general-purpose Agent with ONLY the PNG path and a defect-hunting prompt. Do NOT tell it what was changed, what issues existed, or what to look for. It must find issues independently.

```
Agent(
    subagent_type="general-purpose",
    description="Adversarial figure inspection",
    prompt="""You are a publication figure quality reviewer. You have NEVER seen this figure before and have NO context about its creation.

Inspect this PNG file: {final_png_path}

Read the image with the Read tool at the path above. Then generate and read 600 DPI crops of EVERY panel boundary, label area, and axis region.

For EACH panel in the figure, check for and report:
1. WHITE STRIPS or SEAMS — any thin white lines/gaps that interrupt plot content, especially near panel boundaries, axis areas, or where different sources meet
2. LABEL OCCLUSION — any panel letter (a, b, c, d, e) that is partially covered, faded, or obscured by plot background
3. FONT/SPACING INCONSISTENCY — compare equivalent elements across panels (axis labels, tick marks, titles). Are font sizes, weights, and line spacing consistent?
4. WHITESPACE — does each panel's data fill its allocated area, or is it swimming in empty space? Estimate data fill percentage.
5. ALIGNMENT — are corresponding elements (axes, labels, tick marks) aligned across adjacent panels?
6. CLIPPING — are any data points, labels, or axis elements cut off at panel edges?
7. RENDERING ARTIFACTS — any blurring, moire patterns, rasterization edges, or color banding?

Report EVERY defect you find, with:
- Exact location (panel letter + position description)
- Severity (blocking / minor / cosmetic)
- A suggested crop-frac region to isolate it

Be adversarial. Assume defects exist and search for them. Do not say "looks good" unless you have examined every panel at 600 DPI."""
)
```

**Gate rule:** If the subprocess finds ANY blocking or minor defect, add it to the issue ledger and return to step 7 (Iterate upstream). Do not dismiss subprocess findings.

#### 8. Final per-item visual verification

Before closeout, verify **every numbered item** in the issue ledger using the crop regions recorded in step 2. This step is mandatory and cannot be skipped or summarized. For **each** ledger item:

1. **Generate the final crop** at 600 DPI using the issue's recorded `crop-frac` from the final delivered PDF/PNG.
   ```bash
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py render final.pdf final_issue3.png --dpi 600 --crop-frac 0.5,0.0,1.0,0.4
   ```
2. **Generate a before/after comparison strip** placing the baseline crop (from step 2) next to the final crop.
   ```bash
   python3 ~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py strip compare_issue3.png baseline_issue3.png final_issue3.png --orientation horizontal
   ```
3. **Visually inspect the comparison strip** with the Read tool. The baseline (left) should show the defect; the final (right) should not.
4. **Record the verdict** in the ledger: `verified closed` (defect gone), `improved but open` (reduced but still visible), or `still open` (unchanged or regressed). Include the path to the comparison strip PNG as evidence.
5. For issues detectable by programmatic analysis (spatial, fonts), **also re-run the relevant analysis** on the final output and confirm the measurement is now within threshold.

**Gate rule:** If any item is not `verified closed`, return to step 7 (Iterate upstream). Do not proceed to closeout. No exceptions.

After all items pass, also view the **full final PNG** at 300 DPI to check for any new issues introduced that were not in the original ledger. If new issues are found, add them to the ledger and return to step 7.

#### 9. Report precisely

Closeout must name:
- The exact files rebuilt
- The exact PNGs you viewed (with paths)
- The issue classes you explicitly checked
- Any residual risk
- The numeric publication-quality rating (N/10)
- The numbered issue ledger with final per-item status, including for each item:
  - The crop region used for verification
  - The path to the before/after comparison strip PNG
  - The explicit verdict from step 8
- The exact issues remaining if below 10/10
- Whether external ensemble review was used and what it added

Use direct language: "I viewed comparison strip compare_issue3.png (baseline left, final right) and confirmed the defect is no longer visible." Do not say "verified" if you only ran code or text extraction.

### Resources

- `~/.claude/commands/references/publication-figure-qc/issue-taxonomy.md`: defect classes to check separately
- `~/.claude/commands/references/publication-figure-qc/sequential-checklist.md`: ordered QC procedure
- `~/.claude/commands/references/publication-figure-qc/scripts/qc_views.py`: render/crop/strip/spatial/fonts/guides/diff helper
