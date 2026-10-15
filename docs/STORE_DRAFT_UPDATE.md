# Submission 1 draft update record — 2026-10-14

Product 9N28GX9HTL9Z, Submission 1152921505702072587. Owner explicitly authorized
replacing the draft package with SHA-256 d2f87f1cb020daf667378dcfb8a42ec1c93e29bd776aadd1398b3ee667d3f3a6,
uploading four prepared screenshots and saving the copy in STORE_SUBMISSION_READY.md.
No certification, private/public publication, website publication or PR merge.

The owner subsequently explicitly authorized upload of the replacement 1.0.1.0
file with SHA-256 a8c6f335b5422b2d78e93c6f94435d10bf0f01aa45fb6f5e4a99b3550873febb.
That upload and Save are now complete. The saved draft contains only this new
package; old-package retention described below is historical to the first attempt.

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
- Uploaded the exact authorized 1.0.1.0 file. Overview reports Validated and
  Packages Complete. Reopened Packages shows one package, version 1.0.1.0 x64,
  minimum OS 10.0.19045.0, with the old 1.0.0.0 package gone.
- Saved the approved 403-character runFullTrust justification in the formal
  Restricted capabilities field, including the native Explorer command. The
  runFullTrust approval warning remains pending certification.

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

## Uploaded replacement provenance

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
this version-only repack. The exact locally repacked file was subsequently
owner-authorized, uploaded and saved to the draft.

## Portal recovery during the approved 1.0.1.0 upload

The original tab stayed at Analyzing package 99% and later showed
Status: OK, FaultCode: undefined. No forced button activation, hidden API or
validation bypass was used. A separate tab was recovered through the normal
Home -> Apps and games -> product -> Packages UI. It showed the uploaded
1.0.1.0, automatic removal of the superseded package and an enabled Save button.
Saved there, observed the overview's Validated/Complete state and reopened
Packages to verify persistence. Closed the stale original upload tab.

Local proof is retained under artifacts/store-version-1.0.1.0/portal-proof;
account screenshots are not committed to the public repository.

## Remaining

Update 2026-10-15: Age ratings are now Complete after the owner confirmed the
IARC terms/adulthood and the generated ratings were saved. Patched Windows 11
UI exports and Unicode Explorer activation/export passed; see
[pre-certification check](RELEASE_CHECK_2026-10-15.md).
Tester account/group selection, patched Windows 10 manual checks and Store
delivery tests on both systems remain pending.
Obtain separate certification/private publishing authorization only after the
remaining draft gates are complete. PR #2 and website remain unpublished.
