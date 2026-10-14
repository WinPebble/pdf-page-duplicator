$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root 'artifacts\shell-build'
& cmake -S (Join-Path $root 'shell') -B $build -A x64 -DBUILD_TESTING=ON
if ($LASTEXITCODE -ne 0) { throw 'Native shell CMake configuration failed. Install Visual Studio C++ x64 tools.' }
& cmake --build $build --config Release
if ($LASTEXITCODE -ne 0) { throw 'Native shell build failed.' }
& ctest --test-dir $build -C Release --output-on-failure
if ($LASTEXITCODE -ne 0) { throw 'Native shell selection/launch tests failed.' }
$dll = Join-Path $build 'Release\WinPebble.PDFPageDuplicator.Shell.dll'
if (-not (Test-Path -LiteralPath $dll)) { throw 'Missing native shell DLL.' }
Write-Host 'PASS: native x64 Explorer command built and tested.'
