# Version 1.0.2.0 preparation

Requested 2026-10-15: change only the Explorer context-menu label from
`Page Duplicator` to `PDF Duplicator`. The product/window name remains
WinPebble PDF Page Duplicator. PDF processing, UI, CLSID, activation arguments,
PDF selection rules, capabilities and Windows minimum are unchanged.

Both development and Store manifests and Store packaging assertions advance to
1.0.2.0 for the next package. The existing native command test now expects the
new label; the development registration helper prints the same label.

Version 1.0.1.0 already submitted to Microsoft remains untouched and uses the
old menu label. Historical submission notes and screenshots describe that
version; do not silently rewrite them as evidence for this update.

Future Store release note:
“Renamed the PDF context-menu command to PDF Duplicator.”

Validation: built the native DLL and existing command/argument-recorder test
with MSVC x64 C++17, /W4 /WX /utf-8 /EHsc /MT. The command test passed its exact
new menu title check, COM lifecycle, PDF-only single selection and unchanged
Unicode/spaced/metacharacter argument launch. Both manifest registration gates,
exact Store identity gate and PS5.1 helper regression checks passed. No new UI
or PDF algorithm tests are needed for this label change.

Local Store candidate prepared from the verified 1.0.1.0 staged payload, replacing
only the compiled shell DLL and manifest. All seven retained EXE/DLL hashes
match the previous patched payload. MakeAppx pack/unpack and Test-StorePackage
passed, including exact identity, version 1.0.2.0, minimum Windows 19045,
payload inspection and absence of a development signature. Not installed or
submitted. This local incremental package is not claimed to be an independent
CI rebuild. Binary provenance, inspection report and checksum are retained in
artifacts/store-version-1.0.2.0/out.

Candidate SHA-256:
`dd1dc128fb349ad72846ab07916a04c37f39ca78d215a6bc1f8b142e403249ec`.

Future certification-note change: replace the old Explorer menu label with
PDF Duplicator. Prepare the next submission only after reviewing the new
package; no upload, certification submission, publication or PR merge is
authorized by this preparation request.
