---
name: tap
description: >-
  Prompt-emphasis and self-review for marked critical spans. Use when the user
  marks words or phrases with [[double brackets]], says tap, upweight, don't
  neglect, make sure you nail X, invokes /tap, or clearly flags one portion of
  the prompt as the part that must not be missed. Iterates adversarial review on
  each tap target until treatment converges, then answers with a one-line footer.
  Automatically decomposes compound multi-clause or long taps into internal requirements.
metadata:
  short-description: Emphasize and adversarially review tapped prompt spans
---

# tap

`tap` fixes a specific failure mode: when a prompt has one phrase that *really* matters, a model often pattern-matches the overall request, name-drops the important phrase once, and moves on — neglecting the thing the user cared most about. `tap` forces deliberate, repeated, adversarial attention on the marked portion before the response is allowed to settle.

The mechanism is **iterate-to-convergence on the tapped portion**, not "repeat the phrase twice." The word/phrase may appear any number of times; what is mandated is that the model *reviews its own handling* of that portion at least twice, tries to break it, and only settles once successive passes reconcile.

This is an instruction-and-review discipline, not logit manipulation. It does not change token sampling; it allocates deliberate, skeptical attention. Do not claim otherwise.

Input-side techniques (prompt repetition, attention steering, XML tags) may complement `tap` but do not replace output-side critique. Intrinsic self-correction is unreliable for reasoning and facts without external checks — see [references/sources.md](references/sources.md).

## Step 1 — Identify the taps

A "tap" is a marked span the user wants upweighted. Recognize taps from any of these:

- `[[double brackets]]` around a word or phrase — the primary syntax.
- An explicit instruction: "tap: X", "upweight 'X'", "don't neglect X", "the key part is X".
- `/tap` followed by the prompt with marked spans.
- Optional markup: `<tap target="phrase">...</tap>` (especially for long prompts).

Extract each tapped span into a **tap target** list. In your working copy of the prompt, read the bracketed text as normal prompt content — the brackets are markers, not literal text to echo back. If nothing is explicitly marked but the user clearly signals one portion is critical, treat that portion as a single tap target and note that you inferred it.

**Note:** IFEval uses `[[title]]` as an *output* format constraint. `[[...]]` in `tap` marks *input emphasis* — do not confuse the two.

If there are no taps and no signal of emphasis, this skill does not apply — answer normally.

**Auto-taps from `immune`:** Spans bracketed by the [`immune`](../immune/codex/SKILL.md) lens are first-class tap targets — same Steps 1b–5. `immune` does not supply critique themes; adversarial review stays **span-anchored** (draft sentence + tap text only).

## Step 1b — Decompose compound taps (automatic)

**Runs automatically** for any tap that is compound. The user does not need to say "decompose" or use a special flag.

**Decompose when any of these hold:**

- More than ~15 words, or
- Two or more clauses (e.g. joined by "and", "but", "without", "while", semicolons), or
- Multiple distinct obligations (format + content + audience + edge case, list items, etc.)

**Skip decomposition** for short, single-obligation taps (e.g. `[[zero-downtime]]`, `[[backward-compatible]]`).

For each compound tap, before Pass 1, derive **3–7 atomic requirements** `R1…Rn` (internal only):

- Each `Ri` is **one** checkable obligation — not a theme.
- Split conjunctions ("and", lists) into separate `Ri` values; do not collapse into one vague item.
- Each `Ri` must be answerable by pointing to a specific part of the final response.

Use `R1…Rn` in factored check and red-team for that tap. **Coverage** for a decomposed tap: every `Ri` has substantive treatment somewhere in the answer (the tap as a whole still needs **2+ distinct engagement points** overall, not 2+ per `Ri`). **Fidelity**: no `Ri` was satisfied only by an easier substitute.

Do **not** print the decomposition in the user-facing answer unless they asked for an outline or checklist.

**Opt-out (rare):** If the user says `tap-raw` or `no decompose` on a specific span, treat that tap as atomic (no `Ri` list).

## Step 2 — Pass 1: draft

Answer the **whole** prompt, not just the tapped parts — taps upweight, they don't narrow the task. While drafting, deliberately engage each tap target **substantively at 2+ distinct points** of the response (the coverage standard): not one throwaway mention, but genuine, distinct engagement — e.g., once where it's introduced and again where it's applied, tested, or its consequences are worked out.

Operational coverage slots (use what fits): **introduce → operationalize → stress-test or consequences**. In adversarial review, name any empty slot.

For each tap target, record internal scores (0–100, honest self-ratings, not calibrated probabilities):

- **coverage** — substantive engagement at 2+ distinct points?
- **fidelity** — does treatment match what the phrase actually demands (not an adjacent easier question)?

## Step 3 — Pass 2+: adversarial review and reconcile

This is the core of the skill. For **each** tap target:

### 3a — Factored check (before re-reading the draft charitably)

Without the full draft in mind, answer:

1. What does this phrase **require** (constraints, audience, format, edge cases)? If decomposed, work through **each `Ri`**.
2. What would **clearly violate** it (or any `Ri`)?
3. If **verifiable** (counts, format, keywords, booleans — IFEval-style), what checks would pass/fail per `Ri` where applicable?

### 3b — Red-team the draft

Do not re-read charitably. Attack as a critic trying to prove you neglected the phrase:

- Did I address what this phrase actually *demands*, or an adjacent, easier question?
- Is it engaged substantively at 2+ distinct points, or name-dropped once?
- Is there a more correct, complete, or stronger treatment I skipped because the first one came easily?
- Did I quietly drop a constraint the phrase implies?
- **Anti-sycophancy:** The critic verifies whether the *draft satisfies the tap*, not whether the user was right to emphasize it.

