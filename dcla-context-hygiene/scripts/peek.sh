#!/usr/bin/env bash
# peek.sh — inspect a data file without loading it into context.
#
# The largest recurring context leak in a scraping/records project is an agent
# running `cat` on a CSV or NDJSON. This makes the right way the easy way.
#
# Usage: scripts/peek.sh <file> [n]     # n = sample rows, default 10

set -euo pipefail
f="${1:?usage: peek.sh <file> [n]}"
n="${2:-10}"

[ -f "$f" ] || { echo "no such file: $f" >&2; exit 1; }

bytes=$(wc -c < "$f" | tr -d ' ')
echo "file:  $f"
echo "bytes: $bytes"

case "$f" in
  *.csv|*.tsv|*.txt|*.ndjson|*.jsonl|*.log)
    echo "lines: $(wc -l < "$f" | tr -d ' ')"
    echo "--- first $n ---"
    head -n "$n" "$f" | cut -c1-400
    ;;
  *.json)
    echo "--- top-level shape ---"
    if command -v jq >/dev/null 2>&1; then
      jq -r 'if type=="array" then "array, length \(length)"
             elif type=="object" then "object, keys: \(keys|join(", "))"
             else type end' "$f"
      echo "--- first $n (if array) ---"
      jq -c ".[0:$n]? // ." "$f" | cut -c1-800
    else
      head -c 800 "$f"; echo
    fi
    ;;
  *.xlsx|*.xlsm)
    echo "--- sheets ---"
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$f" <<'PY'
import sys, zipfile, re
with zipfile.ZipFile(sys.argv[1]) as z:
    wb = z.read("xl/workbook.xml").decode("utf-8", "replace")
    for m in re.finditer(r'<sheet[^>]*name="([^"]+)"', wb):
        print(" ", m.group(1))
PY
    else
      echo "  (install python3 to list sheets)"
    fi
    echo "Do not convert the whole workbook. Query the sheet you need."
    ;;
  *)
    echo "--- first $n lines ---"
    head -n "$n" "$f" | cut -c1-400
    ;;
esac
echo "---"
echo "Read only the section you need. Do not open this file whole."
