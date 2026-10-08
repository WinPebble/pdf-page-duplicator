# Store package construction check, NOT a submission or signed installer.
# Reuse the already-tested WPF/engine build stage, then replace ONLY the manifest
# with the Store-specific identity and rebuild a separate unsigned package.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$buildPreview = Join-Path $PSScriptRoot 'Build-MSIX-Preview.ps1'
$storeManifest = Join-Path $PSScriptRoot 'AppxManifest.Store.xml'
$previewRoot = Join-Path $root 'artifacts\msix-preview'
$previewStage = Join-Path $previewRoot 'stage'
$storeRoot = Join-Path $root 'artifacts\msix-store-candidate'
$stage = Join-Path $storeRoot 'stage'
$out = Join-Path $storeRoot 'out'
$msix = Join-Path $out 'WinPebble-PDF-Page-Duplicator-0.3.0-Store-CANDIDATE-DO-NOT-SUBMIT.msix'

if (-not (Test-Path $storeManifest)) { throw 'Store manifest is missing.' }
if (-not (Test-Path $buildPreview)) { throw 'MSIX preview builder is missing.' }
$kits = Join-Path ([Environment]::GetFolderPath('ProgramFilesX86')) 'Windows Kits\10\bin'
$makeappx = Get-ChildItem $kits -Directory | Sort-Object Name -Descending |
  ForEach-Object { Join-Path $_.FullName 'x64\makeappx.exe' } |
  Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $makeappx) { throw 'Windows SDK MakeAppx tool is missing.' }

# Development packaging gate produces the EXEs and validates their presence.
& $buildPreview
if ($LASTEXITCODE -ne 0) { throw 'Development packaging stage failed.' }
if (Test-Path $storeRoot) { Remove-Item $storeRoot -Recurse -Force }
New-Item -ItemType Directory $stage,$out -Force | Out-Null
Copy-Item -Path (Join-Path $previewStage '*') -Destination $stage -Recurse -Force
Copy-Item -LiteralPath $storeManifest -Destination (Join-Path $stage 'AppxManifest.xml') -Force

[xml]$xml = Get-Content (Join-Path $stage 'AppxManifest.xml') -Raw
$ns=[System.Xml.XmlNamespaceManager]::new($xml.NameTable)
$ns.AddNamespace('f','http://schemas.microsoft.com/appx/manifest/foundation/windows10')
$id=$xml.SelectSingleNode('/f:Package/f:Identity',$ns)
$prop=$xml.SelectSingleNode('/f:Package/f:Properties',$ns)
$expectedName='TrungHieuNguyen-WinPebble.WinPebblePDFPageDuplicat'
$expectedPublisher='CN=6BD09250-A4F3-4F78-9DA7-2D9751735950'
$expectedDisplay='Trung Hieu Nguyen - WinPebble'
if (-not $id -or $id.Name -cne $expectedName -or
    $id.Publisher -cne $expectedPublisher -or $id.ProcessorArchitecture -cne 'x64' -or
    $id.Version -cne '1.0.0.0' -or $prop.PublisherDisplayName -cne $expectedDisplay) {
  throw 'Store identity does not match recorded Partner Center values.'
}
if (Get-ChildItem $stage -File -Recurse | Where-Object { $_.Extension -in @('.cer','.pfx','.p12') }) {
  throw 'Certificate material must not be bundled.'
}
& $makeappx pack /d $stage /p $msix /o
if ($LASTEXITCODE -ne 0) { throw 'Store candidate MSIX packaging failed.' }

Add-Type -AssemblyName System.IO.Compression
$zip=[System.IO.Compression.ZipFile]::OpenRead($msix)
try {
  $items=@($zip.Entries | ForEach-Object FullName)
  foreach($name in @('AppxManifest.xml','WinPebble.PDFPageDuplicator.exe',
    'Engine/WinPebble.PDFPageDuplicator.POC.exe',
    'Assets/Square44x44Logo.png','Assets/Square150x150Logo.png','Assets/StoreLogo.png')) {
    if ($items -notcontains $name) { throw "Store package missing required file: $name" }
  }
  if ($items -contains 'AppxSignature.p7x') { throw 'Store candidate must not contain a dev signature.' }
} finally { $zip.Dispose() }
$hash=(Get-FileHash $msix -Algorithm SHA256).Hash.ToLowerInvariant()
"SHA256 ($([IO.Path]::GetFileName($msix))) = $hash" | Set-Content (Join-Path $out 'SHA256SUMS.txt') -Encoding ASCII
Copy-Item $storeManifest (Join-Path $out 'AppxManifest.Store.xml') -Force
Write-Host 'PASS: Store identity + unsigned MSIX package STRUCTURE.'
Write-Host 'BLOCKER: This build still uses placeholder icons. DO NOT submit or sideload.'
Write-Host "Product Store ID: 9N28GX9HTL9Z"
