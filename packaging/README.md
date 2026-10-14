# MSIX engineering packaging gate

This is an **unsigned, development-identity packaging test** for the WPF app and
its separate PDFsharp engine. It is **not** a trusted installer or Store submission.
Do not install this test artifact on a Smart App Control-protected computer, and do
not disable Windows security for testing.

Official icon tiles and the executable ICO are generated from the approved,
SHA-256-verified WinPebble pebble mark. No developer certificate is generated,
trusted or distributed by CI.

The separate Store product is already reserved: **9N28GX9HTL9Z**. Exact identity
values are locked in `STORE_IDENTITY.md` and `AppxManifest.Store.xml`.
`Build-MSIX-Store-Candidate.ps1` checks identity before building and inspects the
packed manifest and payload using `Test-StorePackage.ps1`. It emits
`PACKAGE-INSPECTION.json` containing commit, identity and SHA-256 hashes. Store CI
runs the existing 20 geometry / 13 PDF cases against the engine **unpacked from
that MSIX**, without rebuilding it. This is not an installed-package runtime test.

An unsigned MSIX is accepted for Store submission; the Store handles signing.
The `NOT-SUBMITTABLE` artifact label describes our incomplete readiness gates,
not a Microsoft requirement to purchase a signing certificate. Do not sideload
the candidate. Complete listing, real screenshots and Private audience setup;
obtain owner authorization before certification or private publishing. Install
from Microsoft Store on the protected PC only when the private listing is live.
See `docs/STORE_PRIVATE_PREPARATION.md` for the review checklist and sources.

Only after hands-on WPF review should the app proceed to modern File Explorer
context-menu integration. This is a preparatory build gate, not proof that a
Store install, WPF launch, or Smart App Control acceptance works.
