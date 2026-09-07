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
7. **v1's inherited-privacy claim is dropped.** v1 line 105 directed the router
   to "preserve DCLA privacy and aggregate-output rules inherited from the
   parent project." Morgan confirms Drug Price Pilot inherits no such rules and
   that individual-level identifiers are permitted. The claim was wrong in v1
   and is removed, not softened. Do not reintroduce it.

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

## Phase 0 — the finding that outranks everything above

Added 2026-09-06 after measuring the live tree. This displaces the `.ignore`
as the highest-value action.

**Measured, not assumed.** `drug-price-pilot` enumerates 30,240 files. Only
119 of them (0.4%) are generated/vendored, so the `.ignore` recovers almost
nothing there. The cost is elsewhere:

- ~9,900 image files (8,878 png, 840 webp, 195 jpg). No HEIC — these are
  machine-generated, not photographs.
- 11,400 data files (5,709 csv, 5,592 json, 111 tsv) — authoritative, must
  stay searchable.
- 22,365 files (74% of the project) live under `incoming/`.

**One directory holds 7,036 of them:**
`incoming/CENSUS-CLUSTER-051-DPP-B96-S001-PRIMARY-REVIEW-20260905/_superseded`

6,319 of those files are byte-identical copies of one failed render
(`_superseded/pre-A011/raw/pdftohtml-fragments/`, sha1 `72a37e01...`). It is
the debris of a retry loop that ran four to five hours on 2026-09-05. Sibling
clusters hold 46-177 files each. Morgan confirms the runaway.

DCLA-wide, **~10,400 files are already marked dead** by the existing
`_quarantine` / `_superseded` convention: 8,496 matching "superseded", 1,888
matching "quarantine", 17 "deprecated". The convention is sound. Nothing
purges it.

### Bucket A — trash now, unambiguous

`Drug Checking History/drug-price-pilot/incoming/CENSUS-CLUSTER-051-DPP-B96-S001-PRIMARY-REVIEW-20260905/_superseded`
(7,036 files). Retain one copy of the failed render as evidence of the
incident; 6,319 copies document it no better than one does. This single
deletion cuts the project's file count ~23% and is lower-risk than every item
in the disk-cleanup section.

### Bucket B — ask Morgan first, creative assets

Superseded image generations under project `_quarantine` directories:
`meet-the-tranqs-carousel` (813), `video-character-elements` (290),
`supply-report-social-2026-09` (238), `poppy-drug-checking-reel` (66),
`drug-checking-history-p2-carousel` (35), and the smaller tails.

These are discarded generations, not machine debris, and Morgan reviews image
options via contact sheet. Build a contact sheet before trashing any of them.

### Bucket C — do not touch in this pass

`site-mockups/_quarantine` and both `site-mockups/.claude/worktrees/*/
_quarantine` directories. Website work is out of scope and another session is
active there.

### Ignore images, never ignore data

A PNG can never be a text search hit, and ripgrep already skips binaries
during content search, so the cost of images is pure enumeration. Ignoring
them is free:

    **/*.png
    **/*.webp
    **/*.jpg
    **/*.jpeg
    **/*.svg
    **/*.pyc
    **/*.gz
    **/*.bin

The 11,400 csv/json/tsv files must NOT be ignored — they are authoritative
inputs and searching them is legitimate. Their risk is an agent reading one
whole, which is what `peek.sh` and the router's never-read-data-files-whole
rule exist to prevent. On this evidence that rule is the single highest-value
line in the router.

### Prevention — scratch discipline and a bloat guard

The runaway wrote 7,036 files into an authoritative inbound directory. Neither
v1 nor this plan's earlier sections addressed that failure mode.

1. Agent intermediates go to `.scratch/<run-id>/`, which is in `.ignore` and
   purgeable wholesale. Nothing writes intermediates into `incoming/`.
2. Only a deliberate promotion step moves a finished artefact into `incoming/`.
3. `scripts/check-dir-bloat.sh` flags any directory over 500 immediate files
   and reports its most-repeated file hash. At 500 it would have tripped within
   minutes of the loop starting rather than after four hours.
4. `_quarantine` and `_superseded` get a retention window. The same script
   lists any older than 30 days. The convention already exists; it just needs
   something that empties it.

## Order of work

### Phase 1 — free wins, no blockers

**1.1 Install the ignore at BOTH the DCLA root and each project root.**

Empirically confirmed 2026-09-06: ripgrep honours an `.ignore` located in the
directory being searched, unconditionally. Discovery of a *parent* `.ignore`
is not reliable when the tree is not a single Git repository, which DCLA is
not. So the per-project copy is the mechanism that actually works; the
DCLA-root copy is a convenience for searches started at the root.

    cp templates/dot-ignore "<DCLA-root>/.ignore"
    cp templates/dot-ignore "<each-active-project-root>/.ignore"

Then verify from a project subdirectory with
`scripts/verify-ignore-is-honoured.sh <dir>`. That script requires ripgrep and
exits 2 rather than reporting a pass if ripgrep is missing.

**Ripgrep availability.** `rg` is not on Morgan's shell PATH (`brew install
ripgrep` to add it). This does not neutralise the `.ignore`: Claude Code ships
its own bundled ripgrep for its search tool, which honours `.ignore` files
regardless of what is on PATH. Installing `rg` is about being able to verify
that behaviour, and about Morgan's own shell searches. Whether Codex or other
agents honour `.ignore` is unverified and should not be assumed.

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
