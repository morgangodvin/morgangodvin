# Release manifest classes — generator fix specification

Install alongside the release tooling. This is the change that prevents the
V94 R1 defect from recurring.

Last updated: 2026-09-06

## Root cause

The V94 R1 manifest almost certainly enumerated release members by **globbing
the project root** rather than reading an explicit list. A glob cannot
distinguish a frozen deliverable from a living operational document, so the
root `README.md` was swept into the hash-pinned core set.

An errata fixes one instance. Only a generator change fixes the class.

## The two classes

**core** — explicitly enumerated, hash-pinned, immutable after seal.
Data exports, analysis outputs, protocol/schema files at their sealed
revision, the manifest itself. If a core member must change, that is a new
release, not an edit.

**companion** — listed for reference, mutable, **not** hash-verified.
`README.md`, `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING`-style docs, any file
whose job is to describe current state rather than record a frozen result.

## Required generator changes

1. **No globbing for `core`.** Core members come from an explicit list in a
   release-definition file. A file not named there is never core.

2. **Deny-list guard.** Refuse to seal, with a hard error naming this
   document, if any of these lands in `core`:
   `README.md`, `README`, `CLAUDE.md`, `AGENTS.md`, `CHANGELOG.md`,
   `TODO.md`, `NOTES.md`, or any path under `history/`, `logs/`, `tmp/`,
   `.codex-work/`.

3. **Snapshot instead of pin.** When a companion document's state at seal time
   is worth preserving, the generator writes an immutable snapshot to
   `history/<NAME>-<RELEASE>-SEALED-<sha8>.<ext>` and pins **that path**.
   The living file is never the pin target.

4. **Manifest schema carries the class.** Every entry records
   `class: core | companion`. Verification tooling hashes `core` entries only
   and reports `companion` entries as informational.

5. **Verifier honours the class.** A companion entry whose live file has
   changed is not a verification failure. Today's tooling would report it as
   one; that is the behaviour to change.

## Migration

Existing sealed releases are not regenerated. Add an errata (see
`V94-R1-ERRATA.md`) for each release that pinned a companion document, and
apply the generator changes from the next release forward.
