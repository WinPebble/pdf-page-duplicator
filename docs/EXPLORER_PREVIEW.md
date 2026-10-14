# Explorer Page Duplicator command

Requested flow: **right-click one PDF → Page Duplicator → the existing options
window opens with that exact PDF already selected**. The command does not export
automatically, show a file chooser, change the default PDF app or process a batch.
The owner chooses settings and Create PDF in the existing WPF window.

## Implementation

- Native x64 C++17 `IExplorerCommand`, registered through full-MSIX manifest
  extensions `windows.comServer` and `windows.fileExplorerContextMenus`.
- Dedicated CLSID `0CDFF472-2768-42AC-B500-F64804FC61C6`, different from PDF to Image.
- Menu label **Page Duplicator**, package's approved executable icon, `.pdf` scope.
- Exactly one filesystem PDF is accepted, including uppercase `.PDF`, spaces,
  Unicode and shell metacharacters. Multiple selections, folders and other file
  types are hidden/rejected. No PDF parsing happens during menu construction.
- Invoke starts the WPF EXE beside the DLL via CreateProcessW with an explicit
  application path and quoted PDF argument, without a shell interpreter. WPF's
  startup path immediately loads it. Missing/invalid files show an error status.
- The DLL never loads PDFsharp, converts PDFs or waits for conversion. Conversion
  remains in the separate engine process. No resident service is added.

## Automated gates

`packaging/Build-ExplorerCommand.ps1` uses CMake and Visual Studio x64 C++ tools,
builds the native DLL with static CRT, and runs CTest before packaging. The native
test loads the DLL directly, checks COM lifetime/title/canonical ID, validates
single-PDF selection behavior and invokes a **test-only argument recorder** to
verify the exact Unicode/spaced/metacharacter path received by the child process.
The recorder is never placed in a real package.

Both manifests and the unpacked Store candidate are checked for one matching
CLSID/verb, native DLL path, STA registration and `.pdf`-only scope. Existing PDF
output/progress tests remain in place. A build/test pass does not prove real
Explorer registration, menu appearance, WPF activation or uninstall behavior.

## Development review before Store

The MSIX gate publishes `PDF-Page-Duplicator-Explorer-Review-win-x64`, a complete
loose development layout, separate from the unsigned inspection MSIX and the
Store candidate. A review kit contains `Package/`, the two helper scripts and
test PDF samples. This is a registration/install test, not a portable ZIP launch.

On an **owner-approved test machine** where Windows Developer Mode is already
enabled, use Windows PowerShell as the intended user:

```powershell
.\Register-ExplorerPreview.ps1
```

The helper registers only `WinPebble.PDFPageDuplicator.PreviewDev` for that user.
It refuses Store identity, checks prerequisites and does not enable Developer
Mode, change SAC/Defender, create/trust a certificate, edit PDF associations or
restart Explorer. Leave `Package/` at the same path while registered. Do not
install development and Store variants concurrently; remove the preview before
testing the Store variant.

1. Close old preview windows; right-click one sample PDF in Explorer.
2. Choose Page Duplicator. Confirm there is no file chooser and that the correct
   filename, page count and proportions are loaded. Include Unicode/space paths.
3. Export with all four modes and compare the output in Foxit.
4. Check a non-PDF, a folder and multiple selection: this command should not be
   available. Confirm PDF to Image and the default PDF association still work.
5. Run `.\Unregister-ExplorerPreview.ps1`; confirm the menu disappears and PDFs
   remain. Explorer may cache commands until an approved restart or sign-out.

Developer Mode and machine registration must be approved separately for the
intended environment. SAC being off does not by itself enable loose package
registration. On a protected primary PC, use Store-signed Private audience
delivery after the remaining draft gates and explicit publication approval.

**Current manual status:** the owner enabled Developer Mode and authorized
development registration on Windows 11; package registration reported OK and
the owner confirmed the requested menu/UI/export flow works. Uninstall remains
untested. Windows 10 Pro 22H2 x64 testing is pending; see
[Windows compatibility](WINDOWS_COMPATIBILITY.md). No certificate or security
setting was changed by the agent.
The previously uploaded Store draft package is unchanged; no submit/publish/merge.

## Sources

- [Microsoft: packaged Explorer context menu integration](https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/integrate-packaged-app-with-file-explorer)
- [Microsoft: loose-layout development registration prerequisites](https://learn.microsoft.com/en-us/windows/apps/dev-tools/winapp-cli/security)
