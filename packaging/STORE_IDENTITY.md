# Microsoft Partner Center identity — PDF Page Duplicator

**Verified from Partner Center's Copy button and confirmed by the product owner on 2026-10-08.**

| Field | Verified value |
| --- | --- |
| Product | WinPebble PDF Page Duplicator |
| Store ID | `9N28GX9HTL9Z` |
| Package/Identity/Name | `TrungHieuNguyen-WinPebble.WinPebblePDFPageDuplicat` |
| Package/Identity/Publisher | `CN=6BD09250-A4F3-4F78-9DA7-2D9751735950` |
| Package/Properties/PublisherDisplayName | `Trung Hieu Nguyen - WinPebble` |

The unusual final `Duplicat` suffix is **intentional**, not a typing mistake.
This literal value must not be 'corrected' to the public product display name.

## Store readiness gates

- [x] Product separately reserved in Partner Center (In draft).
- [x] Store identity Name confirmed by **copy/paste**, exact literal.
- [x] Separate Store manifest and automatic identity validation.
- [x] PDFsharp core automated tests and WPF Windows builds.
- [x] Unsigned MSIX **structural** package checks.
- [x] Official WinPebble-derived application icons.
- [ ] Real WPF app screenshots on Windows.
- [ ] Installed MSIX activation and WPF-to-engine execution verified in an approved test environment.
- [ ] Final Store submission package built from approved assets.
- [x] Private audience saved, automatic public date unchecked, organizational licensing disabled (portal verified 2026-10-14).
- [ ] Tester group selected with a designated **personal Microsoft account**.
- [ ] Store certification and private publishing.
- [ ] Real Windows 11 test through Microsoft Store: WPF launch, 2-up/4-up output, install/uninstall.
- [ ] Modern Explorer context menu integration (subsequent milestone).

**Security:** Do not sideload unsigned candidates or disable Smart App Control.
The Store package must use this identity; never reuse the PDF to Image identity.
Keep WPF PR #2 unmerged until the app has been evaluated on a Windows desktop.

Private audience is now **verified as saved** in Partner Center. Tester group
selection remains pending; do not infer portal settings from package identity.
Do not submit for certification or publish (including privately) without owner
authorization. See [preparation checklist and draft listing](../docs/STORE_PRIVATE_PREPARATION.md).
