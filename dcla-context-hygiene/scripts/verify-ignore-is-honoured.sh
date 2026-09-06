#!/usr/bin/env bash
# verify-ignore-is-honoured.sh — CRITICAL PRE-CHECK for the root .ignore.
#
# DCLA is not a single Git repository. Ripgrep's discovery of PARENT .ignore
# files depends on repo-root detection; when an agent starts in a project
# subdirectory, a DCLA-root .ignore may not be honoured at all. Verify before
# trusting it.
#
# Usage: scripts/verify-ignore-is-honoured.sh <project-subdirectory>

set -uo pipefail
d="${1:?usage: verify-ignore-is-honoured.sh <project-subdirectory>}"
cd "$d" || exit 1

echo "cwd: $(pwd)"
hits=$(rg --files --no-require-git 2>/dev/null | rg -c 'node_modules|__pycache__|/\.venv/' || true)

if [ "${hits:-0}" -gt 0 ]; then
  cat <<'MSG'
FAIL — the root .ignore is NOT being applied from this subdirectory.
       (generated-tree paths still enumerate)

Fix, in order of preference:

1. Global ripgrep config (most reliable, applies from any cwd):
     export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
     mkdir -p "$HOME/.config/ripgrep"
     echo '--ignore-file=/Users/morgangodvin/Claude Code/DCLA/.ignore' \
       >> "$HOME/.config/ripgrep/ripgreprc"
   Add the export to your shell profile so agent sessions inherit it.

2. Drop a copy of .ignore at each project root as well as the DCLA root.

Re-run this script after applying a fix.
MSG
  exit 1
fi

echo "PASS — no generated-tree paths enumerated from this directory."
