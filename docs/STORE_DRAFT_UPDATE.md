# Submission 1 draft update record — 2026-10-14

Product 9N28GX9HTL9Z, Submission 1152921505702072587. Owner explicitly authorized
replacing the draft package with SHA-256 d2f87f1cb020daf667378dcfb8a42ec1c93e29bd776aadd1398b3ee667d3f3a6,
uploading four prepared screenshots and saving the copy in STORE_SUBMISSION_READY.md.
No certification, private/public publication, website publication or PR merge.

## Completed and verified

- Saved en-US description covering Windows 10 22H2/Windows 11 x64, Explorer
  startup, explicit export, progress/success and actual limitations.
- Saved five product features and four Desktop screenshots with matching
  captions. Overview reports Store listings Complete.
- Saved updated Additional Testing Information and reloaded it to verify
  persistence. Notes explain packaged COM/Explorer and standard-user engine
  execution, without falsely claiming Store installation passed.
- Read-only verification: Private audience selected, automatic public date off,
  free USD 0, organizational acquisition disabled. No tester group selected.
- Read-only verification: Don't publish until I select Publish now is selected.

## Package collision and safe restoration

The new package completed upload but Partner Center rejected it:
"All .msix and .appx packages (including previously published and currently
uploaded) must be uniquely identified by their full names." The full name was
TrungHieuNguyen-WinPebble.WinPebblePDFPageDuplicat_1.0.0.0_X64_. Both old and new
content used that version. Pending removal does not avoid this validation, and
Save is disabled with zero valid packages. No empty-package draft was saved.

Deleted only the rejected upload entry, then reverted the old package removal.
The old validated 1.0.0.0 package (minimum OS 22000) remains in the saved draft.
This is not a successful replacement of the package.

## Prepared replacement requiring review

Manifest source commit: 21a3e1b7a5dd04ccd09b4346715cc76ce8acedc6.
Package version: 1.0.1.0. Name, Publisher, x64 architecture, Windows minimum
19045, capabilities, UI and PDF behavior unchanged. Both manifests and version
validation assertions are updated; packaging filename now matches 1.0.1.0.

Local review package SHA-256:
`a8c6f335b5422b2d78e93c6f94435d10bf0f01aa45fb6f5e4a99b3550873febb`.

Repacked with installed Windows SDK MakeAppx from the exact verified fa0e05c
security-patched Store payload; only AppxManifest.xml Version changes. All eight
EXE/DLL hashes match that payload. Test-StorePackage validates packed manifest,
identity, payload and lack of development signing; the unpacked engine passes
20 geometry checks. The earlier 15-case PDF test results apply to the identical
engine binary, not to an installed 1.0.1.0 Store package.

Four workflows passed for 21a3e1b, independently building from source:
- https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38596792568 (WPF)
- https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38596792209 (core)
- https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38596792171 (development)
- https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38596792237 (Store)

Those independently built artifacts are not asserted to have the same hash as
the locally repacked review file. VERSION-REPACK-PROVENANCE.json records the
separate manifest and compiled-binary sources. No package was installed for
this version-only repack, and neither it nor its new hash has been uploaded.

## Remaining

Obtain approval for the exact 1.0.1.0 replacement hash, then upload/save it and
recheck portal acceptance. Revisit the formal restricted-capability justification
if the portal exposes a request field; the Explorer-aware testing notes are
saved, while the separate 403-character justification remains prepared copy.
Age ratings are Not started; tester group selection is pending. Final patched
candidate manual checks and Store delivery tests on both systems remain pending.
