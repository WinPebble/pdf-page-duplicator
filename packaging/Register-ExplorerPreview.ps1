# Explicit user-run development registration. No certificates or security changes.
#requires -Version 5.1
[CmdletBinding()]
param([string]$ManifestPath)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
# Windows PowerShell 5.1 may not populate PSScriptRoot while evaluating a
# parameter default. Resolve it in the script body, independent of caller cwd.
if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
  $ManifestPath = Join-Path $PSScriptRoot 'Package\AppxManifest.xml'
}
$manifest = (Resolve-Path -LiteralPath $ManifestPath).Path
[xml]$xml = Get-Content -LiteralPath $manifest -Raw
if ($xml.Package.Identity.Name -cne 'WinPebble.PDFPageDuplicator.PreviewDev' -or
    $xml.Package.Identity.Publisher -cne 'CN=WinPebble Development') {
  throw 'Only the dedicated development identity may be registered by this script.'
}
$layout = Split-Path -Parent $manifest
$minimum = [version]$xml.Package.Dependencies.TargetDeviceFamily.MinVersion
if ([Environment]::OSVersion.Version -lt $minimum -or -not [Environment]::Is64BitOperatingSystem) {
  throw "This preview requires Windows 10 22H2 x64 (build 19045) or newer. Detected: $([Environment]::OSVersion.Version)."
}
foreach ($relative in @('WinPebble.PDFPageDuplicator.exe','WinPebble.PDFPageDuplicator.Shell.dll',
                        'Engine\WinPebble.PDFPageDuplicator.POC.exe')) {
  if (-not (Test-Path -LiteralPath (Join-Path $layout $relative) -PathType Leaf)) { throw "Missing layout file: $relative" }
}
$policy = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -ErrorAction SilentlyContinue
$enabled = if ($policy) { $policy.PSObject.Properties['AllowDevelopmentWithoutDevLicense'] } else { $null }
if (-not $enabled -or $enabled.Value -ne 1) {
  throw 'Windows Developer Mode is not enabled. Registration was not attempted. Choose an approved test environment or obtain owner approval before changing that setting.'
}
Add-AppxPackage -Register $manifest
$registered = Get-AppxPackage -Name 'WinPebble.PDFPageDuplicator.PreviewDev'
if (-not $registered) { throw 'Development package was not registered.' }
Write-Host "Registered for this user: $($registered.PackageFullName)"
Write-Host 'Keep the Package folder in this location until unregistering. Right-click a single PDF and select Page Duplicator.'
Write-Host 'Explorer was not restarted. If the menu is stale, close app windows and arrange an approved Explorer restart or sign-out.'
