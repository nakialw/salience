# Ensemble Review Prompt

## Objective

[State the exact question to answer.]

## Mode

`{{MODE}}`

## Review Posture

`{{POSTURE}}`

## Model Set

{{MODELS}}

## Scope

- Files:
  - [absolute or repo-relative path]
- Decision boundary:
  - [what is in scope]
  - [what is out of scope]

## Context

[Provide only the context required to evaluate the task fairly.]

## Constraints

- Preserve existing behavior unless a change is explicitly requested.
- Call out uncertainty instead of filling gaps with speculation.
- Prefer specific file references over generic advice.

## Posture Instructions

- `standard-consensus`: review normally and give the strongest grounded answer.
- `dissent-first`: lead with the strongest non-consensus concern, objection, or failure mode before broader agreement.
- `adjudication`: give your independent best answer from the evidence and do not try to force consensus early.

## Output Contract

### Required structure

1. Findings or conclusions first
2. Evidence tied to the provided files or context
3. Confidence notes or open questions
4. Recommended next action

### Posture-specific emphasis

- If posture is `dissent-first`, put the strongest disagreement first.
- If posture is `adjudication`, make the argument explicit enough that a later synthesis can choose among competing positions.

### If this is code review

- Order findings by severity
- Include file references
- Focus on bugs, regressions, risks, and missing tests

### If this is plan review

- Identify missing steps, unsafe assumptions, and sequencing risks
- Say whether the plan is executable as written

### If this is debugging

- State the most likely root causes
- Rank them
- Suggest discriminating checks
