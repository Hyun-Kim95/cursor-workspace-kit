# Sync SSOT rules into .cursor/rules for Cursor workspace loading.
# SSOT: shared/rules, shared/optional, project-kit/.cursor/rules
# Do not edit .cursor/rules directly — edit SSOT and re-run this script.

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Dest = Join-Path $Root ".cursor\rules"

$sources = @(
    (Join-Path $Root "shared\rules\*.mdc"),
    (Join-Path $Root "shared\optional\*.mdc"),
    (Join-Path $Root "project-kit\.cursor\rules\*.mdc")
)

if (-not (Test-Path $Dest)) {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
}

Get-ChildItem -Path $Dest -Filter "*.mdc" -ErrorAction SilentlyContinue | Remove-Item -Force

$count = 0
foreach ($pattern in $sources) {
    $dir = Split-Path $pattern -Parent
    if (-not (Test-Path $dir)) { continue }
    Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item $_.FullName -Destination $Dest -Force
        $count++
    }
}

Write-Host "sync-rules: copied $count file(s) to $Dest"
