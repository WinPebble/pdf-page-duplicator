# Private Microsoft Store preparation

Prepared 2026-10-14. Draft for owner review; no submission or publishing authorization.
Product: WinPebble PDF Page Duplicator. Store ID: **9N28GX9HTL9Z**.

Later development update (2026-10-14): the owner confirmed Windows 11
development UI, Explorer menu activation and export work. The public release
must also support Windows 10 22H2 x64; manifests now allow build 19045, but
Windows 10 development testing was subsequently owner-confirmed as passed on
build 19045.7725, including registration/removal after the PS5.1 helper fix.
Store-delivered installation remains pending. See [compatibility gate](WINDOWS_COMPATIBILITY.md).
Portal observations below describe the older uploaded draft package, which
has not been replaced. New submission text must describe the Explorer command.

## Verified baseline

- Public MIT repository; main `47ae127090fdbb71dfd4da036660f7a15dd342c4`.
- PR #2 open, unmerged; feature baseline `7f3b98e3b796a37967bb1bc3a0ff01ec9fb7a63d`.
- Core, WPF, development MSIX and Store candidate CI all successful for that baseline.
- Shared layout calculator; WPF reads page 1 for diagrams, engine handles each page separately.
- Engine resolved relative to `AppContext.BaseDirectory/Engine`; output written alongside input, not inside package. Installed MSIX execution remains unverified.
- Exact Store identity and approved icon retained. No Explorer extension registration.
- No GitHub releases at audit time.

## Partner Center draft observed 2026-10-14

- Submission 1 is In draft. No certification submission or publishing performed.
- Private audience saved and verified by reopening Pricing and availability.
- Base price USD 0; Make this product public on unchecked; organizational licensing disabled.
- No tester group selected. Pricing and availability remains Incomplete until a group is selected. Create/view group links did not open a form in the connected browser; owner action requested without collecting tester emails in chat.
- Properties saved and marked Complete: category Utilities + tools; privacy declaration covers user-selected documents. Partner Center explicitly includes documents in personal information examples.
- Privacy policy text supplied directly using the portal's supported text option; source retained in [PRIVACY.md](PRIVACY.md).
- Owner explicitly authorized uploading the reviewed MSIX into Submission 1 draft. Package uploaded and saved; overview marks Packages Complete. Portal identifies version 1.0.0.0, x64, Windows.Desktop minimum 10.0.22000.0. No blocking acceptance error shown; warning states runFullTrust requires approval. This is package acceptance, not certification.
- en-US listing unlocked. Description, short description, four features, developer and copyright text saved to draft. Listing remains Incomplete because a real desktop screenshot is required; none was fabricated or uploaded.
- Additional Testing Information notes saved and verified by reopening; includes local processing, runFullTrust rationale and the four-mode test procedure. No credentials provided.
- Selected manual publishing hold: Don't publish this submission until I select Publish now.
- Added a 398-character runFullTrust justification within the portal's 500-character limit. Submission Options is marked Complete, with manual publishing hold retained. Explains the packaged WPF/engine process model, standard user execution and local PDF output. Approval remains pending certification; no capability approval is claimed.
- Real installed MSIX testing, WPF screenshots and age ratings remain pending.
- Local portal evidence is in ignored `artifacts/partner-center-review/`; it is not committed to the public repository.

## Remaining gates, in order

