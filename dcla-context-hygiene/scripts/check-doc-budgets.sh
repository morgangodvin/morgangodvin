#!/usr/bin/env bash
# check-doc-budgets.sh — enforce DCLA documentation budgets.
#
# Budgets without enforcement decay. This is the mechanism that stops the next
# README from reaching 2,000 lines.
#
# Usage:
#   scripts/check-doc-budgets.sh [root]          # check, exit 1 on violation
#   STRICT_DATES=1 scripts/check-doc-budgets.sh  # also fail on stray dates
#
# Install as a pre-commit hook, or run weekly from cron.

set -uo pipefail

ROOT="${1:-.}"
README_MAX_LINES=250
README_MAX_BYTES=25600      # 25 KB
ROUTER_MAX_LINES=150

fail=0

note() { printf '%s\n' "$*" >&2; }

# Directories we never audit (generated / vendored / archived history).
PRUNE=(
  -name node_modules -o -name .venv -o -name venv -o -name .git
  -o -name __pycache__ -o -name dist -o -name build -o -name .next
  -o -name .vercel -o -name history -o -name archive -o -name logs
)

while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  lines=$(wc -l < "$f" | tr -d ' ')
  bytes=$(wc -c < "$f" | tr -d ' ')

  case "$base" in
    README.md)
      if [ "$lines" -gt "$README_MAX_LINES" ] || [ "$bytes" -gt "$README_MAX_BYTES" ]; then
        note "OVER BUDGET  $f  (${lines} lines / ${bytes} bytes; max ${README_MAX_LINES} / ${README_MAX_BYTES})"
        fail=1
      fi
      # A README should carry at most one date: the "Last updated" line.
      # Per-run chronology belongs in history/ or logs/.
      datecount=$(grep -cE '[0-9]{4}-[0-9]{2}-[0-9]{2}|(January|February|March|April|May|June|July|August|September|October|November|December) [0-9]{1,2}' "$f" || true)
      if [ "${datecount:-0}" -gt 1 ]; then
        note "DATES        $f  (${datecount} dated lines; expected at most 1 'Last updated')"
        [ "${STRICT_DATES:-0}" = "1" ] && fail=1
      fi
      ;;
    CLAUDE.md|AGENTS.md)
      if [ "$lines" -gt "$ROUTER_MAX_LINES" ]; then
        note "OVER BUDGET  $f  (${lines} lines; max ${ROUTER_MAX_LINES})"
        fail=1
      fi
      ;;
  esac
done < <(find "$ROOT" \( "${PRUNE[@]}" \) -prune -o \
         -type f \( -name README.md -o -name CLAUDE.md -o -name AGENTS.md \) -print0)

if [ "$fail" -eq 0 ]; then
  echo "doc budgets OK"
else
  note ""
  note "Fix by moving chronology into dated files under history/ or logs/,"
  note "not by raising the budget."
fi
exit "$fail"
