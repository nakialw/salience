---
argument-hint: <prompt containing [[tapped spans]] or emphasis instructions>
description: Prompt-emphasis and adversarial self-review on marked critical spans until convergence.
---

Apply the **tap** skill to the following request. If the message has no taps and no emphasis signal, respond normally without the tap loop.

$ARGUMENTS

## Instructions

You are using `tap` — iterate-to-convergence on emphasized prompt portions before settling your answer.

### Step 1 — Identify taps

Extract **tap targets** from:

- `[[double brackets]]` (primary syntax; brackets are markers, not text to echo back)
- Explicit: "tap:", "upweight", "don't neglect", "the key part is", "make sure you nail"
- Inferred critical span when the user clearly flags one portion as non-negotiable
- Optional: `<tap target="...">...</tap>`

Do not confuse input `[[emphasis]]` with IFEval-style `[[title]]` *output* constraints.

**Auto-taps from `immune`:** Spans auto-bracketed by `/immune` are normal tap targets (same steps below). Critique stays span-anchored — no domain failure templates from `immune`.

### Step 1b — Decompose compound taps (automatic)

**Runs automatically** when a tap is compound — no extra user flag.

**Decompose if:** >~15 words, OR 2+ clauses ("and", "but", "without", lists, etc.), OR multiple distinct obligations.

**Skip if:** short single-obligation tap (e.g. `[[zero-downtime]]`).

Before Pass 1, derive **3–7 atomic requirements** `R1…Rn` (internal only). Each `Ri` = one checkable obligation. Use `Ri` in factored check and red-team (cite "R3: …" in objections). Do not print `R1…Rn` in the answer unless the user asked for an outline.

**Opt-out:** `tap-raw` or `no decompose` on a span → treat as atomic.

### Step 2 — Pass 1: draft

Answer the **whole** prompt (taps upweight; they don't narrow the task). For each tap target, engage substantively at **2+ distinct points** — e.g. introduce, operationalize, stress-test/consequences.

Record honest internal scores (0–100, not calibrated): **coverage** and **fidelity**.

### Step 3 — Pass 2+: adversarial review

For each tap target:

1. **Factored check** (before reading the draft charitably): What does the phrase require? (Each **`Ri`** if decomposed.) What would violate it? Any verifiable checks?
2. **Red-team** the draft: at least one concrete objection per pass (cite **`Ri`** when decomposed). Attack neglect, not the user's authority (**anti-sycophancy**).
3. **Reconcile** into a revised answer; re-score.

Use tools/tests/retrieval for **verifiable** taps when available — not introspection alone.

If the prompt cites a **repo path** (`submission/…`, concrete filename): **Read** the file before Pass 1 claims about its contents. Footer may note `(verified: path)` or `(intrinsic only — file not read)`.

Minimum **2** review passes after the draft; **cap 4** per target. High Pass-1 scores still get a real break attempt.

### Step 4 — Convergence

- Material substantive change → another pass.
- Negligible change and coverage/fidelity plateau (Δ ≤ 5 for two passes) → **converged**.
- Oscillation → stop with `(settled — oscillation)`.

### Step 5 — Deliver (user-visible output)

All adversarial work (drafts, passes, `R1…Rn`, scores, objections) is **internal only**.

**Required structure:**

1. If chained from `/immune`: `Auto-tapped (immune): …` is already line 1 — do not repeat.
2. **Answer body** — prose only.
3. If from `/immune`: `— immune · N auto (M manual)` on its **own line** (plain text, no bold).
4. `— tap · …` on its **own line** (plain text, one line).

**FORBIDDEN in user-visible output:**

- "Tap pass N", "Draft →", "Adversarial pass log", "objections:", "Now drafting under tap…"
- Internal `R1…Rn` lists or coverage/fidelity narration in the body
- Merging immune + tap into one footer line
- Bold/markdown on footer lines (`**— tap ·**`)
- Echoing `[[...]]` bracket syntax in the answer body (tap phrases appear as plain prose)

**Tap footer** (one line), e.g.:

`— tap · "zero-downtime": 3 passes, coverage 70→86→88; fidelity 70→86→88 (converged)`

Multiple targets: separate with `; `. Unconverged: `(settled at cap — best of N)` or `(settled — oscillation)`. Decomposed taps: optional `(5/5 requirements)` on the same line.

Do not claim this manipulates logits or token probabilities — it is deliberate attention and critique only.

**Examples:** `[[zero-downtime]]` → no decomposition. `[[zero-downtime with session continuity and rollback if OAuth fails]]` → auto `R1…Rn`, footer may show `(5/5 requirements)`.
