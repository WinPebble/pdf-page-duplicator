# Pre-certification check — 2026-10-15

No certification submission, publication, website deployment or PR merge.

## Exact candidate and local checks

The uploaded 1.0.1.0 MSIX still hashes to
`a8c6f335b5422b2d78e93c6f94435d10bf0f01aa45fb6f5e4a99b3550873febb`.
Its staged, security-patched engine passed 20 geometry checks and all 15 cases
in tests/verify_poc.py. PyMuPDF 1.26.7 was installed only into the ignored
artifacts/release-check-2026-10-15/python-deps test directory, not the product.
The first validator attempt lacked PyMuPDF; a subsequent sandbox temp-directory
permission error was resolved by using the workspace artifact directory for
TEMP/TMP. The completed validator run passed without product changes.

On the local Windows 11 host (build 26300), the staged WPF binary loaded a PDF
from its command-line argument. All four combinations of 2/4 copies and
Portrait/Landscape exported successfully through the UI. Observed initial 0%
and final 100% progress and a successful saved-file modal for each export.
No claim is made that every intermediate percentage was visually sampled.

Replaced the previously registered f9b068f PreviewDev package with the patched
development layout at artifacts/store-ready-fa0e05c/development/Package using
the existing unregister/register helpers. Developer Mode was already enabled;
no security settings, certificates, default association or Explorer restart
were changed. Development identity remains version 1.0.0.0, distinct from the
uploaded Store identity/version 1.0.1.0; compiled files have the same provenance.

Right-clicked `Bản thử Unicode.pdf` in the real Explorer menu and selected Page
Duplicator. The app opened with that exact file preselected and no automatic
export. Selecting Create PDF produced a successful modal and 100% progress.
Independently checked all four direct UI exports and this Unicode export with
the existing PyMuPDF validator: page counts, copy counts, paper dimensions,
text/vector retention all passed. Both input hashes still match the source.

The patched PreviewDev registration is retained for owner testing. Keep its
Package directory in place until unregistering it. This is not Store delivery
or a Smart App Control enabled Store installation test.

## Partner Center

Completed the IARC questionnaire as All Other App Types, with No for all nine
content/interaction/online/restricted-product/location/purchase/reward/browser/
news questions and No for direct-board ratings/physical distribution.
Generated Microsoft, IARC and PEGI 3+; ESRB and USK Everyone; other shown systems
All ages. The owner explicitly confirmed adulthood and agreement to IARC terms
at action time. Saved and observed Age ratings Complete on the product overview.
Current Rating ID is Pending, not a claim of certification approval.

Availability remains Private audience, automatic public date unchecked, free
USD 0, and organizational acquisition disabled. No selected tester group.
The Customer groups page shows no existing group entries. Requested the owner's
intended Store Microsoft account/group; selection is pending that response.
The prior manual Publish now hold remains unchanged.

Local portal proof and Unicode UI screenshots are under
artifacts/release-check-2026-10-15 and are not committed to the public repository.

## Remaining gates

1. Owner supplies intended Microsoft Store tester account(s); create/select group.
2. Owner runs patched retest kit on Windows 10 22H2 x64 and confirms launch,
   right-click preselection, four exports, progress and success. Earlier f9b068f
   Windows 10 results remain valid only for that older binary.
3. Obtain explicit authorization before certification submission.
4. After certification, obtain explicit private publishing authorization; test
   actual Store installation, menu, export, update/uninstall on both systems.
5. Public release, website publication and PR #2 merge need separate approval.
