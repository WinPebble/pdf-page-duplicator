# Windows compatibility release gate

Owner requirement confirmed 2026-10-14: the initial public release must support
both Windows 10 and Windows 11. Do not publish a Windows 11-only package and defer
Windows 10 support to an update.

## Current evidence

- Both development and Store manifests now declare MinVersion
  `10.0.19045.0`, allowing Windows 10 22H2 and Windows 11 package eligibility.
  Package validation rejects a regression to a Windows 11-only minimum.
- The engine targets net10.0; WPF targets net10.0-windows. Those target framework
  names alone do not establish Windows 10 compatibility.
- The owner confirmed development registration, Explorer activation and PDF
  export on Windows 11.
- A portable executable running does not prove Store package eligibility or
  packaged Explorer integration.
- The owner's second test machine is Windows 10 Pro 22H2 x64, OS build
  19045.7725 (owner-provided About screenshot). On 2026-10-14 the owner reported
  all supplied tests passed after applying helper fix 25a37de. Screenshot (149)
  shows successful development registration and removal. See the test record below.

## Required before public release

1. Establish an explicit supported Windows 10 baseline. First test target:
   Windows 10 22H2 x64 (build 19045), alongside Windows 11 x64. Earlier Windows
   10 releases and x86/ARM64 are not implicitly supported.
2. Audit runtime/native dependencies and manifest extension requirements for
   that baseline; resolve any incompatibility before lowering MinVersion in
   both manifests. Preserve the Store identity, approved layout and PDF behavior.
3. Build and validate the resulting package, including any version assumptions
   in package checks. Keep Windows 11 coverage.
4. On actual Windows 10 22H2 or a VM, verify install, Start launch, right-click
   one PDF -> Page Duplicator -> selected PDF loaded, all four export modes,
   progress/success/error behavior, Unicode paths, and uninstall/menu removal.
5. Verify the Store-distributed build on both OS versions. Publish compatibility
   claims on the Store and website only after recording observed results.

Status: **Development testing passed on the owner's Windows 10 and Windows 11
machines; Store-distributed installation testing remains pending.**
Do not treat a manifest change or CI build on Windows 11 as a Windows 10 test.

## Owner-reported Windows 10 test record, 2026-10-14

Environment: Windows 10 Pro 22H2 x64, build 19045.7725.
Payload: exact f9b068f CI binaries, manifest baseline 0a3825d and PowerShell 5.1
registration helper fix 25a37de. The initial helper failed before registration;
the fixed helper was tested and supplied separately.

The owner states all tests in the supplied guide passed: UI launch, all four
export modes, progress and success confirmation, right-click activation with
the selected PDF, Unicode/spaced filenames, removal and the existing PDF to
Image check. This is owner-reported manual evidence, not agent-observed UI
automation. Screenshot (149) independently shows helper registration and
unregistration success messages; it does not independently demonstrate each
PDF result. No personal screenshot/device IDs are committed to the repository.

This closes the development Windows 10 testing gate for that payload and OS
build. Start-menu activation, Store signing/delivery, Store install/update and
the final release candidate on both systems still need release verification.

## Audit and test kit scope

Only package eligibility and preflight/validation change for this compatibility
candidate. The WPF UI, PDF engine and native command behavior remain unchanged.
The initial transfer kit can reuse the exact f9b068f CI binaries, with the new
development manifest and registration helper; its provenance must say so.

The manifest features fit the target: uap10 RuntimeBehavior/TrustLevel requires
19041; desktop4 context menus requires 17134; desktop5 ItemType requires 17763;
COM SurrogateServer requires 15063. The native code uses filesystem/shell/COM
and CreateProcessW APIs; no Windows 11-only API was introduced.

The runtime is bundled (.NET 10); the test PC does not need a separate SDK or
runtime installation. Microsoft's current .NET 10 supported-OS list does not
list Windows 10 Pro 22H2. Technical compatibility demonstrated by our tests
must not be presented as Microsoft's lifecycle/support guarantee. Do not
change the approved runtime or PDFsharp version merely to hide that distinction.

Sources checked 2026-10-14:
- https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-application
- https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-desktop4-fileexplorercontextmenus
- https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-desktop5-itemtype
- https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-com-surrogateserver
- https://github.com/dotnet/core/blob/main/release-notes/10.0/supported-os.md
