# WinPebble PDF Page Duplicator

**Engineering proof of concept (POC). Not a published WinPebble utility.**

Windows PDF page imposition: repeat each page 2 or 4 times on a single output page, portrait or landscape. Each input page produces exactly one output page. The physical page size remains the same, with orientation switched as requested; content is scaled without changing aspect ratio.

## Current implementation

- C# / .NET 10 + PDFsharp 6.2.4 (candidate dependency, not yet production approved).
- All 4 modes: 2-up portrait, 2-up landscape, 4-up portrait, 4-up landscape.
- Retains vector/text via PDF Form XObjects where supported, without rendering to bitmap.
- Keeps input files untouched, refuses explicit overwrite, and avoids filename collisions.
- Stages output in a temporary PDF, verifies it, then moves it to its final filename.
- Known POC limitation: /Rotate, non-default /CropBox and page origins are rejected until separately verified.
- This milestone is **CLI only**. No WPF, Explorer context menu, installer or MSIX has been implemented yet.

## Run in development

Restore and build on Windows with .NET 10 SDK:

    dotnet restore src/PdfPageDuplicator.Poc.csproj
    dotnet build src/PdfPageDuplicator.Poc.csproj -c Release
    dotnet run --project src/PdfPageDuplicator.Poc.csproj -c Release -- --self-test

Create an output:

    dotnet run --project src/PdfPageDuplicator.Poc.csproj -c Release -- "C:\PDFs\input.pdf" --copies 2 --orientation portrait

## Windows CI

The Windows GitHub Actions workflow builds the actual C# engine, runs geometry checks, and uses PyMuPDF **only as an independent output validator**. Its fixtures are generated during CI. On success it uploads an unsigned standalone development executable artifact. A green workflow proves the covered automated scenarios; real Foxit/printing verification and unsupported PDF feature tests remain necessary.

Production target: Windows 11 Explorer integration, small WPF options window, and a separate MSIX Store lane after the core passes quality gates. This repository is not yet a Store app and has no production release.
