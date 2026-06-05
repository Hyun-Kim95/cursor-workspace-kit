# Kit stub: write security-last.json from security-policy.json (no gitleaks/audit execution).
param(
    [string]$WorkspaceRoot = (Get-Location).Path,
    [string]$PolicyPath,
    [string]$StatePath
)

$ErrorActionPreference = 'Stop'
$common = Join-Path $PSScriptRoot '..\Kit-HookCommon.ps1'
if (-not (Test-Path -LiteralPath $common)) {
    Write-Error "Kit-HookCommon.ps1 not found at $common"
}
. $common

if (-not $PolicyPath) {
    $PolicyPath = Join-Path $WorkspaceRoot 'docs\requirements\security-policy.json'
}
if (-not $StatePath) {
    $StatePath = Join-Path $WorkspaceRoot '.cursor\state\security-last.json'
}

function New-CheckResult {
    param([bool]$Enabled)
    if (-not $Enabled) {
        return @{
            enabled = $false
            skipped = $true
            ok      = $true
        }
    }
    return @{
        enabled = $true
        skipped = $false
        ok      = $true
        note    = 'kit-stub: no scan; replace with product security:ci'
    }
}

$checkKeys = @('secrets', 'dependencies', 'sast', 'authz', 'transport', 'data')
$checks = @{}
$tier = 'standard'
$rootOk = $true

if (-not (Test-Path -LiteralPath $PolicyPath)) {
    Write-Host "[security-gate] skip: policy not found at $PolicyPath"
    foreach ($key in $checkKeys) {
        $checks[$key] = New-CheckResult -Enabled $false
    }
}
else {
    $raw = Read-KitUtf8File -Path $PolicyPath
    $policy = $raw | ConvertFrom-Json
    if ($null -ne $policy.tier -and $policy.tier) {
        $tier = [string]$policy.tier
    }
    foreach ($key in $checkKeys) {
        $enabled = $false
        if ($policy.checks.PSObject.Properties.Name -contains $key) {
            $c = $policy.checks.$key
            if ($null -ne $c.enabled) { $enabled = [bool]$c.enabled }
        }
        $checks[$key] = New-CheckResult -Enabled $enabled
        if ($enabled -and -not $checks[$key].ok) { $rootOk = $false }
    }
}

$manualReview = @{
    authz = 'pending'
    owasp = 'pending'
}
if ($tier -eq 'strict') {
    $rootOk = $false
    $manualReview.authz = 'pending'
    $manualReview.owasp = 'pending'
}

$out = @{
    ok           = $rootOk
    version      = 1
    tier         = $tier
    updatedAt    = (Get-Date).ToUniversalTime().ToString('o')
    command      = 'scripts/security/Invoke-SecurityGate.ps1 (kit-stub)'
    checks       = $checks
    blockers     = @()
    manualReview = $manualReview
}

if ($tier -eq 'strict' -and $rootOk -eq $false) {
    $out.blockers = @('strict tier: implement security:ci and complete manualReview (authz, owasp)')
}

Write-KitJsonFile -Path $StatePath -Object $out -Depth 8
Write-Host "[security-gate] wrote $StatePath ok=$rootOk tier=$tier"
exit 0
