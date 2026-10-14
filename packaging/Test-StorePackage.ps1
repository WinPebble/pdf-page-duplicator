# Structural verification only. Does not install, sign, launch or submit anything.
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$PackagePath,
  [Parameter(Mandatory=$true)][string]$MakeAppxPath,
  [string]$SourceCommit = 'UNKNOWN (standalone inspection)'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
& (Join-Path $PSScriptRoot 'Validate-StoreIdentity.ps1')
$package = (Resolve-Path -LiteralPath $PackagePath).Path
$root = Split-Path -Parent $PSScriptRoot
$inspectionRoot = Join-Path $root 'artifacts\msix-store-candidate'
# Unique destination avoids deleting a previous inspection or unrelated folder.
$unpacked = Join-Path $inspectionRoot ('inspection-' + [Guid]::NewGuid().ToString('N'))
& $MakeAppxPath unpack /p $package /d $unpacked /o
if ($LASTEXITCODE -ne 0) { throw 'MakeAppx could not unpack the Store candidate.' }
$sourceManifest = Join-Path $PSScriptRoot 'AppxManifest.Store.xml'
$packedManifest = Join-Path $unpacked 'AppxManifest.xml'
& (Join-Path $PSScriptRoot 'Validate-ExplorerRegistration.ps1') -ManifestPath $packedManifest
if ((Get-FileHash -LiteralPath $sourceManifest).Hash -cne (Get-FileHash -LiteralPath $packedManifest).Hash) {
  throw 'Packaged manifest differs from the validated Store manifest.'
}
foreach ($relative in @('WinPebble.PDFPageDuplicator.exe',
    'WinPebble.PDFPageDuplicator.Shell.dll',
    'Engine\WinPebble.PDFPageDuplicator.POC.exe', 'Assets\Square44x44Logo.png',
    'Assets\Square150x150Logo.png', 'Assets\StoreLogo.png',
    'D3DCompiler_47_cor3.dll', 'PenImc_cor3.dll', 'PresentationNative_cor3.dll',
    'vcruntime140_cor3.dll', 'wpfgfx_cor3.dll')) {
  $file = Get-Item -LiteralPath (Join-Path $unpacked $relative)
  if ($file.Length -eq 0) { throw "Empty package payload: $relative" }
}
$files = @(Get-ChildItem -LiteralPath $unpacked -File -Recurse)
if ($files | Where-Object { $_.Extension -in @('.pfx','.p12','.cer','.py') }) {
  throw 'Package contains certificate material or Python test code.'
}
if (Test-Path -LiteralPath (Join-Path $unpacked 'AppxSignature.p7x')) {
  throw 'Unexpected signature: candidate must not contain a development signature.'
}
$commit = & git -C $root rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot record source commit.' }
[xml]$manifest = Get-Content -LiteralPath $packedManifest -Raw
$report = [ordered]@{
  sourceCommit = $SourceCommit
  inspectionCommit = $commit.Trim()
  package = [IO.Path]::GetFileName($package)
  sha256 = (Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash.ToLowerInvariant()
  identity = [string]$manifest.Package.Identity.Name
  publisher = [string]$manifest.Package.Identity.Publisher
  version = [string]$manifest.Package.Identity.Version
  architecture = [string]$manifest.Package.Identity.ProcessorArchitecture
  structuralCheck = 'PASS'
  installedRuntime = 'NOT TESTED'
  smartAppControl = 'NOT TESTED'
  audience = 'NOT VERIFIED - Partner Center setting, not MSIX metadata'
  submissionApproved = $false
  files = @($files | ForEach-Object {
    [ordered]@{
      path = $_.FullName.Substring($unpacked.Length + 1).Replace('\','/')
      sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
  })
}
$reportPath = Join-Path (Split-Path -Parent $package) 'PACKAGE-INSPECTION.json'
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $reportPath -Encoding UTF8
# Consumers can test this exact unpacked payload without rebuilding the engine.
Write-Output $unpacked