1. Updated Store candidate CI passed at feature commit `ff7b757`: MakeAppx pack/unpack, exact packaged manifest,
   payload inspection and existing tests against the unpacked engine. Inspect
   `PACKAGE-INSPECTION.json` and retain the package SHA-256 and workflow URL.
   [Verified PR workflow](https://github.com/WinPebble/pdf-page-duplicator/actions/runs/38512364384)
   tests merge checkout `0048788214f7d5a791bf2c36118198b006bfd142`;
   artifact SHA-256: `77093650445808a88e817d4b39cf53a94d5b3ffa835cc403da8dde0eacd59c69`.
   This does not prove activation, child-process execution or filesystem behavior
   in an installed MSIX. No package installation is performed by these checks.
2. Obtain real WPF screenshots from an approved Windows test environment, using
   nonsensitive fixture PDFs. Do not disable Smart App Control or trust a test
   certificate on the owner's PC. Capture the actual application, not a mockup.
   Verify startup, page-1 notice, all four layouts, smallest window, 100/150/200%
   display scaling, long Unicode filename and error/success text. Audit concern:
   fixed 275×350 preview canvases may clip at the 940 DIP minimum window width;
   the settings panel may overflow with wrapped status text. Needs visual evidence.
3. Complete Partner Center draft: Properties, age ratings, Packages and en-US
   listing. Validate package acceptance in the portal separately from CI.
   Choose category and answer age-rating questions based on actual app behavior.
   Review `runFullTrust` justification below. Privacy text is already saved;
   the portal supports it without requiring a separately hosted policy URL.
4. Confirm **Private audience** saved with at least one known user group using
   personal Microsoft accounts. Keep **Make this product public on** unchecked.
   Review organizational licensing and retain no unintended organizational
   distribution. Keep free price. Do not request tester email addresses in chat.
   Private audience is now saved, but tester group selection is still pending.
5. Owner reviews the exact candidate hash, screenshots, all draft fields, audience
   and publication settings, then explicitly authorizes certification/private
   publishing. Do not submit, publish, merge PR #2 or create a public release now.
6. After Store signing and private availability, owner installs using the private
   authenticated Store link and matching tester account, keeping Smart App Control
   enabled. Test WPF → engine → output, all four modes, mixed-size multipage PDFs,
   Unicode paths, collision handling, unsupported/corrupt PDFs, launch/exit and
   uninstall. Record observed results. Only then evaluate PR #2 merge.

Private Store delivery requires certification and publishing to that audience.
Preparing the package alone cannot make it installable through Store. The owner
has not yet authorized either operation.

## Draft en-US listing

**Short description:** Repeat each PDF page 2 or 4 times on one sheet, with local processing.

**Description:**

WinPebble PDF Page Duplicator creates a new PDF with two or four copies of each
original page on its own output sheet. Choose Portrait or Landscape and check
the proportional paper-layout diagram before creating the file.

The output keeps the original paper's physical dimensions, arranged in the
selected orientation. Copies scale proportionally to fit. A document with N
pages produces N output pages, and the original PDF stays untouched.

PDF processing happens on your computer. The app has no advertising, analytics
or background service. Text and vector content are reused where supported,
without rendering entire pages as bitmap images.

Current limitations: rotated pages, cropped pages and non-default page origins
are rejected. Diagrams show the first page's proportions, not its content.
Preservation of interactive links, annotations and forms is not guaranteed.
File Explorer context-menu integration is not included in this build.

**Features:**
- Two or four copies of each original page on one output page.
- Portrait and Landscape output with proportional scaling.
- Original physical paper dimensions retained.
- Local processing; original files preserved; output names avoid overwriting.

**System requirements:** Windows 11, x64. Self-contained .NET runtime in package.
Do not claim ARM64 or x86 support for this candidate.

## Draft privacy text

WinPebble PDF Page Duplicator processes PDF files locally on your computer. It
reads the PDF you select and writes a new PDF to the same folder. The app does
not upload your PDFs, collect personal information or usage analytics, show
advertisements, or run a background service. Microsoft Store and Windows may
process information under their own privacy policies.

The complete policy text saved in the Partner Center draft is retained in
[PRIVACY.md](PRIVACY.md), with the existing GitHub issue tracker as the support
destination. This does not publish the app or its Store listing.

## Draft certification notes

**Restricted capability justification saved in draft (398 characters):**

Packaged desktop WPF app using a separate .NET/PDFsharp engine. runFullTrust launches the UI at standard user integrity and starts the packaged Engine executable. Users select a PDF; the engine reads it and stages, validates and saves a new PDF in the same folder without overwriting the original. Processing is local. No admin elevation, service, Explorer extension, analytics or document uploads.

**Testing notes:**

This is a desktop WPF utility for local PDF processing. `runFullTrust` is needed
to launch the packaged desktop application, read a user-selected PDF and invoke
the adjacent packaged command-line PDF engine to create a new file in the input
folder. It does not install a service or Explorer extension.

No app account or sign-in is required. Launch from Start, choose a supported PDF
with unrotated/default page boxes, select 2 or 4 copies and Portrait or Landscape,
then select Create PDF. The new PDF appears alongside the original with a mode
suffix; name collisions produce numbered filenames. Repeat for all four modes.
The diagram shows page 1; every source page is processed individually.

Do not state installed-package testing passed until it has actually passed.

## Microsoft sources checked 2026-10-14

- [MSIX signing and accepted submission formats](https://learn.microsoft.com/en-us/windows/apps/publish/faq/get-started-with-the-microsoft-store): a CA-trusted developer signature is not required for Store MSIX submission.
- [Private audience](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/visibility-options): use a known user group and personal Microsoft accounts; a Public submission cannot later switch to Private. Visibility is a portal setting, not a manifest field.
- [Screenshots](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/screenshots-and-images): submission needs at least one screenshot; additional real screenshots can show the four modes. Confirm dimensions and portal validation before upload.
