# Explicit user-run cleanup; leaves the package files and user PDFs untouched.
#requires -Version 5.1
$ErrorActionPreference = 'Stop'
Get-AppxPackage -Name 'WinPebble.PDFPageDuplicator.PreviewDev' | ForEach-Object {
  Remove-AppxPackage -Package $_.PackageFullName
}
if (Get-AppxPackage -Name 'WinPebble.PDFPageDuplicator.PreviewDev') { throw 'Development package is still registered.' }
Write-Host 'Development registration removed for this user. Store products and PDF files were not removed.'
