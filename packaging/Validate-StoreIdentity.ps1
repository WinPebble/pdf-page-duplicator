#requires -Version 5.1
# Standalone identity gate; checks exact values confirmed via Partner Center Copy.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$manifest = Join-Path $PSScriptRoot 'AppxManifest.Store.xml'
if (-not (Test-Path -LiteralPath $manifest)) { throw 'Missing Store manifest.' }
[xml]$xml = Get-Content -LiteralPath $manifest -Raw
$ns = [System.Xml.XmlNamespaceManager]::new($xml.NameTable)
$ns.AddNamespace('f','http://schemas.microsoft.com/appx/manifest/foundation/windows10')
$id = $xml.SelectSingleNode('/f:Package/f:Identity', $ns)
$properties = $xml.SelectSingleNode('/f:Package/f:Properties', $ns)
if (-not $id -or -not $properties) { throw 'Store manifest is missing Identity or Properties.' }

$requiredName = 'TrungHieuNguyen-WinPebble.WinPebblePDFPageDuplicat'
$requiredPublisher = 'CN=6BD09250-A4F3-4F78-9DA7-2D9751735950'
$requiredDisplay = 'Trung Hieu Nguyen - WinPebble'
$expected = @{
  'Name' = $requiredName
  'Publisher' = $requiredPublisher
  'ProcessorArchitecture' = 'x64'
  'Version' = '1.0.0.0'
}
foreach ($field in $expected.Keys) {
  if ([string]$id.GetAttribute($field) -cne [string]$expected[$field]) {
    throw "Identity.$field mismatch; expected '$($expected[$field])'."
  }
}
if ($properties.PublisherDisplayName -cne $requiredDisplay) {
  throw 'PublisherDisplayName does not match Partner Center.'
}
if ($properties.DisplayName -cne 'WinPebble PDF Page Duplicator') {
  throw 'Unexpected public product display name.'
}
if ($id.GetAttribute('Name') -ceq 'TrungHieuNguyen-WinPebble.WinPebblePDFPageDuplicator') {
  throw 'Do not extend the literal identity Name: Partner Center ends with Duplicat.'
}

# Also protect the source-of-truth documentation from drifting.
$document = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'STORE_IDENTITY.md') -Raw
foreach ($literal in @($requiredName,$requiredPublisher,$requiredDisplay,'9N28GX9HTL9Z')) {
  if (-not $document.Contains($literal)) { throw "Identity documentation lost its required value: $literal" }
}
Write-Host 'PASS: exact Partner Center identity confirmed and locked.' -ForegroundColor Green
