# Sync SSOT skills into .cursor/skills for Cursor workspace loading.
# SSOT: shared/skills, project-kit/.cursor/skills
# Do not edit .cursor/skills directly — edit SSOT and re-run this script.

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Dest = Join-Path $Root ".cursor\skills"

$sources = @(
    (Join-Path $Root "shared\skills\*"),
    (Join-Path $Root "project-kit\.cursor\skills\*")
)

if (-not (Test-Path $Dest)) {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
}

Get-ChildItem -Path $Dest -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force

$count = 0
foreach ($pattern in $sources) {
    $parent = Split-Path $pattern -Parent
    if (-not (Test-Path $parent)) { continue }
    Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $Dest $_.Name) -Recurse -Force
        $count++
    }
}

Write-Host "sync-skills: copied $count skill folder(s) to $Dest"
