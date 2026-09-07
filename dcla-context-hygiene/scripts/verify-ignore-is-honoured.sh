#!/usr/bin/env bash
# verify-ignore-is-honoured.sh — pre-check for the DCLA root .ignore.
#
# DCLA is not a single Git repository. Ripgrep's discovery of PARENT .ignore
# files depends on repo-root detection; when an agent starts in a project
# subdirectory, a DCLA-root .ignore may not be honoured at all. Verify before
# trusting it.
#
# Usage: verify-ignore-is-honoured.sh <project-subdirectory>
#
# Exit codes: 0 pass | 1 ignore not applied | 2 cannot run the check

set -uo pipefail

d="${1:?usage: verify-ignore-is-honoured.sh <project-subdirectory>}"
[ -d "$d" ] || { echo "ERROR: not a directory: $d" >&2; exit 2; }
cd "$d" || exit 2

echo "cwd: $(pwd)"

# ---------------------------------------------------------------------------
# Magnitude report — works without ripgrep. Shows what a naive enumeration
# would sweep up, which is the cost the .ignore exists to avoid.
# ---------------------------------------------------------------------------
total=$(find . -type f 2>/dev/null | wc -l | tr -d ' ')
junk=$(find . -type f \( -path '*/node_modules/*' -o -path '*/.venv/*' \
        -o -path '*/venv/*' -o -path '*/__pycache__/*' -o -path '*/.git/*' \
        -o -path '*/dist/*' -o -path '*/build/*' -o -path '*/.next/*' \
        -o -path '*/.vercel/*' -o -name '*.inspect.ndjson' \) 2>/dev/null \
        | wc -l | tr -d ' ')
echo "files here:              $total"
echo "in generated/vendored:   $junk"
if [ "${total:-0}" -gt 0 ] 2>/dev/null; then
  echo "share that .ignore hides: $(( junk * 100 / total ))%"
fi
echo

# ---------------------------------------------------------------------------
# The actual check. REQUIRES ripgrep. Never report PASS without running it.
# ---------------------------------------------------------------------------
if ! command -v rg >/dev/null 2>&1; then
  cat <<'MSG' >&2
CANNOT VERIFY — ripgrep (rg) is not on PATH. This check did NOT run.

Install it, then re-run:
    brew install ripgrep

Note on what this means in practice: Claude Code ships its own bundled
ripgrep for its search tool, so agent searches still honour .ignore files
even when `rg` is absent from your shell. Installing rg here is about being
able to VERIFY that behaviour yourself, and about your own shell searches.
Other agents (Codex, editors) may or may not use ripgrep at all — the
.ignore only helps tools that honour it.

To test the bundled ripgrep directly, open a Claude Code session in this
directory and ask it to search for a string that exists only inside
node_modules. If it returns hits, the .ignore is not being applied there.
MSG
  exit 2
fi

hits=$(rg --files --no-require-git 2>/dev/null \
       | rg -c 'node_modules/|__pycache__/|/\.venv/|/dist/|/\.next/' || true)
hits="${hits:-0}"

if [ "$hits" -gt 0 ]; then
  cat <<'MSG' >&2
FAIL — the root .ignore is NOT being applied from this subdirectory.
       (generated-tree paths still enumerate)

Fix, in order of preference:

1. Global ripgrep config (most reliable, applies from any cwd):
     mkdir -p "$HOME/.config/ripgrep"
     printf -- '--ignore-file=%s\n' \
       "/Users/morgangodvin/Claude Code/DCLA/.ignore" \
       >> "$HOME/.config/ripgrep/ripgreprc"
     echo 'export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"' >> ~/.zshrc

   Note: RIPGREP_CONFIG_PATH affects your shell's rg. It does not necessarily
   reach an agent's bundled ripgrep, which is why option 2 matters.

2. Drop a copy of .ignore at each project root as well as the DCLA root.
   This is what actually protects agent searches, because a .ignore in the
   search directory itself is honoured unconditionally.

Re-run this script after applying a fix.
MSG
  echo "matching paths: $hits" >&2
  exit 1
fi

echo "PASS — ripgrep enumerated no generated-tree paths from this directory."
