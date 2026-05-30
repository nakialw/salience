# immune — examples and validation prompts

## Example 1 — No immuno gate

**Prompt:** `Summarize the column naming scheme in this CSV export.`

- **Gate:** fail (no glossary match)
- **Behavior:** Normal answer; `— immune · 0 auto (0 manual) (no immuno gate)`; no `tap` loop

---

## Example 2 — Manual tap only

**Prompt:** `Give a one-paragraph overview of [[T cells]].`

- **Gate:** pass
- **Auto-tap:** none or skip (single generic cell term, low interactivity)
- **Behavior:** `tap` on manual span only; `— immune · 0 auto (1 manual)` + tap footer

---

## Example 3 — Compound immuno prompt (full pipeline)

**Prompt:**

```text
Explain whether post-infusion CD8 cytotoxic programming explains responder outcomes
in huCART19-IL18, and how IFNg-myeloid spatial gradients relate to IL-18 armoring
versus CAR backbone effects.
```

**Expected auto-taps (illustrative, scores ~4–5):**

- `[[post-infusion CD8 cytotoxic programming]]` — interactivity + decomposability + density
- `[[responder outcomes]]` — trial + verifiability if data cited
- `[[IFNg-myeloid spatial gradients]]` — spatial + interactivity + density
- `[[IL-18 armoring versus CAR backbone effects]]` — comparative + decomposability

**Auto-tapped line (before answer):**

`Auto-tapped (immune): "post-infusion CD8 cytotoxic programming"; "IFNg-myeloid spatial gradients"; "IL-18 armoring versus CAR backbone effects" (scores: 5, 5, 5)`

Then full `tap` → final answer + `— immune · 3 auto (0 manual)` + tap footer on separate line.

---

## Example 4 — Schema/admin bypass

**Prompt:** `List the columns in submission/working/cosmx/commot/results/.../TAC_communication_pvalue.csv and what each column means statistically.`

- **Gate:** schema/admin bypass (column listing + statistical meaning; cell-type names are metadata only)
- **Auto-tap:** at most 1–2 spans on file/statistical claims — **not** bare `T_CD8`, `B_cell`, etc.
- **Behavior:** `Auto-tapped (immune): …` line 1; optional light tap; separate footers

**Prompt:** `What is the recommended git workflow in this repository for adding a new analysis module?`

- **Gate:** fail (no immuno context)
- **Behavior:** Normal answer; `— immune · 0 auto (0 manual) (no immuno gate)`; no tap

---

## Manual validation (post-install)

Run `./install.sh` from the repo root, then in Claude Code or Codex:

| # | Prompt | Expected |
|---|--------|----------|
| 1 | CSV column naming (Example 1) | No tap loop |
| 2 | `Explain [[T cells]]` (Example 2) | Manual tap only; minimal auto-tap |
| 3 | Example 3 compound prompt | 3–6 auto-taps shown; separate footers |
| 4 | Example 4 git workflow | No tap loop |
| 5 | Example 4 COMMOT columns | Bypass or ≤2 verifiability spans; no cell-header auto-taps |

Record false positives (over-tapped) and false negatives (missed compound phrases) to tune glossary and thresholds in [span-selection.md](span-selection.md).
