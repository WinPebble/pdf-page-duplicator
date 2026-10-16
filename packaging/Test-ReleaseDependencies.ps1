# Inspect the restored graph and runtime config used by each self-contained app.
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ReportPath)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$apps = @(
  @{folder='src';tfm='net10.0';assembly='WinPebble.PDFPageDuplicator.POC'},
  @{folder='src\ui';tfm='net10.0-windows';assembly='WinPebble.PDFPageDuplicator'}
)
$report = foreach ($app in $apps) {
  $folder = Join-Path $root $app.folder
  $assets = Get-Content -LiteralPath (Join-Path $folder 'obj\project.assets.json') -Raw | ConvertFrom-Json
  $libraries = @($assets.libraries.PSObject.Properties.Name)
  foreach ($expected in @('PDFsharp/6.2.4','System.Security.Cryptography.Pkcs/8.0.2')) {
    if ($libraries -cnotcontains $expected) { throw "$($app.assembly): missing resolved dependency $expected" }
  }
  if (@($libraries | Where-Object { $_ -like 'System.Security.Cryptography.Pkcs/*' }).Count -ne 1) {
    throw 'Ambiguous PKCS dependency graph.'
  }
  $configPath = Join-Path $folder "bin\Release\$($app.tfm)\win-x64\$($app.assembly).runtimeconfig.json"
  $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
  $frameworks = @($config.runtimeOptions.includedFrameworks)
  $core = @($frameworks | Where-Object { $_.name -ceq 'Microsoft.NETCore.App' })
  if ($core.Count -ne 1 -or $core[0].version -cne '10.0.13') {
    throw "$($app.assembly): self-contained runtime must include .NET 10.0.13."
  }
  if ($app.folder -ceq 'src\ui') {
    $desktop = @($frameworks | Where-Object { $_.name -ceq 'Microsoft.WindowsDesktop.App' })
    if ($desktop.Count -ne 1 -or $desktop[0].version -cne '10.0.13') { throw 'WPF runtime must include 10.0.13.' }
  }
  [ordered]@{app=$app.assembly;pdfsharp='6.2.4';pkcs='8.0.2';includedFrameworks=$frameworks;check='PASS'}
}
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-Host 'PASS: both restored graphs use PDFsharp 6.2.4 / PKCS 8.0.2 and self-contained runtime 10.0.13.'
