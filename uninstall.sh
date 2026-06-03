#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
REMOVED=0

unlink_if_ours() {
  local dst="$1"
  if [ -L "$dst" ]; then
    local target
    target="$(readlink "$dst")"
    case "$target" in
      "$REPO_DIR"/*)
        rm "$dst"
        echo "  removed: $dst"
        REMOVED=$((REMOVED + 1))

        # Check for backup
        local latest_bak
        latest_bak="$(ls -1t "${dst}".bak.* 2>/dev/null | head -1 || true)"
        if [ -n "$latest_bak" ]; then
          echo "    backup available: $latest_bak"
        fi
        ;;
    esac
  fi
}

# --- Claude Code ---
if [ -d "$HOME/.claude" ]; then
  echo "Removing Claude Code symlinks..."

  unlink_if_ours "$HOME/.claude/commands/ensemble.md"
  unlink_if_ours "$HOME/.claude/commands/task-plan.md"
  unlink_if_ours "$HOME/.claude/commands/parallel-implementation.md"
  unlink_if_ours "$HOME/.claude/commands/publication-figure-qc.md"

  for f in general.md deep-review.md llm-checker.md continuous-fix.md external-llm-prep.md; do
    unlink_if_ours "$HOME/.claude/commands/references/task-plan-templates/$f"
  done

  unlink_if_ours "$HOME/.claude/commands/references/wave-planning.md"
  unlink_if_ours "$HOME/.claude/commands/references/parallel-task-plan-template.md"
  unlink_if_ours "$HOME/.claude/commands/references/publication-figure-qc/issue-taxonomy.md"
  unlink_if_ours "$HOME/.claude/commands/references/publication-figure-qc/sequential-checklist.md"
  unlink_if_ours "$HOME/.claude/commands/references/publication-figure-qc/scripts/qc_views.py"

  unlink_if_ours "$HOME/.claude/commands/deep-research-browser.md"
  unlink_if_ours "$HOME/.claude/commands/references/deep-research-browser/chatgpt-ui-patterns.md"
  unlink_if_ours "$HOME/.claude/commands/tap.md"
  unlink_if_ours "$HOME/.claude/commands/immune.md"
  unlink_if_ours "$HOME/.claude/commands/clarify.md"
  unlink_if_ours "$HOME/.claude/commands/note.md"
  unlink_if_ours "$HOME/.claude/commands/introspect.md"
  unlink_if_ours "$HOME/.claude/commands/anterospect.md"
  unlink_if_ours "$HOME/.claude/commands/references/tap/sources.md"
  unlink_if_ours "$HOME/.claude/commands/references/clarify/sources.md"
  unlink_if_ours "$HOME/.claude/commands/references/note/sources.md"
  unlink_if_ours "$HOME/.claude/commands/references/note/note-hook.sh"
  unlink_if_ours "$HOME/.claude/commands/references/introspect/sources.md"
  unlink_if_ours "$HOME/.claude/commands/references/anterospect/sources.md"
  unlink_if_ours "$HOME/.claude/commands/references/immune/immuno-glossary.md"
  unlink_if_ours "$HOME/.claude/commands/references/immune/span-selection.md"
  unlink_if_ours "$HOME/.claude/commands/references/immune/examples.md"

  # Config symlinks removed in salience — skills only
fi

# --- Codex ---
if [ -d "$HOME/.codex" ]; then
  echo "Removing Codex symlinks..."

  unlink_if_ours "$HOME/.codex/skills/ensemble-check"
  unlink_if_ours "$HOME/.codex/skills/task-plans"
  unlink_if_ours "$HOME/.codex/skills/parallel-implementation"
  unlink_if_ours "$HOME/.codex/skills/publication-figure-qc"
  unlink_if_ours "$HOME/.codex/skills/tap"
  unlink_if_ours "$HOME/.codex/skills/immune"
fi

# --- Gemini ---
if [ -d "$HOME/.gemini" ] && command -v gemini >/dev/null 2>&1; then
  echo "Removing Gemini skills..."
  for skill_name in ensemble-check task-plans parallel-implementation publication-figure-qc tap immune; do
    gemini skills uninstall "$skill_name" --scope user 2>/dev/null && {
      echo "  uninstalled gemini skill: $skill_name"
      REMOVED=$((REMOVED + 1))
    } || true
  done
fi

echo ""
echo "Done. $REMOVED symlinks removed."
echo "Restore backups manually if needed (look for *.bak.* files)."
