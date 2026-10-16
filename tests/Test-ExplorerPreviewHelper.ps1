# Run with pwsh on Windows; exercise the actual Windows PowerShell 5.1 host.
# Fixtures cannot register: one lacks payload, the other has a forbidden identity.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$probe = Join-Path ([IO.Path]::GetTempPath()) ('WinPebble-Helper-' + [guid]::NewGuid().ToString('N'))
$package = Join-Path $probe 'Package'
$helper = Join-Path $probe 'Register-ExplorerPreview.ps1'
$manifest = Join-Path $package 'AppxManifest.xml'
$store = Join-Path $probe 'Store.xml'
$hostExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
try {
  New-Item -ItemType Directory -Path $package | Out-Null
  Copy-Item -LiteralPath (Join-Path $root 'packaging\Register-ExplorerPreview.ps1') -Destination $helper
  Copy-Item -LiteralPath (Join-Path $root 'packaging\AppxManifest.Dev.xml') -Destination $manifest
  Copy-Item -LiteralPath (Join-Path $root 'packaging\AppxManifest.Store.xml') -Destination $store
  # The caller's directory is deliberately different from the helper's folder.
  Push-Location $root
  try {
    $output = & $hostExe -NoProfile -ExecutionPolicy Bypass -File $helper 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0 -or $output -notmatch 'Missing layout file: WinPebble.PDFPageDuplicator.exe') {
      throw "PS5.1 default path did not reach safe payload validation: $output"
    }
    $output = & $hostExe -NoProfile -ExecutionPolicy Bypass -File $helper -ManifestPath $store 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0 -or $output -notmatch 'Only the dedicated development identity') {
      throw "PS5.1 explicit manifest did not reject Store identity: $output"
    }
  } finally { Pop-Location }
  Write-Host 'PASS: PS5.1 -File default path and explicit manifest; no registration attempted.'
} finally {
  # Only remove this test's named files and now-empty folders, without recursion.
  foreach ($file in @($helper,$manifest,$store)) {
    if (Test-Path -LiteralPath $file -PathType Leaf) { Remove-Item -LiteralPath $file }
  }
  foreach ($folder in @($package,$probe)) {
    if (Test-Path -LiteralPath $folder -PathType Container) { Remove-Item -LiteralPath $folder }
  }
}
