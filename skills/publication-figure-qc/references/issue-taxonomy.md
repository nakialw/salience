# Publication Figure Defect Taxonomy

Treat these as separate issue classes. Do not collapse them into a generic "looks off."

## Data And Content

- wrong subjects or groups included
- wrong time points or strata
- stale data export
- wrong panel count
- missing panel
- duplicated panel
- wrong legend/manuscript description

## Typography

- font too small
- font too large
- inconsistent relative font size across panels
- inconsistent relative font size within a panel
- one panel family reads typographically weaker than neighbors
- panel letters too small or too large
- title scale inconsistent with axis/annotation scale
- bold/regular style inconsistency

## Overlap And Crowding

- label-label overlap
- label-line overlap
- label-point overlap
- axis tick overlap
- title overlap
- panel-letter overlap
- annotation box collision
- crowding near margins

## Geometry And Layout

- excessive whitespace
- under-scaled plot region
- panel too dominant
- panel too weak relative to neighbors
- inconsistent panel sizing
- bad row/column balance
- poor alignment
- detached sub-blocks
- figure looks assembled rather than designed

## Clipping And Export

- clipped text
- clipped axis labels
- clipped points or lines
- clipped panel letters
- stale text behind current text
- stale panel letters bleeding through
- old art not fully removed
- low-resolution raster inside vector composite
- PDF no longer editable/vector when it should be

## Character Rendering

- broken minus signs
- broken Greek letters
- broken superscripts/subscripts
- malformed plus signs or slashes
- missing punctuation
- font fallback producing wrong glyphs
- OCR-looking or corrupted text after export

## Semantic Mismatch

- legend still mentions removed colors
- figure text still references superseded layout
- manuscript/rebuttal/cover letter out of sync with figure
- packet manifest/readme describes old content

## Review Discipline Failures

- verified from code only, not the image
- verified source pane but not final composite
- checked original defect but missed introduced regression
- looked only at the full figure and not the affected crop
- inspected a copied mirror but not the canonical delivered PNG path
- inspected a file before the producing process exited successfully
- rebuilt dependent outputs in parallel and verified a stale downstream result
- accepted a local panel fix without regrading the whole figure
- treated materially better as if it meant finished
