# Mark rule-candidates.ndjson entries rejected after SSOT promotion (local only).
param(
    [string]$WorkspaceRoot = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$kitRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
. (Join-Path $kitRoot "scripts\Kit-HookCommon.ps1")

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = $kitRoot
}

$path = Join-Path $WorkspaceRoot "docs\agent\rule-candidates.ndjson"
if (-not (Test-Path -LiteralPath $path)) {
    Write-Host "No candidates file: $path"
    exit 0
}

$dup = @(4, 12, 15, 16, 22)
$vc = @(0, 2, 8, 9, 20, 21)
$dc = @(6, 11, 18, 24)

$out = New-Object System.Collections.Generic.List[string]
$now = (Get-Date).ToString("o")
$approvalPath = Join-Path $WorkspaceRoot "docs\agent\rule-approvals.md"

foreach ($line in ((Read-KitUtf8File -Path $path) -split "`r?`n")) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $o = $line | ConvertFrom-Json
    $clone = [ordered]@{}
    foreach ($p in $o.PSObject.Properties) {
        $clone[$p.Name] = $p.Value
    }
    $id = [string]$clone.id
    if ($id -match 'rc_mined_(\d+)') {
        $n = [int]$Matches[1]
        $reason = "product-only; not kit SSOT"
        if ($dup -contains $n) { $reason = "duplicate verify-change 8-10" }
        elseif ($vc -contains $n) { $reason = "promoted verify-change 11-12" }
        elseif ($dc -contains $n) { $reason = "promoted document-change step 0" }
        $clone.status = "rejected"
        $clone.rejected_at = $now
        $clone.rejected_reason = $reason
    }
    $out.Add(($clone | ConvertTo-Json -Compress))
}

Write-KitUtf8File -Path $path -Content (($out -join "`n") + "`n")

if (-not (Test-Path -LiteralPath $approvalPath)) {
    Write-KitUtf8File -Path $approvalPath -Content @(
        "# Rule approvals",
        "",
        "| time | ID | result | note |",
        "|------|----|--------|------|",
        ""
    ) -join "`n"
}

foreach ($line in $out) {
    $item = $line | ConvertFrom-Json
    if ([string]$item.status -ne "rejected") { continue }
    $logLine = "| $(Get-Date -Format s) | $($item.id) | reject | $($item.rejected_reason) |"
    Add-Content -LiteralPath $approvalPath -Value $logLine -Encoding UTF8
}

Write-Host "Reject-RuleCandidatesBatch: $($out.Count) line(s) -> rejected"
exit 0
