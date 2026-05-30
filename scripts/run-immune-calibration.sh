#!/usr/bin/env bash
# Run /immune on calibration prompts via `claude -p`. Requires Claude Code CLI + auth.
# SMOKE=1 runs ids 01,04,18,19,20 only and asserts v1.1 output contract.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPTS="$REPO_DIR/docs/calibration/calibration-prompts.tsv"
OUT_DIR="$REPO_DIR/docs/calibration/runs-$(date +%Y%m%d-%H%M%S)"
WORKDIR="${CALIB_WORKDIR:-$HOME/ficture}"
SMOKE_IDS="01 04 18 19 20"
FAILURES=0

mkdir -p "$OUT_DIR"
SUMMARY="$OUT_DIR/summary.tsv"
echo -e "id\texpected_gate\tauto_line_ok\ttrace_leak\tgate_ok\tfooter_ok\texit_code" > "$SUMMARY"

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
  local plain auto_line_ok=0 trace_leak=0 gate_ok=0 footer_ok=0
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
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t0\n' \
    "$id" "$expected" "$auto_line_ok" "$trace_leak" "$gate_ok" "$footer_ok" >> "$SUMMARY"

  local fail=0
  [ "$auto_line_ok" -eq 1 ] || { echo "  FAIL $id: missing Auto-tapped line or gate footer"; fail=1; }
  [ "$trace_leak" -eq 0 ] || { echo "  FAIL $id: tap trace in body"; fail=1; }
  [ "$gate_ok" -eq 1 ] || { echo "  FAIL $id: gate behavior"; fail=1; }
  [ "$footer_ok" -eq 1 ] || { echo "  FAIL $id: footer format"; fail=1; }
  return "$fail"
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
    FAILURES=$((FAILURES + 1))
    continue
  fi

  if ! check_output "$id" "$expected" "$out"; then
    FAILURES=$((FAILURES + 1))
  else
    echo "  -> ok" | tee -a "$log"
  fi
done < <(tail -n +2 "$PROMPTS")

echo ""
echo "Wrote $OUT_DIR"
echo "Summary: $SUMMARY"

if [ "${SMOKE:-0}" = "1" ] && [ "$FAILURES" -gt 0 ]; then
  echo "SMOKE FAILED: $FAILURES assertion(s)" >&2
  exit 1
fi

echo "All assertions passed."
