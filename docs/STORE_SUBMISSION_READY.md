# Current Store submission copy and review gates

Prepared 2026-10-14. Owner authorized the specified package, four screenshots
and copy update to Submission 1. Listing copy/features/four captioned Desktop
screenshots were saved; Store listings is now Complete. Updated certification
testing notes were saved and verified by reopening. Private audience and manual
publishing hold remain unchanged. No certification/publication or PR merge.

The approved 1.0.0.0 MSIX upload was rejected for a duplicate package full name
with different contents. The failed upload was deleted and pending removal of
the old package was reverted. The old package remains in the draft. A version
1.0.1.0 candidate is prepared locally; it has NOT been uploaded or authorized
for upload yet. See [draft update record](STORE_DRAFT_UPDATE.md).

## Candidate and security

Source candidate: fa0e05c7361fbadd97c98bb51c851875cd4e7f08.
Actual PR workflow checkout: 7614acd08e61741394d5f563aae2d41938d1e8ce
(temporary merge checkout of the candidate with main 47ae127; PR #2 is unmerged).
Exact downloaded MSIX SHA-256:
`d2f87f1cb020daf667378dcfb8a42ec1c93e29bd776aadd1398b3ee667d3f3a6`.
The downloaded hash and all 17 extracted file hashes match PACKAGE-INSPECTION.json.
Store MSIX/packaged engine checks: https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38589727197
Development/native/helper checks: https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38589727169
Core PDF tests: https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38589727165
WPF build: https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38589727217
All four workflows passed. Retain PACKAGE-INSPECTION.json, SHA256SUMS.txt and
DEPENDENCY-INSPECTION.json with the exact downloaded MSIX before approving upload.

PDFsharp remains 6.2.4. Both apps explicitly resolve PKCS 8.0.2 and bundle runtime
10.0.13. The packaging gate checks resolved graphs and generated self-contained
runtime configs. NuGet audit includes transitive dependencies and NU1901-NU1904
fail the build. See [security change](RELEASE_SECURITY.md).

The owner tested the earlier f9b068f binaries with the Windows 10 manifest and
PS5.1 helper fix on Windows 10 Pro 22H2 build 19045.7725, and the UI/menu/export
on Windows 11. The security-patched candidate has new binaries: earlier manual
results must not be reported as tests of these exact new files. Recheck launch,
right-click activation and all four exports on both machines before final release.
Store signing/delivery, update and final uninstall remain separate gates.

## en-US listing

Short description:

Repeat each PDF page 2 or 4 times on one sheet, with local processing.

Description:

WinPebble PDF Page Duplicator creates a new PDF with two or four copies of each
original page on its own output sheet. Choose Portrait or Landscape and check
the proportional layout diagram before creating the file.

Start from the app or right-click one PDF in File Explorer and choose Page
Duplicator. The window opens with that PDF already selected. Choose your
settings, select Create PDF, follow the progress percentage and receive a
confirmation when the output has been saved.

The output keeps the original paper's physical dimensions in the selected
orientation. Copies scale proportionally without distortion. A document with
N pages produces N output pages. The original PDF stays untouched, and output
names avoid overwriting existing files.

Processing happens on your computer. No PDF upload, app account, advertising,
analytics or background service is required. Text and vector content are reused
where supported, without rasterizing entire pages.

Requirements: Windows 10 version 22H2 or later, or Windows 11; x64 processor.
The runtime is included. Earlier Windows 10 versions, x86 and native ARM64 are
not supported by this package.

Limitations: rotated pages, cropped pages and non-default page origins are
rejected. Preview diagrams show the first page's proportions, not PDF content.
Interactive links, annotations and forms are not guaranteed to be preserved.
The Explorer command accepts one PDF at a time. You need write access to the
input folder to save the output alongside the original.

Features:
- Two or four copies of each original page on one output page.
- Portrait and Landscape with proportional scaling and original paper size.
- Right-click a PDF to open the app with that file selected.
- Progress percentage and saved-file confirmation.
- Local processing; original files preserved; collision-safe output names.

Support: https://github.com/WinPebble/pdf-page-duplicator/issues
Privacy: use the existing docs/PRIVACY.md text; no changed data collection.

## Restricted capability justification (403 characters; maximum 500)

Packaged WPF utility processing PDFs locally at standard user integrity. runFullTrust launches the UI and bundled PDF engine to read a selected PDF and save a new PDF beside it without overwriting. A packaged native IExplorerCommand adds Page Duplicator to the PDF context menu and opens the UI with that file selected. No admin elevation, service, uploads, analytics or default PDF association changes.

## Certification testing notes

Desktop utility for local PDF processing; no app login or credentials required.
runFullTrust supports standard-user WPF and bundled engine execution. The native
packaged COM IExplorerCommand registers only a PDF context-menu verb. It performs
no conversion inside Explorer, launches the adjacent UI and exits without
waiting for conversion. It does not change the default PDF association or add
a service. No elevation or internet connection is needed to process documents.

Install on Windows 10 22H2 x64 or Windows 11 x64. Launch from Start, choose a PDF
with unrotated pages/default page boxes and a writable source folder. Test
2/4 copies and Portrait/Landscape. Select Create PDF; verify progress, success
confirmation and a new PDF beside the source, with one output page per source
page. Existing files and the original must remain unchanged. Repeated exports
use numbered collision-safe output names.

Close the window. Right-click one PDF -> Page Duplicator; confirm the same UI
opens with the correct PDF loaded without a file chooser or automatic export.
Include a filename with spaces and Unicode. The command hides/rejects folders,
non-PDFs and multiple selections. Corrupt/unsupported files should report an
error without a success confirmation. Uninstall and confirm the menu disappears
while PDFs and other WinPebble apps remain.

Private-audience testers must acquire through the authorized Microsoft account;
this is Store acquisition, not an app-specific account requirement. Reviewers
must not be told that Store installation has already passed.

## Screenshots and age-rating preparation

Four native application captures are prepared locally in
artifacts/store-ready-fa0e05c/screenshots, each PNG 1920x1152, showing the four
layouts with the nonsensitive fixture Source_Letter_Landscape_2Pages.pdf.
Native captures were returned as JPEG and encoded to PNG without cropping,
resizing, retouching, overlays or changing UI content; originals are retained.
They show the previously tested f9b068f UI. MainWindow.xaml and MainWindow.xaml.cs
are unchanged between f9b068f and fa0e05c. They are actual UI screenshots, not
evidence that the patched candidate was manually installed or that PDF content
is rendered in the preview. Owner approval and portal validation are pending.

Captions (each under 200 characters):
1. Two copies of each page on a portrait sheet, with proportional scaling.
2. Two copies of each page on a landscape sheet.
3. Four copies of each page on a landscape sheet.
4. Four copies of each page on a portrait sheet.

Age-rating questionnaire facts: utility, no bundled mature/violent/sexual
content, gambling, purchases, ads, user-to-user communication, online content
sharing, location tracking or social network. Users open their own local PDF
documents; arbitrary user document content is not bundled content. Answer the
actual questionnaire using these facts; do not invent a rating or mark the
portal section Complete without observing its result.

## Ordered next actions

1. Review exact MSIX hash, dependency inspection, screenshots and this copy.
2. Obtain owner authorization for replacing the old draft package and uploading
   screenshots/saving updated text; retain Private audience/manual hold.
3. Select a known tester group with personal Microsoft accounts and finish age
   ratings. Recheck every portal section and runFullTrust review status.
4. Obtain explicit certification authorization; submit only when complete.
5. After certification, obtain explicit private publishing authorization; install
   from Store on both machines and perform final package tests, including SAC
   enabled on the supported Windows 11 test environment.
6. Only after those results and separate approval: merge PR #2, public Store
   visibility/publication, and website publication together.
