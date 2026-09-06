# DCLA context-hygiene plan — v2 (post-review)

Date: 2026-09-06
Supersedes: `archive/superseded PLANFORCLAUDEREVIEW archive.md`

## What changed from v1

1. **Dependency deletion is split out of this plan.** It buys zero context and
   is the only place something can be lost. It is now a separate disk task.
2. **`analysis-code/mortality-2026-09-03/.venv` is NOT deleted.** Morgan
   confirmed this analysis is destined for publication. A `pip freeze` does not
   capture index URLs, extras, platform wheels, or build toolchain — insufficient
   for a reproducibility claim that may be challenged. 254 MiB is cheap insurance.
3. **The `.ignore` is expanded** and gated on a verification step, because a
   DCLA-root `.ignore` may not be honoured from project subdirectories (DCLA is
   not a Git repo).
4. **The seal fix now includes a generator change**, not only an errata.
   Otherwise the same defect recurs at the next release.
5. **Three new prevention mechanisms**: a budget-enforcement script, a
   no-dates-in-README rule, and a never-read-data-files-whole rule with a
   `peek.sh` helper so the right way is the easy way.
6. **Two verification steps upgraded from judgement to mechanical checks**
   (diary reassembly; CADOJ builder acceptance).

## Objective (unchanged)

Reduce routine context and token consumption without a risky physical
reorganization of DCLA. Large media, archives, and dependencies do not consume
model context merely by existing; they matter when broad tools enumerate or
open them. Disk cleanup is a separate goal, tracked separately.

## Decisions carried forward from Morgan

- Drug Price Pilot gets its own Codex project; files stay at the existing path.
- No physical move of Drug Price Pilot into Data Scrape Drugs and Arrests.
- Website Git/worktree resolution is handled separately; do not touch it.
- The two unpublished reel READMEs are not compacted yet.
- Completed Claude Science transfer packages are retired.
- Photos verification-cache copies removed after second-device confirmation.
- CADOJ workbook builder preserved; large inspection artefacts removed.

## Order of work

### Phase 1 — free wins, no blockers

**1.1 Verify then install the root ignore.**
Run `scripts/verify-ignore-is-honoured.sh` from a project subdirectory FIRST.
If it fails, apply the `RIPGREP_CONFIG_PATH` fix it prints before installing.
An `.ignore` that is not honoured is worse than none: it creates false
confidence. Install `templates/dot-ignore` as `<DCLA-root>/.ignore`.

Do not add `site-mockups/.claude/worktrees/` yet — it would hide live state
from the session resolving the website worktrees. Add it after that lands.

**1.2 Install the project-local router.**
`templates/CLAUDE.md.drug-price-pilot` → project root `CLAUDE.md` (55 lines).
`templates/AGENTS.md.drug-price-pilot` → project root `AGENTS.md` (pointer only).

**1.3 Install the helper scripts.**
`scripts/peek.sh` and `scripts/check-doc-budgets.sh` into the project's
`scripts/`. Wire the budget check into a pre-commit hook or a weekly cron.

**1.4 Delete standalone `__pycache__` trees** (~8.3 MiB). Fully safe, trivially
regenerable. Negligible gain; included only because it is free.

### Phase 2 — the seal fix and the README compaction

Follow `templates/V94-R1-ERRATA.md` § "Order of operations" exactly. The
snapshot must be written and its SHA-256 verified as
`5f5ce6593ab5ef891b28b463fd8e6a26bf9227fb06c68f3ee81fd5f5a8aa32cb`
**before** the root README is replaced. Then apply the generator changes in
`templates/MANIFEST-CLASSES.md`.

Expected gain: default README context down ~104 KB (130 KB → 26 KB), and below
250 lines once the dated September 3–4 sections move to `history/`.

Never regenerate or overwrite the authoritative V94 seal.

### Phase 3 — deferred consolidation

- Collapse duplicate CLAUDE/AGENTS files in old reel projects to a shared
  parent plus short children. Low context value, but they are a **drift**
  hazard: contradictory instructions surfacing unpredictably.
