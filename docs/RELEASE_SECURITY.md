# Release security dependency remediation

Prepared 2026-10-14. PDFsharp 6.2.4 remains unchanged. No PDF/layout behavior,
capability, Store identity, security setting or document access scope changed.

CI previously reported NU1902/NU1903 for transitive
System.Security.Cryptography.Pkcs 8.0.1. Microsoft advisories describe CPU
exhaustion in EnvelopedCms.Decode and SignedCms.CheckSignature. Both list 8.0.2
as a fixed 8.x package and 10.0.13 as a fixed 10.x release. No exploitation or
reachability through this app has been established; the dependency is patched
without relying on an unproven claim that these APIs cannot be reached.

Both CLI and WPF explicitly reference PKCS 8.0.2, overriding PDFsharp's older
transitive minimum. Directory.Build.props pins the self-contained runtime to
10.0.13, enables auditing of transitive packages and treats vulnerability
warnings NU1901-NU1904 as build errors. Updating a machine-wide runtime alone
does not patch a self-contained application; the candidate was rebuilt.

Test-ReleaseDependencies.ps1 checks the resolved graph for both projects and
the generated runtime configs for the actual self-contained publish. It emits
DEPENDENCY-INSPECTION.json outside the install payload. Development and Store
package workflows include this check. Existing native/helper, PDF geometry,
end-to-end PDF and progress checks still apply.

Validated source: fa0e05c7361fbadd97c98bb51c851875cd4e7f08; all four CI workflows
passed. Keep this evidence scoped to that source and the inspected artifacts;
it is not a guarantee against undisclosed vulnerabilities. The security patch
changes binaries, so final manual Windows 10/11 and Store delivery checks must
use this candidate rather than simply copying earlier manual results.

Sources:
- https://github.com/advisories/GHSA-2fmv-rv2c-59x7
- https://github.com/advisories/GHSA-846f-f764-76mx
