# Smoke test for transcript rule mining (fixture only).
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "RuleSignalCommon.ps1")
$kitRoot = $script:RuleSignalKitRoot
$fixtureRoot = Join-Path $scriptDir "fixtures\projects"
$convFile = Join-Path $fixtureRoot "test-project\agent-transcripts\sample-conv-001\sample-conv-001.jsonl"
if (-not (Test-Path -LiteralPath $convFile)) {
    Write-Error "Fixture missing: $convFile"
}

$stateDir = Join-Path $kitRoot ".cursor\state"
$reportJson = Join-Path $stateDir "rule-mined-report.json"
if (Test-Path -LiteralPath $reportJson) { Remove-Item -LiteralPath $reportJson -Force }

& (Join-Path $scriptDir "Invoke-TranscriptRuleMining.ps1") `
    -WorkspaceRoot $kitRoot `
    -TranscriptsRoot $fixtureRoot `
    -MaxFiles 10 `
    -TopClusters 10 `
    -SinceDays 0 `
    -MinConversationHits 1 `
    -MinDistinctConversations 1

if (-not (Test-Path -LiteralPath $reportJson)) {
    Write-Error "Expected report not created: $reportJson"
}

$report = Get-Content -LiteralPath $reportJson -Raw -Encoding UTF8 | ConvertFrom-Json
if ($report.files_scanned -lt 1) {
    Write-Error "Expected at least 1 file scanned."
}
if ($null -eq $report.clusters) {
    Write-Error "Expected clusters array in report."
}

$clusterCount = @($report.clusters).Count
if ($clusterCount -lt 1) {
    Write-Error "Expected at least 1 cluster from fixture signals."
}
Write-Host "Test-TranscriptRuleMining: OK (files=$($report.files_scanned) clusters=$clusterCount)"
exit 0