- Start Claude Code sessions in project directories, not at DCLA root. The
  same reasoning that justifies the Codex project split applies identically
  and costs nothing.
- `hollywood-street-outreach` (475 lines) and `keyframes-v4` (413 lines)
  READMEs: history extraction when convenient.

## Separate task — disk cleanup (NOT context)

Track this apart from context hygiene. Nothing here reduces tokens.

1. **`node_modules` (14 trees, ~1.23 GiB).** Before deleting any tree, check it
   for: a `patches/` directory or `patch-package` in scripts; `resolutions` /
   `overrides` / `pnpm.overrides` in `package.json`; `postinstall` scripts;
   git-URL dependencies; native modules (`sharp`, `canvas`, `better-sqlite3`,
   `puppeteer`, `playwright`). **Keep any tree that has one.** Restore with
   `npm ci` or `pnpm install --frozen-lockfile`, never generic `npm install`.
   Promise pinned dependency versions, not byte-identical cross-platform installs.

2. **drug-arrests explorer `.venv` (~91 MiB).** Reproducible from hashed
   `uv.lock`, pinned `pyproject.toml`, Python constraint, and launcher. Safe.

3. **`analysis-code/mortality-2026-09-03/.venv` (~254 MiB) — DO NOT DELETE.**
   Publication-bound. Retain until publication. Independently of retention,
   record now: `pip freeze`, `pip list --format=freeze`, `python -VV`,
   `uname -a`, and hashes of every installed wheel.

4. **Nested `.vercel/output`** — separate build-cache decision, not a
   lock-backed install.

## Trash retention

~3 GiB currently sits at
`/Users/morgangodvin/.Trash/DCLA-context-cleanup-2026-09-06/`.

Trash is **not a backup**. One Finder "Empty Trash" from any window destroys
all of it at once, and macOS may auto-empty after 30 days if that setting is
enabled. Before that happens:

- Write `RESTORE.md` inside that folder listing every item and its origin path.
- Set an explicit review-and-empty date.
- Confirm the six Photos videos and the CADOJ inspection artefacts are
  represented elsewhere, or accepted as gone.

Disk space is not reclaimed until Trash is emptied.

## Verification checklist — mechanical, not judgement

1. Diary reassembly is a `diff`, not a review:
   `cat history/research-log-B1232-B1457/part*.md | diff - <original>` must
   produce empty output. **Retain the original until this passes.** If the
   original is already gone, this cannot be verified and the plan should say
   so rather than claim it was confirmed.
2. CADOJ builder acceptance is an output diff, not `node --check`. Syntax
   validity does not prove
   `millennium-research-concepts/public-records-responses/CADOJ-BFS-01_CA-DOJ-26-1810/scripts/build_declared_substances.mjs`
   still resolves its inputs from the new location. Run it and diff the
   produced workbook against the existing one. Relative paths and sibling-data
   references are exactly what breaks on promotion out of scratch space.
3. Sealed-snapshot SHA-256 matches before the root README is replaced.
4. `scripts/check-doc-budgets.sh` passes after the compact README lands.
5. `scripts/verify-ignore-is-honoured.sh` passes from at least two different
   project subdirectories.
6. Compact draft exposes every current V94 entry point, blocker, canonical
   table, and required command.

## Explicitly deferred

- Website worktrees, branches, merge, deployment.
- Rubber-shortage and Poppy-intro reel documentation.
- Broad deletion of `.codex-work`, `tmp`, or all ZIPs.
- Deduplication of research PDFs and provenance snapshots.
- Physical relocation of Drug Price Pilot or Data Scrape Drugs and Arrests.

Exact duplicate media and research files are a future disk-hygiene issue, not
a current token-limit issue.

## Do not

- Delete the mortality venv before publication.
- Regenerate, edit, or overwrite the V94 R1 seal or manifest.
- Globally ignore ZIPs, CSVs, PDFs, `dist/` under published sites, or all
  `.claude/` content — these can be authoritative research inputs, tracked
  website output, or operational handoffs.
- Touch the website or the two unpublished reels in this pass.
- Raise a documentation budget instead of moving chronology out of a README.
