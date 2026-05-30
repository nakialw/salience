#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
ACTIONS=0

link_file() {
  local src="$1" dst="$2"
  local dst_dir
  dst_dir="$(dirname "$dst")"
  mkdir -p "$dst_dir"

  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "$current" = "$src" ]; then
      return 0
    fi
    rm "$dst"
    echo "  replaced stale symlink: $dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "${dst}.bak.${TIMESTAMP}"
    echo "  backed up: $dst -> ${dst}.bak.${TIMESTAMP}"
  fi

  ln -s "$src" "$dst"
  echo "  linked: $dst -> $src"
  ACTIONS=$((ACTIONS + 1))
}

link_dir() {
  local src="$1" dst="$2"
  local dst_parent
  dst_parent="$(dirname "$dst")"
  mkdir -p "$dst_parent"

  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "$current" = "$src" ]; then
      return 0
    fi
    rm "$dst"
    echo "  replaced stale symlink: $dst"
  elif [ -d "$dst" ]; then
    mv "$dst" "${dst}.bak.${TIMESTAMP}"
    echo "  backed up dir: $dst -> ${dst}.bak.${TIMESTAMP}"
  elif [ -e "$dst" ]; then
    mv "$dst" "${dst}.bak.${TIMESTAMP}"
    echo "  backed up: $dst -> ${dst}.bak.${TIMESTAMP}"
  fi

  ln -s "$src" "$dst"
  echo "  linked: $dst -> $src"
  ACTIONS=$((ACTIONS + 1))
}

# --- Claude Code ---
if [ -d "$HOME/.claude" ]; then
  echo "Installing Claude Code skills..."

  # Commands
  link_file "$REPO_DIR/skills/ensemble/claude/ensemble.md" \
            "$HOME/.claude/commands/ensemble.md"
  link_file "$REPO_DIR/skills/task-plan/claude/task-plan.md" \
            "$HOME/.claude/commands/task-plan.md"
  link_file "$REPO_DIR/skills/parallel-implementation/claude/parallel-implementation.md" \
            "$HOME/.claude/commands/parallel-implementation.md"
  link_file "$REPO_DIR/skills/publication-figure-qc/claude/publication-figure-qc.md" \
            "$HOME/.claude/commands/publication-figure-qc.md"

  # Shared references: task-plan templates
  for f in general.md deep-review.md llm-checker.md continuous-fix.md external-llm-prep.md; do
    link_file "$REPO_DIR/skills/task-plan/references/task-plan-templates/$f" \
              "$HOME/.claude/commands/references/task-plan-templates/$f"
  done

  # Shared references: parallel-implementation
  link_file "$REPO_DIR/skills/parallel-implementation/references/wave-planning.md" \
            "$HOME/.claude/commands/references/wave-planning.md"
  link_file "$REPO_DIR/skills/parallel-implementation/references/parallel-task-plan-template.md" \
            "$HOME/.claude/commands/references/parallel-task-plan-template.md"

  # Shared references: publication-figure-qc
  link_file "$REPO_DIR/skills/publication-figure-qc/references/issue-taxonomy.md" \
            "$HOME/.claude/commands/references/publication-figure-qc/issue-taxonomy.md"
  link_file "$REPO_DIR/skills/publication-figure-qc/references/sequential-checklist.md" \
            "$HOME/.claude/commands/references/publication-figure-qc/sequential-checklist.md"
  link_file "$REPO_DIR/skills/publication-figure-qc/scripts/qc_views.py" \
            "$HOME/.claude/commands/references/publication-figure-qc/scripts/qc_views.py"

  # deep-research-browser command + references
  link_file "$REPO_DIR/skills/deep-research-browser/claude/deep-research-browser.md" \
            "$HOME/.claude/commands/deep-research-browser.md"
  link_file "$REPO_DIR/skills/tap/claude/tap.md" \
            "$HOME/.claude/commands/tap.md"
  link_file "$REPO_DIR/skills/immune/claude/immune.md" \
            "$HOME/.claude/commands/immune.md"

  # Shared references: tap + immune (tap suite)
  link_file "$REPO_DIR/skills/tap/references/sources.md" \
            "$HOME/.claude/commands/references/tap/sources.md"
  link_file "$REPO_DIR/skills/immune/references/immuno-glossary.md" \
            "$HOME/.claude/commands/references/immune/immuno-glossary.md"
  link_file "$REPO_DIR/skills/immune/references/span-selection.md" \
            "$HOME/.claude/commands/references/immune/span-selection.md"
  link_file "$REPO_DIR/skills/immune/references/examples.md" \
            "$HOME/.claude/commands/references/immune/examples.md"

  link_file "$REPO_DIR/skills/deep-research-browser/references/chatgpt-ui-patterns.md" \
            "$HOME/.claude/commands/references/deep-research-browser/chatgpt-ui-patterns.md"

  # Platform configs: not auto-linked (machine-specific). See config/examples/
else
  echo "Skipping Claude Code (no ~/.claude/ directory)"
fi

# --- Codex ---
if [ -d "$HOME/.codex" ]; then
  echo "Installing Codex skills..."

  link_dir "$REPO_DIR/skills/ensemble/codex" \
           "$HOME/.codex/skills/ensemble-check"
  link_dir "$REPO_DIR/skills/task-plan/codex" \
           "$HOME/.codex/skills/task-plans"
  link_dir "$REPO_DIR/skills/parallel-implementation/codex" \
           "$HOME/.codex/skills/parallel-implementation"
  link_dir "$REPO_DIR/skills/publication-figure-qc/codex" \
           "$HOME/.codex/skills/publication-figure-qc"
  link_dir "$REPO_DIR/skills/tap/codex" \
           "$HOME/.codex/skills/tap"
  link_dir "$REPO_DIR/skills/immune/codex" \
           "$HOME/.codex/skills/immune"

  echo ""
  echo "  Optional: copy config/examples/ for platform settings (not symlinked)."
else
  echo "Skipping Codex (no ~/.codex/ directory)"
fi

# --- Gemini ---
if [ -d "$HOME/.gemini" ]; then
  echo "Installing Gemini skills..."

  if command -v gemini >/dev/null 2>&1; then
    for skill_dir in ensemble task-plan parallel-implementation publication-figure-qc tap immune; do
      local_dir="$REPO_DIR/skills/$skill_dir/gemini"
      if [ -d "$local_dir" ]; then
        skill_name=$(sed -n 's/^name: *//p' "$local_dir/SKILL.md" | head -1)
        if [ -n "$skill_name" ]; then
          gemini skills uninstall "$skill_name" --scope user 2>/dev/null || true
          gemini skills link "$local_dir" --consent 2>/dev/null && {
            echo "  linked gemini skill: $skill_name"
            ACTIONS=$((ACTIONS + 1))
          } || echo "  warning: failed to link gemini skill: $skill_name"
        fi
      fi
    done
  else
    echo "  Gemini CLI not found in PATH; skipping skill linking"
  fi
else
  echo "Skipping Gemini (no ~/.gemini/ directory)"
fi

echo ""
echo "Done. $ACTIONS symlinks created/updated."
