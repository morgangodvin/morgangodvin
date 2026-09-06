# V94 R1 — manifest errata

Install at the Drug Price Pilot project root as `V94-R1-ERRATA.md`.

Status: **errata only.** This document does not modify, regenerate, or
invalidate the V94 R1 terminal handoff manifest or any hash it records. The
original seal remains authoritative exactly as issued.

Last updated: 2026-09-06

## Defect

The V94 R1 terminal handoff manifest classifies the project root `README.md`
as a core, hash-pinned release member. That is a category error: the root
README is a living operational document that must be edited as the project
changes. Pinning it makes the seal and the document mutually exclusive —
either the seal breaks or the README freezes permanently.

This is a defect in the manifest's *classification* of one entry. It is not a
defect in the sealed content, and no recorded hash is wrong.

## Recorded facts

- Sealed root `README.md` size at V94 R1: **130,178 bytes**
- Sealed SHA-256:
  `5f5ce6593ab5ef891b28b463fd8e6a26bf9227fb06c68f3ee81fd5f5a8aa32cb`
- After a refactor exposed the mismatch, the live root README was restored
  byte-for-byte to the sealed version and its SHA-256 re-verified as matching.

## Resolution

1. The sealed byte-state is preserved, unmodified, as an immutable snapshot at:

   `history/README-V94R1-SEALED-5f5ce659.md`

2. **For any verification of the V94 R1 manifest's `README.md` entry, that
   snapshot path is the verification target.** The manifest's recorded hash
   verifies against the snapshot and will continue to do so permanently.

3. The project root `README.md` is hereby declared a **companion** artefact:
   mutable, listed in release documentation for reference, and not
   hash-verified.

4. No hash, signature, or manifest file from V94 R1 is edited. This errata is
   additive.

## Verification procedure

```sh
shasum -a 256 history/README-V94R1-SEALED-5f5ce659.md
# must print:
# 5f5ce6593ab5ef891b28b463fd8e6a26bf9227fb06c68f3ee81fd5f5a8aa32cb
```

If that matches, V94 R1 verifies. The root `README.md` is out of scope for
verification from this errata forward.

## Order of operations when adopting the compact README

Do these in order. Step 1 must complete and verify before step 3.

1. Copy the current (restored, sealed-identical) root `README.md` to
   `history/README-V94R1-SEALED-5f5ce659.md`.
2. Run the verification procedure above. **Stop if it does not match.**
3. Add this errata file at the project root.
4. Promote the compact draft from
   `history/README-COMPACT-DRAFT-2026-09-06.md` to the project root as
   `README.md`, re-checking every relative project link in its destination
   context rather than its draft location.
5. Move the dated September 3–4 coordination sections out of the promoted
   README into a dated file under `history/`. Do this at adoption, not later.
6. Run `scripts/check-doc-budgets.sh` and confirm a clean pass.

## Prevention

See `MANIFEST-CLASSES.md`. Fixing this instance without fixing the manifest
generator guarantees the same defect in the next release.
