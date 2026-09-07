#!/usr/bin/env bash
# check-dir-bloat.sh — catch runaway directories early.
#
# Evidence for this guard: on 2026-09-05 a retry loop ran for four to five
# hours and wrote 7,036 files into
#   incoming/CENSUS-CLUSTER-051-.../_superseded
# of which 6,319 were byte-identical copies of a single failed render. Its
# sibling clusters hold 46-177 files each. A 500-file threshold would have
# tripped within the first minutes instead of after four hours.
#
# Also reports quarantine/superseded directories past their retention window,
# because DCLA already has the _quarantine convention and nothing purges it.
#
# Usage:
#   check-dir-bloat.sh [root] [max-files-per-dir] [retention-days]
# Defaults: . 500 30

set -uo pipefail

ROOT="${1:-.}"
MAX="${2:-500}"
RETENTION_DAYS="${3:-30}"
fail=0
note() { printf '%s\n' "$*" >&2; }

PRUNE=( -name node_modules -o -name .venv -o -name venv -o -name .git
        -o -name __pycache__ -o -name dist -o -name .next )

echo "=== directories over ${MAX} files (immediate children only) ==="
while IFS= read -r -d '' d; do
  n=$(find "$d" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "${n:-0}" -gt "$MAX" ]; then
    note "BLOAT  ${n} files  $d"
    fail=1
    # Byte-identical duplicates are the runaway-loop signature.
    dup=$(find "$d" -maxdepth 1 -type f -exec shasum {} + 2>/dev/null \
          | awk '{print $1}' | sort | uniq -c | sort -rn | head -1)
    [ -n "$dup" ] && note "       most-repeated hash: ${dup# }"
  fi
done < <(find "$ROOT" \( "${PRUNE[@]}" \) -prune -o -type d -print0 2>/dev/null)

echo
echo "=== quarantine/superseded older than ${RETENTION_DAYS} days ==="
found_stale=0
while IFS= read -r -d '' d; do
  n=$(find "$d" -type f 2>/dev/null | wc -l | tr -d ' ')
  [ "${n:-0}" -eq 0 ] && continue
  note "STALE  ${n} files  $d"
  found_stale=1
done < <(find "$ROOT" -type d \( -iname '*_quarantine*' -o -iname '*_superseded*' \) \
         -mtime "+${RETENTION_DAYS}" -print0 2>/dev/null)
[ "$found_stale" -eq 0 ] && echo "none"

echo
if [ "$fail" -eq 0 ]; then
  echo "no directory bloat detected"
else
  note "A directory this large is almost always a loop that wrote its"
  note "intermediates where they do not belong. Intermediates go to"
  note ".scratch/<run-id>/ (ignored, purgeable); only a deliberate promotion"
  note "step moves a finished artefact into incoming/."
fi
exit "$fail"
