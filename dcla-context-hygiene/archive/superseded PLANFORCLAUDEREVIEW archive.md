# DCLA context-hygiene plan — for Claude review

Date: 2026-09-06

## Objective

Reduce routine context and token consumption without a risky physical reorganization of
DCLA. Disk cleanup is secondary. Large media, archives, and dependencies do not consume
model context merely by existing; they matter when broad tools enumerate or open them.

## Decisions already made by Morgan

- Give Drug Price Pilot its own Codex project while leaving its files at the existing path.
- Do not physically move Drug Price Pilot into Data Scrape Drugs and Arrests now.
- Compact the Drug Price Pilot README after V94 completes. V94 is now complete.
- Website Git/worktree resolution is being handled separately with Claude; do not touch it.
- Do not compact the two unpublished reel READMEs yet.
- Retire completed Claude Science transfer packages.
- Remove the six Photos verification-cache video copies after second-device confirmation.
- Preserve the unique CADOJ workbook builder, then remove the large inspection artifacts.

## Completed safely in this pass

### Drug Price Pilot README draft and V94 seal issue

An approximately 404-line / 26 KB compact README draft is preserved at
`history/README-COMPACT-DRAFT-2026-09-06.md`. The 1,663-line reverse-chronological
B1232–B1457 research diary is also preserved under
`history/research-log-B1232-B1457/` in four parts plus an index.

The draft is staged under `history/` only to avoid changing the sealed root file. Its
relative project links are intended for eventual promotion to the project root as
`README.md`; review them in that destination context rather than treating the draft's
temporary location as canonical.

The compact draft would reduce default README context by about 80%, but it is **not live
yet**. V94's terminal handoff manifest incorrectly treats the mutable root `README.md`
as a core hash-pinned release member. After the refactor exposed that mismatch, the live
README was restored byte-for-byte to its sealed 130,178-byte version. Its SHA-256 again
matches V94 exactly:

`5f5ce6593ab5ef891b28b463fd8e6a26bf9227fb06c68f3ee81fd5f5a8aa32cb`

Claude should design a post-seal documentation-maintenance addendum or equivalent fix
that preserves the original V94 seal and its README snapshot without requiring a mutable
project README to remain frozen forever. Do not silently regenerate or overwrite the
authoritative V94 seal. After that is reviewed, adopt the compact draft and consider
moving its remaining dated September 3–4 coordination sections into a second history
file to bring the live README below 250 lines.

### Inspection artifacts

The unique CADOJ workbook builder was promoted from scratch space to:

`millennium-research-concepts/public-records-responses/CADOJ-BFS-01_CA-DOJ-26-1810/scripts/build_declared_substances.mjs`

It passes `node --check`; its canonical project README now documents it. The only byte
difference from the scratch copy is a final newline added by the patching tool.

Three regenerable `*.inspect.ndjson` files totaling about 436 MiB were moved to
recoverable macOS Trash. Final workbooks, reports, and preview images remain.

### Photos verification cache

Two verification-export copies each of `Skydive.MP4`, `GX013533.MP4`, and
`GX013536.MP4` were moved to recoverable Trash after all six were SHA-256 matched to
both the canonical Personal copy and the iCloud Drive copy. Morgan separately confirmed
availability on a phone. Logical size moved: about 1.91 GiB.

### Claude Science transfers

Completed outbound September 3–4 transfer directories and ZIPs were moved to recoverable
Trash. Canonical local datasets, incoming returns, the DPP collection-round export,
source-identity review, audit ledgers, small session logs, and current V94 release remain.
Logical size moved: about 602 MiB.

All removed material is currently recoverable at:

`/Users/morgangodvin/.Trash/DCLA-context-cleanup-2026-09-06/`

Disk space is not reclaimed until Morgan empties Trash.

## Highest-return next actions

### 1. Register Drug Price Pilot as its own Codex project

Use the existing folder directly:

`/Users/morgangodvin/Claude Code/DCLA/Drug Checking History/drug-price-pilot`

Do not move the folder. This creates a narrow default search/context boundary without
breaking absolute paths, active research handoffs, manifests, or sibling-data references.
Data Scrape Drugs and Arrests is now a separate Codex project with another active task;
keep it separate unless a later migration is explicitly designed.

### 2. Add a short project-local context router

After review, add a concise project-local `CLAUDE.md` and an `AGENTS.md` pointer that:

