# WinPebble PDF Page Duplicator — WPF v0.3 Preview

**Engineering UI preview only; not a product release.**

This UI contains:
- Original-page proportion preview: width and height from PDF page 1 MediaBox.
- Output preview: same deterministic LayoutCalculator as CLI core; physical sheet dimensions match policy.
- Portrait/Landscape and 2/4 copy controls, instant preview updates.
- Choose PDF via file dialog, or start UI with a PDF file path (future Explorer command).
- 'Create PDF' invokes the **tested PDFsharp CLI engine** from an adjacent `Engine/` subfolder.
- No content rendering, tracking, network, install/uninstall or background service.

**Known deliberate limitation:** rotated, cropped or non-zero-origin PDF pages are not accepted by this engineering POC. UI validates these before enabling Create. Multi-page PDFs may have different page sizes; preview explicitly shows only first page. Output engine uses each page's own size.

Use the complete Windows CI UI artifact, keeping the Engine subfolder together with the UI executable. The GUI was compiled in GitHub Windows CI, but interactive usability requires manual inspection on a real Windows desktop (not available on a CI headless runner).

No WPF/MSIX store claims until UI tests, Explorer integration, packaging and Store certification have been independently confirmed.
