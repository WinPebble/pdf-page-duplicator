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
- WPF options window with file selection, four modes and proportional diagrams using the same layout calculator as the CLI. Mixed-size documents preview page 1; output uses each page's own size.
- Separate development and Store-identity full MSIX build lanes with the approved WinPebble icon.
- Store candidate is an unsigned inspection artifact, not an approved installer. Real packaged WPF execution and owner UI review remain pending.
- Modern Explorer context menu is not implemented. No Store certification or public release.

## Run in development

Restore and build on Windows with .NET 10 SDK:

    dotnet restore src/PdfPageDuplicator.Poc.csproj
    dotnet build src/PdfPageDuplicator.Poc.csproj -c Release
    dotnet run --project src/PdfPageDuplicator.Poc.csproj -c Release -- --self-test

Create an output:

    dotnet run --project src/PdfPageDuplicator.Poc.csproj -c Release -- "C:\PDFs\input.pdf" --copies 2 --orientation portrait

## Windows CI

The Windows GitHub Actions workflow builds the actual C# engine, runs geometry checks, and uses PyMuPDF **only as an independent output validator**. Its fixtures are generated during CI. On success it uploads an unsigned standalone development executable artifact. A green workflow proves the covered automated scenarios; real Foxit/printing verification and unsupported PDF feature tests remain necessary.

Next target: Microsoft Store **Private audience** installation on Windows 11 with Smart App Control enabled. See [private Store preparation](docs/STORE_PRIVATE_PREPARATION.md) and [Store identity](packaging/STORE_IDENTITY.md). PR #2 stays open until owner UI review; submission, private publishing and public release require explicit owner authorization.
