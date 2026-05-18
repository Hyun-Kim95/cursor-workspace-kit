# Sync SSOT agents into .cursor/agents for Cursor workspace loading.
# SSOT: shared/agents
# Do not edit .cursor/agents directly — edit SSOT and re-run this script.

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Src = Join-Path $Root "shared\agents"
$Dest = Join-Path $Root ".cursor\agents"

if (-not (Test-Path $Src)) {
    Write-Host "sync-agents: no shared/agents at $Src"
    exit 0
}

if (-not (Test-Path $Dest)) {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
}

Get-ChildItem -Path $Dest -Filter "*.md" -ErrorAction SilentlyContinue | Remove-Item -Force

$count = 0
Get-ChildItem -Path $Src -Filter "*.md" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $Dest $_.Name) -Force
    $count++
}

Write-Host "sync-agents: copied $count agent file(s) to $Dest"
