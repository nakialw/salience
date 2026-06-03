#!/usr/bin/env bash
# Run /immune on calibration prompts via `claude -p`. Requires Claude Code CLI + auth.
# SMOKE=1 runs ids 01,04,18,19,20 only and asserts v1.1 output contract.
# Exit policy (Policy B): FUNCTIONAL failures (tap trace leak, wrong gate, merged
# immune/tap footer) fail the build on ANY batch. COSMETIC issues (missing
# Auto-tapped line, missing non-merged footer) are warnings only — surfaced and
# tracked against the 19/20 auto_line target, but never block.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPTS="$REPO_DIR/docs/calibration/calibration-prompts.tsv"
OUT_DIR="$REPO_DIR/docs/calibration/runs-$(date +%Y%m%d-%H%M%S)"
WORKDIR="${CALIB_WORKDIR:-$HOME/ficture}"
SMOKE_IDS="01 04 18 19 20"

mkdir -p "$OUT_DIR"
SUMMARY="$OUT_DIR/summary.tsv"
echo -e "id\texpected_gate\tauto_line_ok\ttrace_leak\tgate_ok\tfooter_ok\tfooter_merged\tclass\texit_code" > "$SUMMARY"
FATAL=0
WARN=0
AUTO_LINE_OK=0
AUTO_LINE_TOTAL=0

if ! command -v claude >/dev/null 2>&1; then
  echo "error: claude CLI not found" >&2
  exit 1
fi

if [ ! -f "$PROMPTS" ]; then
  echo "error: missing $PROMPTS" >&2
  exit 1
fi

should_run() {
  local id="$1"
  if [ "${SMOKE:-0}" = "1" ]; then
    case " $SMOKE_IDS " in
      *" $id "*) return 0 ;;
      *) return 1 ;;
    esac
  fi
  return 0
}

strip_md() {
  sed 's/\*\*//g' "$1"
}

check_output() {
  local id="$1" expected="$2" out="$3"
  local plain auto_line_ok=0 trace_leak=0 gate_ok=0 footer_ok=0 footer_merged=0
  plain="$OUT_DIR/${id}.plain.txt"
  strip_md "$out" > "$plain"

  if grep -q '^Auto-tapped (immune):' "$plain" 2>/dev/null; then
    auto_line_ok=1
  elif [ "$expected" = "none" ] && grep -q 'no immuno gate' "$plain" 2>/dev/null; then
    auto_line_ok=1
  fi

  if grep -qiE 'Tap pass [0-9]|Adversarial pass log|Now drafting under tap|objections \(against|Draft → tap' "$plain" 2>/dev/null; then
    trace_leak=1
  fi

  case "$id" in
    18)
      if grep -q 'no immuno gate' "$plain" 2>/dev/null; then
        gate_ok=1
      elif grep -q '^Auto-tapped (immune):' "$plain" 2>/dev/null; then
        local auto
        auto=$(grep -m1 '^Auto-tapped (immune):' "$plain")
        if ! echo "$auto" | grep -qE 'T_CD8|B_cell|Macrophage|Treg|Plasma'; then
          gate_ok=1
        fi
      fi
      ;;
    19)
      grep -q 'no immuno gate' "$plain" 2>/dev/null && gate_ok=1
      ;;
    *)
      if [ "$expected" = "immuno" ]; then
        gate_ok=1
        grep -q 'no immuno gate' "$plain" 2>/dev/null && gate_ok=0
      else
        gate_ok=1
      fi
      ;;
  esac

  if grep -q '^— immune ·' "$plain" 2>/dev/null; then
    if grep -q '^— tap ·' "$plain" 2>/dev/null; then
      footer_ok=1
    elif grep -q 'no immuno gate' "$plain" 2>/dev/null; then
      footer_ok=1
    fi
  elif grep -q 'no immuno gate' "$plain" 2>/dev/null; then
    footer_ok=1
  fi

  if grep -E '^— immune ·.*tap ·' "$plain" 2>/dev/null; then
    footer_ok=0
    footer_merged=1
  fi

  # Policy B classification:
  #   FATAL  = functional failures: tap trace leak, wrong gate behavior, merged footer (contract violation)
  #   WARN   = cosmetic: missing Auto-tapped line, missing (non-merged) footer
  local fatal=0 warn=0
  [ "$trace_leak" -eq 0 ]   || { echo "  FATAL $id: tap trace in body"; fatal=1; }
  [ "$gate_ok" -eq 1 ]      || { echo "  FATAL $id: gate behavior"; fatal=1; }
  [ "$footer_merged" -eq 0 ] || { echo "  FATAL $id: merged immune/tap footer (contract violation)"; fatal=1; }
  [ "$auto_line_ok" -eq 1 ] || { echo "  warn  $id: missing Auto-tapped line"; warn=1; }
  [ "$footer_ok" -eq 1 ]    || { echo "  warn  $id: missing/!split footer"; warn=1; }

  # Track auto-line metric (non-blocking, target 19/20 per calibration-v1)
  AUTO_LINE_TOTAL=$((AUTO_LINE_TOTAL + 1))
  [ "$auto_line_ok" -eq 1 ] && AUTO_LINE_OK=$((AUTO_LINE_OK + 1))

  local class="ok"
  [ "$warn" -eq 1 ] && class="warn"
  [ "$fatal" -eq 1 ] && class="fatal"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t0\n' \
    "$id" "$expected" "$auto_line_ok" "$trace_leak" "$gate_ok" "$footer_ok" "$footer_merged" "$class" >> "$SUMMARY"

  FATAL_THIS=$fatal
  WARN_THIS=$warn
  return 0
}

