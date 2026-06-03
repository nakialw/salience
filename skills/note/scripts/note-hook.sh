#!/usr/bin/env bash
# note-hook.sh — git post-commit hook that fires the `note` skill on large commits.
#
# Install (from a repo where you want auto-notes):
#   ln -s /path/to/salience/skills/note/scripts/note-hook.sh .git/hooks/post-commit
#   chmod +x .git/hooks/post-commit
#
# Config (env or git config):
#   NOTE_THRESHOLD       lines changed (insertions+deletions) to trigger; default 200
#   NOTE_NOTEBOOK        notebook path; default docs/lab-notebook.md
#   NOTE_DISABLE=1       skip entirely
#   git config note.threshold 200   # alternative to env var
#
# Safety contract: this runs AFTER the commit is already made. It must NEVER
# fail the commit, block, or hang. All failure paths exit 0. If the `claude`
# CLI is absent or errors, the hook degrades to a silent no-op (optionally
# leaving a TODO marker) — it never leaves the repo in a bad state.

set -u  # NOT -e: we never want a failure here to surface as a commit error.

# --- opt-out ---
if [ "${NOTE_DISABLE:-0}" = "1" ]; then
  exit 0
fi

# --- locate repo ---
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -z "$REPO_ROOT" ] && exit 0
cd "$REPO_ROOT" || exit 0

# --- guard against recursion ---
# `note` appending to the notebook + a commit could re-trigger the hook.
# Skip if the latest commit only touches the notebook itself.
NOTEBOOK="${NOTE_NOTEBOOK:-docs/lab-notebook.md}"
CHANGED="$(git diff --name-only HEAD~1..HEAD 2>/dev/null || git show --name-only --format= HEAD 2>/dev/null || true)"
if [ -n "$CHANGED" ] && [ "$(echo "$CHANGED" | grep -vc "^${NOTEBOOK}$")" = "0" ]; then
  # every changed file IS the notebook → don't recurse
  exit 0
fi

# --- threshold ---
THRESHOLD="${NOTE_THRESHOLD:-$(git config --get note.threshold 2>/dev/null || echo 200)}"

# --- compute diff size of the just-made commit ---
# Sum insertions+deletions from --numstat (handles multiple files; ignores binary "-").
if git rev-parse HEAD~1 >/dev/null 2>&1; then
  RANGE="HEAD~1..HEAD"
  NUMSTAT="$(git diff --numstat HEAD~1..HEAD 2>/dev/null)"
else
  # first commit: diff against empty tree
  RANGE="(root commit)"
  NUMSTAT="$(git show --numstat --format= HEAD 2>/dev/null)"
fi

LINES="$(echo "$NUMSTAT" | awk '{ if ($1 ~ /^[0-9]+$/) ins+=$1; if ($2 ~ /^[0-9]+$/) del+=$2 } END { print ins+del+0 }')"
FILES="$(echo "$NUMSTAT" | grep -c .)"

# --- decide ---
if [ "${LINES:-0}" -lt "$THRESHOLD" ]; then
  exit 0  # not substantial enough; nothing to do
fi

SHA="$(git rev-parse --short HEAD 2>/dev/null)"
SUBJECT="$(git log -1 --format=%s 2>/dev/null)"

# --- build the context handed to the skill ---
read -r -d '' CONTEXT <<EOF || true
[note hook] A commit exceeded the ${THRESHOLD}-line threshold (${LINES} lines across ${FILES} file(s)).

Run the note skill for this commit:
- SHA: ${SHA}
- Range: ${RANGE}
- Subject: ${SUBJECT}
- Notebook: ${NOTEBOOK}

Use git to gather the facts (git log -1, git diff --stat ${RANGE}, git diff ${RANGE}), write the six-field entry, and append it to ${NOTEBOOK}. Non-interactive: do not ask questions; infer the goal from the commit message and diff and mark it inferred.
EOF

# --- invoke claude non-interactively, or degrade safely ---
if command -v claude >/dev/null 2>&1; then
  # Run in background so the hook returns immediately and never blocks the user.
  # Output/errors are logged, not surfaced.
  ( printf '/note %s\n' "$CONTEXT" | claude -p >/dev/null 2>>"$REPO_ROOT/.git/note-hook.log" ) &
  exit 0
else
  # No CLI: leave a lightweight reminder instead of failing.
  mkdir -p "$(dirname "$NOTEBOOK")" 2>/dev/null || true
  {
    echo ""
    echo "<!-- note-hook: commit ${SHA} (${LINES} lines) exceeded threshold but \`claude\` CLI was not found."
    echo "     Run \`/note ${SHA}\` manually to record this change. -->"
  } >> "$NOTEBOOK" 2>/dev/null || true
  exit 0
fi
