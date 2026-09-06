# DCLA context-hygiene package

Drafted 2026-09-06 in a remote session with **no access to the DCLA filesystem**.
Every path referenced here is from the plan document, not verified on disk.
Adapt before installing; run the verification steps.

## Read first

`PLAN-v2.md` — the revised plan. Start there.

## Contents

| File | Install as | Purpose |
|---|---|---|
| `PLAN-v2.md` | — | Revised plan, supersedes v1 |
| `templates/dot-ignore` | `<DCLA-root>/.ignore` | Search ignore (verify first) |
| `templates/CLAUDE.md.drug-price-pilot` | `<drug-price-pilot>/CLAUDE.md` | Context router, 55 lines |
| `templates/AGENTS.md.drug-price-pilot` | `<drug-price-pilot>/AGENTS.md` | Pointer only |
| `templates/V94-R1-ERRATA.md` | `<drug-price-pilot>/V94-R1-ERRATA.md` | Seal fix, additive |
| `templates/MANIFEST-CLASSES.md` | alongside release tooling | Generator fix (prevention) |
| `scripts/verify-ignore-is-honoured.sh` | `<project>/scripts/` | **Run before installing `.ignore`** |
| `scripts/check-doc-budgets.sh` | `<project>/scripts/` | Budget enforcement |
| `scripts/peek.sh` | `<project>/scripts/` | Safe data-file inspection |
| `archive/superseded PLANFORCLAUDEREVIEW archive.md` | — | Original v1 plan |

## Install order

1. `scripts/verify-ignore-is-honoured.sh <a-project-subdir>` — fix if it fails.
2. Install `.ignore`, `CLAUDE.md`, `AGENTS.md`, and the scripts.
3. Follow `templates/V94-R1-ERRATA.md` § "Order of operations" for the seal
   fix and README compaction. Snapshot and verify SHA-256 **before** replacing
   the root README.
4. Apply `templates/MANIFEST-CLASSES.md` to the release generator.

## Scripts were tested

`check-doc-budgets.sh` and `peek.sh` were run against synthetic fixtures in
this session: the budget script correctly flags an over-length README and
CLAUDE.md, correctly prunes `node_modules`, and exits 0 on a compliant tree.
`verify-ignore-is-honoured.sh` was syntax-checked only — it needs a real
ripgrep-on-DCLA run to be meaningful.
