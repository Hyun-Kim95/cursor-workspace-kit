# Sync all kit SSOT into .cursor/ (rules, skills, agents).

$ErrorActionPreference = "Stop"
$Scripts = Split-Path -Parent $MyInvocation.MyCommand.Path

& (Join-Path $Scripts "sync-rules.ps1")
& (Join-Path $Scripts "sync-skills.ps1")
& (Join-Path $Scripts "sync-agents.ps1")

Write-Host "sync-kit: done"
