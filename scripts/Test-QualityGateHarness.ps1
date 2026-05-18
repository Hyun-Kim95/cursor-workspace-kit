# Manual verification for quality-gate.ps1 (Harness stage 2)
$ErrorActionPreference = "Stop"
$ScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$KitRoot = Split-Path -Parent $ScriptsDir
$QgScript = Join-Path $KitRoot ".cursor\hooks\quality-gate.ps1"

if (-not (Test-Path -LiteralPath $QgScript)) {
    Write-Error "Run sync-hooks.ps1 first. Missing $QgScript"
    exit 1
}

$failures = New-Object System.Collections.ArrayList

function Assert-Case {
    param([string]$Name, [bool]$Condition, [string]$Detail = "")
    if (-not $Condition) {
        $msg = "FAIL: $Name"
        if ($Detail) { $msg += " — $Detail" }
        [void]$failures.Add($msg)
        Write-Host $msg
    }
    else {
        Write-Host "PASS: $Name"
    }
}

$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("kit-qg-test-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $temp -Force | Out-Null
$hooksDir = Join-Path $temp ".cursor\hooks"
$stateDir = Join-Path $temp ".cursor\state"
$wsScriptsDir = Join-Path $temp "scripts"
New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
New-Item -ItemType Directory -Path $wsScriptsDir -Force | Out-Null

& (Join-Path $ScriptsDir "sync-hooks.ps1") | Out-Null
Copy-Item -LiteralPath (Join-Path $KitRoot ".cursor\hooks\quality-gate.ps1") -Destination (Join-Path $hooksDir "quality-gate.ps1") -Force
Copy-Item -LiteralPath (Join-Path $ScriptsDir "Kit-HookCommon.ps1") -Destination (Join-Path $wsScriptsDir "Kit-HookCommon.ps1") -Force

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText((Join-Path $temp ".cursor-kit.json"), @'
{
  "kitRepoMode": "submodule",
  "harness": {
    "qualityGate": { "mode": "warn" }
  }
}
'@, $utf8NoBom)

[System.IO.File]::WriteAllText((Join-Path $temp ".cursor\quality-gate.json"), @'
{
  "version": 1,
  "enabled": true,
  "onlyWhen": {
    "deliveryLoopEnabled": true,
    "lifecyclePhases": ["verify"]
  },
  "commands": [
    { "id": "stub", "shell": "exit 0", "maxSeconds": 10, "required": false }
  ],
  "onFailure": "warn"
}
'@, $utf8NoBom)

[System.IO.File]::WriteAllText((Join-Path $stateDir "delivery-ralph.json"), @'
{
  "version": 1,
  "enabled": true,
  "lifecyclePhase": "verify",
  "checklistItems": []
}
'@, $utf8NoBom)

try {
    $qgHook = Join-Path $hooksDir "quality-gate.ps1"
    $prev = Get-Location
    Set-Location -LiteralPath $temp
    & powershell -NoProfile -ExecutionPolicy Bypass -File $qgHook
    $exitCode = $LASTEXITCODE
    Set-Location -LiteralPath $prev.Path

    $statePath = Join-Path $temp ".cursor\state\quality-gate-last.json"
    Assert-Case -Name "run exit 0" -Condition ($exitCode -eq 0)
    Assert-Case -Name "state file exists" -Condition (Test-Path -LiteralPath $statePath)

    if (Test-Path -LiteralPath $statePath) {
        $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
        Assert-Case -Name "state ok true" -Condition ($state.ok -eq $true)
    }

    # Case: qualityGate off -> no state update on second run without config
    [System.IO.File]::WriteAllText((Join-Path $temp ".cursor-kit.json"), @'
{
  "harness": { "qualityGate": { "mode": "off" } }
}
'@, $utf8NoBom)
    Remove-Item -LiteralPath $statePath -Force -ErrorAction SilentlyContinue
    Set-Location -LiteralPath $temp
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $hooksDir "quality-gate.ps1")
    Set-Location -LiteralPath $prev.Path
    Assert-Case -Name "off skips" -Condition (-not (Test-Path -LiteralPath $statePath))
}
finally {
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Test-QualityGateHarness: $($failures.Count) failure(s)."
    exit 1
}

Write-Host ""
Write-Host "Test-QualityGateHarness: all cases passed."
exit 0
