---
name: tap
description: >-
  Prompt-emphasis and self-review for marked critical spans. Use when the user
  marks words or phrases with [[double brackets]], says tap, upweight, don't
  neglect, make sure you nail X, invokes /tap, or clearly flags one portion of
  the prompt as the part that must not be missed. Iterates adversarial review on
  each tap target until treatment converges, then answers with a one-line footer.
  Automatically decomposes compound multi-clause or long taps into internal requirements.
---

# tap

`tap` fixes a specific failure mode: when a prompt has one phrase that *really* matters, a model often pattern-matches the overall request, name-drops the important phrase once, and moves on — neglecting the thing the user cared most about. `tap` forces deliberate, repeated, adversarial attention on the marked portion before the response is allowed to settle.

The mechanism is **iterate-to-convergence on the tapped portion**, not "repeat the phrase twice." The word/phrase may appear any number of times; what is mandated is that the model *reviews its own handling* of that portion at least twice, tries to break it, and only settles once successive passes reconcile.

This is an instruction-and-review discipline, not logit manipulation. It does not change token sampling; it allocates deliberate, skeptical attention. Do not claim otherwise.

## Step 1 — Identify the taps

Recognize taps from: `[[double brackets]]`; explicit "tap / upweight / don't neglect"; `/tap`; or clearly inferred critical spans. Optional: `<tap target="...">...</tap>`.

Extract **tap targets**. Brackets are markers, not text to echo. No taps and no emphasis signal → answer normally.

## Step 1b — Decompose compound taps (automatic)

Auto-run for compound taps (>~15 words, 2+ clauses, or multiple obligations). Skip for short single-obligation taps. Internal **R1…Rn** (3–7 checkable items); use in critique; do not print unless user asked. Opt-out: `tap-raw` / `no decompose`.

## Step 2 — Pass 1: draft

Answer the **whole** prompt. Engage each tap at **2+ distinct substantive points** (introduce → operationalize → stress-test/consequences).

Score each target (0–100, honest, not calibrated): **coverage** and **fidelity**.

## Step 3 — Pass 2+: adversarial review

Per target: (a) factored check — requirements per **Ri** if decomposed; (b) red-team — cite **Ri** in objections; (c) reconcile. Anti-sycophancy: verify the draft satisfies the tap, not that the user was right. Verifiable taps → use checks/tools when available. Repo path cited → **Read** file before Pass 1 claims about contents.

Minimum **2** review passes beyond draft; **cap 4** per target. Attack even high Pass-1 scores.

## Step 4 — Convergence

Converged when substantive change is negligible and both scores plateau (Δ ≤ 5 for two passes). Stop on oscillation with `(settled — oscillation)`. Per-target stopping.

## Step 5 — Output (user-visible)

Adversarial work is **internal only**. Structure: answer body → (if `/immune`) `— immune · N auto (M manual)` → `— tap · …` on **separate plain-text lines**.

**Forbidden:** pass logs, objection blocks, "drafting under tap", `R1…Rn` in body, merged footers, bold footers.

One tap footer line: `— tap · "<phrase>": <n> passes, coverage <c1>→…; fidelity <f1>→… (converged)`. Multiple targets: `; ` separated. See codex `SKILL.md` for full spec.

## Resources

- `references/sources.md` — literature lineage
