# Sequential Publication Figure QC Checklist

Run these checks in order. Do not skip ahead.

## 1. Issue Ledger Freeze

- List every user-reported defect verbatim.
- Number each issue and keep the numbering stable through the final report.
- Add likely regressions from [issue-taxonomy.md](issue-taxonomy.md).
- Mark each issue as `open`, `fixed pending visual check`, or `verified closed`.

## 2. Source Integrity Check

- Confirm the intended source panel count and panel identities.
- Confirm the current source files are the correct live files, not stale alternates.
- Confirm any updated data grouping or subject assignment actually flows into the source plots.
- Confirm the build path is vector-first where feasible.
- Confirm rebuild ordering is valid:
  - upstream pane rebuilds finished successfully
  - dependent composite rebuilds started only after upstream completion
  - packet rebuild or sync happened only after canonical rebuilds were done

## 3. Source Pane Render Check

For each changed panel:

- render the source PDF to PNG
- inspect the full pane
- inspect a crop around the originally reported defect if needed

Checks:

- correct panel content
- correct panel count
- correct plotted groups/subjects
- correct axes, titles, legends, guides, thresholds
- correct panel letters if the pane contains them
- no stale bleed-through from prior art

## 4. Typography Check

Check each of these separately:

- absolute font size is readable at figure scale
- absolute font size is readable at review scale in a downscaled final PNG, not just at full-resolution zoom
- relative font size is consistent across panel titles, axis titles, axis ticks, labels, legends, annotations, and panel letters
- panel letters are sized consistently across the figure
- font weight/style is consistent with neighboring panels
- no unexpectedly tiny or oversized text blocks remain
- panel-letter vertical alignment is visually consistent with nearby title baselines when adjacent panels come from different source PDFs

## 5. Collision Check

Check each of these separately:

- text-text overlap
- label-label overlap
- label-line overlap
- label-point overlap that makes labels unreadable
- axis-tick overlap
- title-label overlap
- panel-letter overlap
- guide-line overlap with labels that causes ambiguity

## 6. Geometry And Spacing Check

Check each of these separately:

- excessive whitespace
- under-scaled panel footprint
- inconsistent panel widths/heights
- poor row/column balance
- misaligned panel tops/baselines
- crowding near page edges
- unintentionally floating panels or detached sub-blocks
- figure still looks assembled rather than designed
- one panel family still visually dominates or disappears at page level

## 7. Clipping And Rendering Check

Check each of these separately:

- clipped text
- clipped points/lines
- cropped tick labels
- cropped panel letters
- incorrectly rendered characters
- missing minus signs
- broken Greek letters or superscripts
- bad hyphen/en dash/minus substitution
- text or symbols silently dropped during export
- rasterized or blurry panels where vector output was expected

## 8. Semantic Concordance Check

- legend matches the current visual encoding
- no stale references to removed colors, guides, or panel structures
- manuscript/rebuttal/cover-letter text still describes the figure correctly if figure meaning changed
- packet manifests/readmes do not describe superseded outputs

## 9. Composite Check

- inspect the rebuilt full composite PNG
- inspect a review-scale full PNG where undersized text or weak panel letters would be obvious
- inspect a crop around the changed panel(s)
- inspect the crop from the exact final delivered PNG after the last rebuild, not an earlier QC render
- inspect any area that previously had stray text, stale letters, bleed-through, or clipping
- reject the figure if a locally fixed panel still leaves the page globally unbalanced
- reject the figure if you only verified a copied mirror and did not inspect the canonical delivered PNG path after the rebuild completed

Only close an issue here if it is visibly gone in the final composite PNG.

## 10. Delivery Check

- packet PDF matches the canonical figure
- packet contents include required separate components if requested
- temporary debug artifacts are excluded unless intentionally kept
- final reported outputs are the files the user will actually open

## 11. Final Verification Statement

Before closing, explicitly state:

- which PNGs you viewed
- that the listed PNGs came from the final rebuild iteration
- that dependent rebuilds were run in the correct order
- whether you used sweep mode and, if so, how many labeled iterations were compared
- the numbered issue ledger and the final status of each numbered item
- which issue classes you checked
- that you checked both original defects and newly introduced defects
- any residual risks