while IFS=$'\t' read -r id source expected prompt; do
  [ -z "$id" ] && continue
  should_run "$id" || continue

  out="$OUT_DIR/${id}.txt"
  log="$OUT_DIR/${id}.log"
  echo "=== $id ($expected) ===" | tee -a "$log"
  set +e
  printf '%s\n' "/immune $prompt" | (cd "$WORKDIR" && claude -p) > "$out" 2>>"$log"
  ec=$?
  set -e

  if [ "$ec" -ne 0 ]; then
    echo "  -> exit $ec" | tee -a "$log"
    FATAL=$((FATAL + 1))
    continue
  fi

  FATAL_THIS=0
  WARN_THIS=0
  check_output "$id" "$expected" "$out"
  FATAL=$((FATAL + FATAL_THIS))
  WARN=$((WARN + WARN_THIS))
  if [ "$FATAL_THIS" -ne 0 ]; then
    echo "  -> FATAL"
  elif [ "$WARN_THIS" -ne 0 ]; then
    echo "  -> ok (with warnings)"
  else
    echo "  -> ok" | tee -a "$log"
  fi
done < <(tail -n +2 "$PROMPTS")

echo ""
echo "Wrote $OUT_DIR"
echo "Summary: $SUMMARY"
echo ""
echo "auto_line: ${AUTO_LINE_OK}/${AUTO_LINE_TOTAL} (target 19/20; non-blocking metric)"
echo "warnings (cosmetic, non-blocking): $WARN"
echo "fatal (functional): $FATAL"

# Policy B: functional failures fail the build on ANY batch (smoke or full).
# Cosmetic warnings (missing Auto-tapped line, missing non-merged footer) never block;
# they are surfaced above and tracked against the 19/20 auto_line target.
if [ "$FATAL" -gt 0 ]; then
  echo "BUILD FAILED: $FATAL functional failure(s) — tap trace leak, gate error, or merged footer." >&2
  exit 1
fi

if [ "$WARN" -gt 0 ]; then
  echo "Passed with $WARN cosmetic warning(s) (non-blocking)."
else
  echo "All assertions passed."
fi
