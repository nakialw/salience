---
argument-hint: [optional context — what the last change was about; omit to infer from git]
description: Append a structured lab-notebook entry (date, title, goal, result, next step, pitfalls) after a substantial code change. Fires manually as /note or automatically via the post-commit hook on large diffs.
---

Apply the **note** skill. Produce one dated lab-notebook entry recording the change that just happened, and append it to the lab notebook.

$ARGUMENTS

## Purpose

`note` captures research/engineering provenance the moment it's freshest — after a substantial change — so the *reasoning* behind the work isn't lost. Structured, machine-parseable entries beat free-text logs (Schröder et al. 2022, RO-Crate/FAIR provenance), and the single highest-value field is the one normally lost: **pitfalls / rejected approaches / null results**. Capture those deliberately. See [references/sources.md](references/note/sources.md).

(Note: `note` is justified by provenance and reproducibility, **not** by productivity claims — the often-quoted "ELN saves ~9 hours/week" figure is a 7-user vendor study, not evidence. Don't repeat it.)

## When this runs

- **Manually:** the user runs `/note` (optionally with a one-line context argument).
- **Automatically:** the post-commit hook (`scripts/note-hook.sh`) detects a commit whose diff exceeds the line threshold (default 200) and invokes this skill non-interactively. In hook mode you will be given the commit SHA, stats, and changed-file list as context — use them; do not block on questions.

## Step 1 — Gather the facts (don't invent them)

Establish what actually changed from the repository, not from memory:

- Most recent commit: `git log -1 --format='%H%n%an%n%ad%n%s%n%b'` (SHA, author, date, subject, body).
- Scope: `git diff --stat HEAD~1..HEAD` (files touched, insertions/deletions). If `HEAD~1` doesn't exist (first commit), use `git show --stat HEAD`.
- Changed files and the nature of the change: read the diff (`git diff HEAD~1..HEAD`) enough to describe *what* changed and *why it mattered*, not line-by-line.

If invoked outside a git repo or with no commits, ask the user for the change description rather than fabricating git facts.

**Goal of the last prompt:** if a context argument was passed, that *is* the goal — use it. Otherwise infer the goal from the commit message + diff, and mark it as inferred (`Goal (inferred): …`) so the record is honest about its source.

## Step 2 — Write the entry

Emit exactly these fields, in this order. Keep each tight — this is a logbook, not a report.

```markdown
## <YYYY-MM-DD HH:MM> — <concise title>

- **Commit:** `<short-sha>` (<n files, +x/−y>)
- **Goal:** <what this change was trying to achieve — the objective of the last prompt/task>
- **Result:** <what actually happened — what now works/exists that didn't before; state plainly if partial or if it failed>
- **Next step:** <the single most likely next action forward>
- **Pitfalls:** <known weaknesses, risks, or rejected approaches of the CURRENT approach — what might bite us, what we tried that didn't work, what we're unsure about. This field is mandatory and must be substantive — "none" is rarely the honest answer.>
```

Rules:
- **Date/time:** use the actual commit timestamp (from Step 1), not a guess.
- **Result must be honest about failure.** If the change didn't achieve the goal, say so — a logbook that only records successes is useless for reproducibility. Null results are high-value (record them).
- **Pitfalls is the point.** Resist writing "none." Name the real risk: an untested path, a shortcut taken, an assumption not yet validated, a calibration still deferred. If you genuinely see no pitfall, say *why* you're confident, briefly.
- **No invented facts.** Every concrete claim (file count, what changed) traces to Step 1. Don't attribute intent the diff doesn't support.
- Keep it to the six fields. No preamble, no postscript.

## Step 3 — Append to the notebook

- Default notebook path: `docs/lab-notebook.md` (create it with an `# Lab notebook` header if absent).
- The hook may pass an explicit `--notebook <path>`; honor it.
- **Append** the new entry under the header, newest-last (chronological) — do not overwrite or reorder existing entries.
- After appending, report the one-line title and the path written, nothing more.

## Output (manual mode)

Show the user the entry you appended and the path. One line of confirmation is enough — don't re-explain the change they just made.

## Notes on scope

- `note` records; it does not evaluate the quality of the change (that's `tap`/`clarify`/`publication-figure-qc`). It captures *what happened and what's risky*, faithfully.
- The 200-line threshold is a heuristic for "substantial," configurable in the hook. It's a trigger for *when to bother*, not a claim that smaller changes don't matter.
- Entries are designed to be machine-parseable (consistent field headers) so the notebook can later be processed into structured provenance if desired.

Lineage and rationale: [references/sources.md](references/note/sources.md).