- identify V94 R1 as the current authoritative internal release;
- direct dashboard work to the V94 internal-analysis README and data;
- direct research continuation to the newest research-log entry only when needed;
- direct schema/method work to the relevant protocol files;
- prohibit reading the archived 1,663-line diary by default;
- preserve DCLA privacy and aggregate-output rules inherited from the parent project.

Keep the router under roughly 60 lines and free of per-run status updates.

### 3. Add a conservative root search ignore

DCLA is not a single Git repository and currently has no root `.ignore`. Add one for
tools such as ripgrep:

```gitignore
**/node_modules/
**/.venv/
**/venv/
**/__pycache__/
site-mockups/.claude/worktrees/
**/*.inspect.ndjson
```

Do not globally ignore ZIPs, CSVs, PDFs, `dist/`, or all `.claude/` content. Those can
be authoritative research inputs, tracked website output, or operational handoffs.
Agents can use `--no-ignore` for intentional forensic searches.

### 4. Enforce documentation budgets

- Project README: current state, entry points, commands, blockers, and canonical outputs;
  target no more than 250 lines or 25 KB.
- CLAUDE.md / AGENTS.md: durable invariants only; target no more than 100–150 lines.
- Per-run chronology: dated files under `history/`, `logs/`, or an existing event
  ledger—never an indefinitely appended README.
- Large handoffs: one concise current handoff plus immutable dated history.
- Before reading a large text file, agents should inspect byte count and headings, then
  open only the relevant section.

## Low-risk generated-file cleanup for Claude to review and execute

1. Delete the 14 lock-backed primary `node_modules` trees, about 1.23 GiB total.
   Restore npm projects with `npm ci`, not generic `npm install`; restore pnpm
   projects with `pnpm install --frozen-lockfile`. Most projects pin packages but not
   the Node/package-manager runtime, so promise pinned dependency versions rather than
   byte-identical cross-platform installs.
2. Delete standalone `__pycache__` trees, about 8.3 MiB.
3. Delete the drug-arrests explorer `.venv`, about 91 MiB. It is already reproducible
   from its hashed `uv.lock`, pinned `pyproject.toml`, Python constraint, and launcher.
4. For `analysis-code/mortality-2026-09-03/.venv`, first save the 14-package
   `pip freeze` output and record Python 3.13.13. Then delete the roughly 254 MiB venv.
5. Treat nested `.vercel/output` as a separate build-cache decision; it is not one of
   the independently lock-backed installs.

## Context-bearing documents found in the audit

| File | Size | Recommendation |
|---|---:|---|
| Drug Price Pilot README | live: 2,059 lines / 130 KB; draft: 405 lines / 26 KB | Review seal-safe adoption of compact draft |
| site-mockups README | 882 lines / 55 KB | Website work is out of scope here |
| rubber-shortage-carousel README | 773 lines / 42 KB | Defer; unpublished project |
| poppy-intro-reel README | 549 lines / 34 KB | Defer; unpublished project |
| hollywood-street-outreach README | 475 lines / 27 KB | Later candidate for history extraction |
| keyframes-v4 README | 413 lines / 24 KB | Later candidate; not automatically loaded at DCLA root |

Root and parent DCLA workshop instructions are not the problem: together they are only
about 10 KB. Duplicate CLAUDE/AGENTS files in old reel projects are also low priority
because only path-relevant instructions are normally loaded.

## Explicitly deferred

- Website worktrees, branches, merge, and deployment.
- Rubber-shortage and Poppy-intro reel documentation.
- Broad deletion of `.codex-work`, `tmp`, or all ZIPs.
- Deduplication of research PDFs and provenance snapshots.
- Physical relocation of Drug Price Pilot or Data Scrape Drugs and Arrests.

Exact duplicate media and research files are a future disk-hygiene issue, not a current
token-limit issue. Review them only when storage or canonical-copy management becomes a
priority.

## Claude review checklist

1. Resolve the mutable-README pinning defect without mutating or invalidating the original
   V94 terminal seal.
2. Confirm the compact Drug Price Pilot draft still exposes every current V94 entry point,
   blocker, canonical table, and required command.
3. Confirm the archived diary parts preserve all 1,663 source lines in order.
4. Challenge any proposed root-ignore pattern that could conceal authoritative inputs.
5. Confirm the CADOJ promoted builder belongs in the canonical project and no additional
   scratch-only build dependency must be retained.
6. Execute generated dependency cleanup only when no install/build is active.
7. Do not touch the website or the two unpublished reels in this cleanup.
