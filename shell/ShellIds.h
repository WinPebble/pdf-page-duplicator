#pragma once
#include <windows.h>

// Dedicated to PDF Page Duplicator; never reuse PDF to Image's CLSIDs.
// Manifest literal: 0CDFF472-2768-42AC-B500-F64804FC61C6
inline constexpr CLSID PageDuplicatorClsid =
{ 0x0cdff472, 0x2768, 0x42ac, { 0xb5, 0x00, 0xf6, 0x48, 0x04, 0xfc, 0x61, 0xc6 } };