Surface at least one **concrete** adversarial objection per tap target per review pass (cite **`Ri`** when decomposed, e.g. "R3: cutover is still big-bang"), then **reconcile**: revise the response to answer the objection. Re-score coverage and fidelity after revising.

**Verifiable taps:** When checks exist (code, tests, retrieval, tools), run them — do not rely on introspection alone (CRITIC/CoVe-style). If the prompt cites a **repo path** (`submission/…`, concrete filename), **Read** the file before Pass 1 claims about its contents. Say in the footer if verification was intrinsic only: `(verified: path)` or `(intrinsic only — file not read)`.

The adversarial step matters most when Pass 1 *already looks fine* — that is exactly when models stop being careful. High Pass-1 scores still get a genuine attempt to break.

## Step 4 — Convergence test (when to stop)

After each review pass, compare this pass's treatment of each tap target against the previous pass:

- **Materially different** (real substantive revision; scores moved a lot): not converged — run another pass.
- **Negligible change** (no substantive edit; only cosmetic tweaks) **and** both coverage and fidelity are high or plateaued (Δ ≤ 5 each across two consecutive passes): **converged.** Settle.
- **Oscillation** (scores or substance swing without net gain): stop with `(settled — oscillation)` and keep the highest-confidence version.

Convergence — successive passes *reconciling* and stabilizing — is the desired outcome. Perpetual change is thrashing, not thoroughness.

Rules:

- **Minimum 2 review passes** beyond the initial draft, even if Pass 1 looked perfect — the review is the point.
- **Cap at 4 passes total** per tap target. If not converged by the cap, settle on the **highest-confidence** version and flag `(settled at cap — best of N)`.
- Run passes per tap target; targets may converge at different times. Stop a target once it converges; continue on the rest.

## Step 5 — Output and report (user-visible)

All adversarial work (drafts, passes, `R1…Rn`, scores, objections) is **internal only**.

**Required structure:**

1. If chained from `/immune`: `Auto-tapped (immune): …` is already line 1 — do not repeat.
2. **Answer body** — prose only (no `[[markers]]`, no inline scaffolding).
3. If from `/immune`: `— immune · N auto (M manual)` on its **own line** (plain text, no bold).
4. `— tap · …` on its **own line** (plain text, one line).

**FORBIDDEN in user-visible output:**

- "Tap pass N", "Draft →", "Adversarial pass log", "objections:", "Now drafting under tap…"
- Internal `R1…Rn` lists or coverage/fidelity narration in the body
- Merging immune + tap into one footer line
- Bold/markdown on footer lines (`**— tap ·**`)
- Echoing `[[...]]` bracket syntax in the answer body (tap phrases appear as plain prose)

**Tap footer** (one line):

```
— tap · "<phrase>": <n> passes, coverage <c1>→…→<cf>; fidelity <f1>→…→<ff> (converged)
```

For multiple targets, separate with `; `. Mark unconverged targets with `(settled at cap — best of N)` or `(settled — oscillation)` instead of `(converged)`.

For **decomposed** taps, you may append requirement coverage when helpful: `(5/5 requirements)` or `(settled at cap; R4 unresolved)` — keep on the same footer line.

**Example footer:**

```
— tap · "backward-compatible": 3 passes, coverage 65→80→88; fidelity 70→85→88 (converged); "error budget": 2 passes, coverage 90→92; fidelity 88→92 (converged)
```

Keep the footer to one line. It reports cycles to convergence and score trajectories — nothing else.

## Worked examples

### Short tap (no decomposition)

**Prompt:** `Write a migration plan to move our auth service to OAuth, and make it [[zero-downtime]].`

- **Taps:** `zero-downtime` — single obligation → **Step 1b skipped**.
- **Pass 1:** Full migration plan. Mention zero-downtime in rollout. Coverage 70, fidelity 70 — named, but is it *engineered* in?
- **Pass 2 (adversarial):** "Cutover flips all traffic at once — that's a downtime window. No in-flight sessions." Reconcile: dual-running, token bridge, gradual shift with rollback. Coverage 86, fidelity 86.
- **Pass 3:** "Clock skew on token expiry during shift?" Minor sentence. Negligible change. Coverage 88, fidelity 88. **Converged.**
- **Footer:** `— tap · "zero-downtime": 3 passes, coverage 70→86→88; fidelity 70→86→88 (converged)`

### Compound tap (automatic decomposition)

**Prompt:** `Draft the cutover section. It must be [[zero-downtime with session continuity during cutover and a rollback path if OAuth validation fails]].`

- **Tap:** compound → **Step 1b runs automatically.** Internal `R1…R5`: no visible outage; in-flight sessions survive; gradual/dual-run cutover; rollback if OAuth validation fails; rollback does not strand sessions worse than forward path.
- **Pass 1:** Covers R1 and R3 lightly; name-drops R2, R4. Coverage 65, fidelity 60.
- **Pass 2:** Objections on **R4** (rollback not operable), **R2** (no token bridge). Reconcile. Coverage 85, fidelity 82.
- **Pass 3:** Minor **R5** sentence. **Converged.**
- **Footer:** `— tap · "zero-downtime with session continuity…": 3 passes, coverage 65→85→88; fidelity 60→82→86 (converged; 5/5 requirements)`

## Additional resources

- Literature and lineage: [references/sources.md](references/sources.md)
