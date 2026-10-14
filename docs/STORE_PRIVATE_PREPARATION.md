# Private Microsoft Store preparation

Prepared 2026-10-14. Draft for owner review; no submission or publishing authorization.
Product: WinPebble PDF Page Duplicator. Store ID: **9N28GX9HTL9Z**.

## Verified baseline

- Public MIT repository; main `47ae127090fdbb71dfd4da036660f7a15dd342c4`.
- PR #2 open, unmerged; feature baseline `7f3b98e3b796a37967bb1bc3a0ff01ec9fb7a63d`.
- Core, WPF, development MSIX and Store candidate CI all successful for that baseline.
- Shared layout calculator; WPF reads page 1 for diagrams, engine handles each page separately.
- Engine resolved relative to `AppContext.BaseDirectory/Engine`; output written alongside input, not inside package. Installed MSIX execution remains unverified.
- Exact Store identity and approved icon retained. No Explorer extension registration.
- No GitHub releases at audit time. Partner Center not inspected in this session.

## Remaining gates, in order

1. Run updated Store candidate CI: MakeAppx pack/unpack, exact packaged manifest,
   payload inspection and existing tests against the unpacked engine. Inspect
   `PACKAGE-INSPECTION.json` and retain the package SHA-256 and workflow URL.
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
   Review `runFullTrust` justification below. Publish a privacy/support URL if
   requested by Partner Center; neither URL is assumed to exist.
4. Confirm **Private audience** saved with at least one known user group using
   personal Microsoft accounts. Keep **Make this product public on** unchecked.
   Review organizational licensing and retain no unintended organizational
   distribution. Keep free price. Do not request tester email addresses in chat.
   Last handoff screenshot showed Public audience; this remains unverified.
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

This text is ready for review, not an already-published privacy policy. Owner
must provide an approved contact/support destination before it becomes a policy.

## Draft certification notes

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
