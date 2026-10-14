[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ManifestPath)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
[xml]$xml = Get-Content -LiteralPath $ManifestPath -Raw
$ns = [Xml.XmlNamespaceManager]::new($xml.NameTable)
$ns.AddNamespace('f','http://schemas.microsoft.com/appx/manifest/foundation/windows10')
$ns.AddNamespace('c','http://schemas.microsoft.com/appx/manifest/com/windows10')
$ns.AddNamespace('d4','http://schemas.microsoft.com/appx/manifest/desktop/windows10/4')
$ns.AddNamespace('d5','http://schemas.microsoft.com/appx/manifest/desktop/windows10/5')
$classes = @($xml.SelectNodes('//c:SurrogateServer/c:Class',$ns))
$types = @($xml.SelectNodes('//d4:FileExplorerContextMenus/d5:ItemType',$ns))
$verbs = @($xml.SelectNodes('//d5:Verb',$ns))
$clsid = '0CDFF472-2768-42AC-B500-F64804FC61C6'
if ($classes.Count -ne 1 -or $types.Count -ne 1 -or $verbs.Count -ne 1) { throw 'Expected exactly one PDF Explorer command and COM class.' }
if ($classes[0].Id -cne $clsid -or $classes[0].Path -cne 'WinPebble.PDFPageDuplicator.Shell.dll' -or
    $classes[0].ThreadingModel -cne 'STA' -or $types[0].Type -cne '.pdf' -or
    $verbs[0].Clsid -cne $clsid -or $verbs[0].Id -cne 'WinPebblePageDuplicator') {
  throw 'Explorer registration does not match the dedicated Page Duplicator command.'
}
$header = Get-Content -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) 'shell\ShellIds.h') -Raw
if (-not $header.Contains($clsid)) { throw 'Native command identity drifted from the manifest.' }
Write-Host 'PASS: one PDF-only Explorer verb, dedicated CLSID and native DLL registration.'
