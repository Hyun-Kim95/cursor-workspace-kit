#!/usr/bin/env pwsh
# sessionStart: SSOT -> .cursor/rules|skills|agents (fail-open)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-HookWarning {
    param([string]$ProjectRoot, [string]$Message)
    try {
        $stateDir = Join-Path $ProjectRoot ".cursor\state"
        if (-not (Test-Path -LiteralPath $stateDir)) {
            New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
        }
        $logPath = Join-Path $stateDir "sync-kit-hook-warnings.log"
        $ts = (Get-Date).ToString("s")
        Add-Content -LiteralPath $logPath -Value "[$ts] sync-kit-on-session: $Message" -Encoding UTF8
    }
    catch { }
}

try {
    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
    $syncScript = Join-Path $projectRoot "scripts\sync-kit.ps1"
    if (-not (Test-Path -LiteralPath $syncScript)) {
        exit 0
    }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $syncScript
    exit 0
}
catch {
    Write-HookWarning -ProjectRoot $projectRoot -Message $_.Exception.Message
    exit 0
}
