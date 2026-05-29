# Kit stub: write perf-last.json from perf-budget.json (no Lighthouse/k6 execution).
param(
    [string]$WorkspaceRoot = (Get-Location).Path,
    [string]$BudgetPath,
    [string]$StatePath
)

$ErrorActionPreference = 'Stop'
$common = Join-Path $PSScriptRoot '..\Kit-HookCommon.ps1'
if (-not (Test-Path -LiteralPath $common)) {
    Write-Error "Kit-HookCommon.ps1 not found at $common"
}
. $common

if (-not $BudgetPath) {
    $BudgetPath = Join-Path $WorkspaceRoot 'docs\requirements\perf-budget.json'
}
if (-not $StatePath) {
    $StatePath = Join-Path $WorkspaceRoot '.cursor\state\perf-last.json'
}

function New-PlatformResult {
    param([bool]$Enabled)
    if (-not $Enabled) {
        return @{
            enabled = $false
            skipped = $true
            ok      = $true
            metrics = @{}
        }
    }
    return @{
        enabled = $true
        skipped = $false
        ok      = $true
        metrics = @{}
        note    = 'kit-stub: no measurement; replace with product perf:ci'
    }
}

$platformKeys = @('web', 'app', 'api')
$platforms = @{}

if (-not (Test-Path -LiteralPath $BudgetPath)) {
    Write-Host "[perf-gate] skip: budget not found at $BudgetPath"
    foreach ($key in $platformKeys) {
        $platforms[$key] = New-PlatformResult -Enabled $false
    }
    $rootOk = $true
}
else {
    $raw = Read-KitUtf8File -Path $BudgetPath
    $budget = $raw | ConvertFrom-Json
    $rootOk = $true
    foreach ($key in $platformKeys) {
        $enabled = $false
        if ($budget.platforms.PSObject.Properties.Name -contains $key) {
            $p = $budget.platforms.$key
            if ($null -ne $p.enabled) { $enabled = [bool]$p.enabled }
        }
        $platforms[$key] = New-PlatformResult -Enabled $enabled
        if ($enabled -and -not $platforms[$key].ok) { $rootOk = $false }
    }
}

$out = @{
    ok        = $rootOk
    version   = 1
    updatedAt = (Get-Date).ToUniversalTime().ToString('o')
    command   = 'scripts/perf/Invoke-PerfGate.ps1 (kit-stub)'
    platforms = $platforms
}

Write-KitJsonFile -Path $StatePath -Object $out -Depth 6
Write-Host "[perf-gate] wrote $StatePath ok=$rootOk"
exit 0
