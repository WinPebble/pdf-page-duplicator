# MSIX engineering packaging gate

This is an **unsigned, development-identity packaging test** for the WPF app and
its separate PDFsharp engine. It is **not** a trusted installer or Store submission.
Do not install this test artifact on a Smart App Control-protected computer, and do
not disable Windows security for testing.

Official icon tiles and the executable ICO are generated from the approved,
SHA-256-verified WinPebble pebble mark. No developer certificate is generated,
trusted or distributed by CI.

To test on the user's protected Windows 11 PC, reserve the **separate** Microsoft
Store product "WinPebble PDF Page Duplicator" in Partner Center; supply the exact
Name, Publisher and PublisherDisplayName from **Product identity**. Never reuse the
PDF to Image Store identity. Build a separate Store MSIX with those exact values;
use a **Private audience** for initial testers, submit for certification, publish,
and install **from Microsoft Store** only after the listing is live.

Only after hands-on WPF review should the app proceed to modern File Explorer
context-menu integration. This is a preparatory build gate, not proof that a
Store install, WPF launch, or Smart App Control acceptance works.
