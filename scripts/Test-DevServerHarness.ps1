# Smoke test for dev-server harness helpers (no live port kill).
$ErrorActionPreference = "Stop"
$KitRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $KitRoot "scripts\Kit-HookCommon.ps1")

$h = Get-KitHarnessConfig -WorkspaceRoot $KitRoot
if ($h.DevServerCleanup.Mode -ne "kill") {
    throw "Expected devServerCleanup.mode kill, got $($h.DevServerCleanup.Mode)"
}

$ports = Get-DevServerPortsFromText -Text "ready on http://localhost:3000`nPort 3001"
if ($ports -notcontains 3000 -or $ports -notcontains 3001) {
    throw "Port parse failed: $($ports -join ',')"
}

$tmp = Join-Path $env:TEMP ("kit-dev-server-test-" + [guid]::NewGuid().ToString("n"))
$stateDir = Join-Path $tmp ".cursor\state"
New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
$cfg = @{
    RegistryFile = ".cursor/state/agent-dev-servers.json"
    KeepFile     = ".cursor/state/dev-server-keep.json"
    LogPath      = ".cursor/state/dev-server-cleanup.log"
}

Add-DevServerKeepFromAgentText -ProjectRoot $tmp -DevServerConfig $cfg -ConversationId "c1" -Text "dev-server-keep: 3001 - browser check" | Out-Null
$keepPath = Join-Path $tmp ($cfg.KeepFile -replace '/', '\')
$doc = Read-DevServerKeepRegistry -Path $keepPath
if ($doc.keeps.Count -ne 1) {
    throw "Expected 1 keep entry, got $($doc.keeps.Count)"
}

Write-Host "Test-DevServerHarness: OK"
Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
