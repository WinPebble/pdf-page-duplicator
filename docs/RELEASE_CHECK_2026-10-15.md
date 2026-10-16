# Pre-certification check — 2026-10-15

## Submission completed

Owner subsequently explicitly confirmed the separate Submit action. Submitted
version 1.0.1.0 in Submission 1152921505702072587 for product 9N28GX9HTL9Z.
Observed In certification, Submission Complete, Pre-processing In progress,
Certification/Publishing Not started, and the message that publication starts
as soon as certification passes. Public audience and automatic publication are
owner-authorized. No claim of certification success or public availability yet.
Saved local proof submitted-in-certification.png. No PR merge or website deploy.
The prior blocked attempt below is historical.

## Latest owner decision

Owner requested public release with no further testing; unresolved patched
Windows 10 and Store-delivery checks remain unverified, but are no longer
owner-required pre-release gates. Saved Public audience and Publish as soon as
certification passes. Automatic action review blocked the attempted Submit for
certification, citing the earlier separate-confirmation restriction; requested
explicit Submit confirmation. Submission remains a draft. No PR merge or website
deployment was performed. Prior private/manual-hold records below are historical.

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
USD 0, and organizational acquisition disabled. After the owner supplied the
intended Store account, created `WinPebble Page Duplicator Private Testers`
(group ID 1152921504607280733) with exactly one member and selected/saved it
in Submission 1. Reopened Availability and verified the group remains checked,
Private audience selected and automatic public date unchecked. Personal email
is retained only in Partner Center/local proof, not in public repository docs.
Overview now reports every section Complete and Submit for certification enabled.
The prior manual Publish now hold remains unchanged.

Local portal proof and Unicode UI screenshots are under
artifacts/release-check-2026-10-15 and are not committed to the public repository.

## Remaining gates

1. Completed: owner supplied Store account; tester group created/selected/saved.
2. Owner runs patched retest kit on Windows 10 22H2 x64 and confirms launch,
   right-click preselection, four exports, progress and success. Earlier f9b068f
   Windows 10 results remain valid only for that older binary.
3. Obtain explicit authorization before certification submission.
4. After certification, obtain explicit private publishing authorization; test
   actual Store installation, menu, export, update/uninstall on both systems.
5. Public release, website publication and PR #2 merge need separate approval.
