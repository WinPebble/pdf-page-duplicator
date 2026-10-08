$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'artifacts\msix-preview'
$stage = Join-Path $out 'stage'
$gui = Join-Path $out 'gui'
$engine = Join-Path $out 'engine'
$dest = Join-Path $out 'out'
$manifest = Join-Path $PSScriptRoot 'AppxManifest.Dev.xml'
$msix = Join-Path $dest 'PDF-Page-Duplicator-v0.3-UNSIGNED-DEV-ONLY.msix'
$kits = Join-Path ([Environment]::GetFolderPath('ProgramFilesX86')) 'Windows Kits\10\bin'
if (-not (Test-Path $kits)) { throw 'Windows SDK missing' }
$makeappx = Get-ChildItem $kits -Directory | Sort-Object Name -Descending |
  ForEach-Object { Join-Path $_.FullName 'x64\makeappx.exe' } |
  Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $makeappx) { throw 'MakeAppx missing' }
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
foreach ($p in @($stage,$gui,$engine,$dest,(Join-Path $stage 'Engine'),(Join-Path $stage 'Assets'))) {
  New-Item -ItemType Directory $p -Force | Out-Null
}
& dotnet publish (Join-Path $root 'src\ui\PDFPageDuplicator.UI.csproj') -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o $gui
if ($LASTEXITCODE -ne 0) { throw 'GUI publish failed' }
& dotnet publish (Join-Path $root 'src\PdfPageDuplicator.Poc.csproj') -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o $engine
if ($LASTEXITCODE -ne 0) { throw 'Engine publish failed' }
Copy-Item (Join-Path $gui '*') $stage -Force -Recurse
Copy-Item (Join-Path $engine '*') (Join-Path $stage 'Engine') -Force -Recurse
Copy-Item $manifest (Join-Path $stage 'AppxManifest.xml') -Force

# Technical-only temporary icon assets. Must be replaced before Store submission.
Add-Type -AssemblyName System.Drawing
foreach ($icon in @(
  @{name='Square44x44Logo.png';n=44},
  @{name='Square150x150Logo.png';n=150},
  @{name='StoreLogo.png';n=50}
)) {
  $n=[int]$icon.n
  $bmp=[System.Drawing.Bitmap]::new($n,$n)
  $g=[System.Drawing.Graphics]::FromImage($bmp)
  $brush=[System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(36,92,153))
  try {
    $g.FillRectangle($brush,0,0,$n,$n)
    $bmp.Save((Join-Path (Join-Path $stage 'Assets') $icon.name),[System.Drawing.Imaging.ImageFormat]::Png)
  } finally { $brush.Dispose();$g.Dispose();$bmp.Dispose() }
}

foreach($f in @('WinPebble.PDFPageDuplicator.exe','Engine\WinPebble.PDFPageDuplicator.POC.exe','AppxManifest.xml')) {
  if (-not (Test-Path (Join-Path $stage $f))) { throw "Missing package input: $f" }
}
if (Get-ChildItem $stage -File -Recurse | Where-Object { $_.Extension -in @('.cer','.pfx','.p12') }) {
  throw 'Certificate material is forbidden'
}
& $makeappx pack /d $stage /p $msix /o
if ($LASTEXITCODE -ne 0) { throw 'MakeAppx packaging failed' }
Add-Type -AssemblyName System.IO.Compression
$zip = [System.IO.Compression.ZipFile]::OpenRead($msix)
try {
  $names=@($zip.Entries | ForEach-Object FullName)
  foreach($f in @('AppxManifest.xml','WinPebble.PDFPageDuplicator.exe',
    'Engine/WinPebble.PDFPageDuplicator.POC.exe','Assets/Square44x44Logo.png',
    'Assets/Square150x150Logo.png','Assets/StoreLogo.png')) {
    if ($names -notcontains $f) { throw "MSIX missing: $f" }
  }
  if ($names -contains 'AppxSignature.p7x') { throw 'Unexpected MSIX signature' }
} finally { $zip.Dispose() }
$hash=(Get-FileHash $msix -Algorithm SHA256).Hash.ToLowerInvariant()
"SHA256 ($([IO.Path]::GetFileName($msix))) = $hash" | Set-Content (Join-Path $dest 'SHA256SUMS.txt') -Encoding ascii
Write-Host 'PASS: unsigned MSIX packaging gate. NOT for installation or Store submission.' -ForegroundColor Green
