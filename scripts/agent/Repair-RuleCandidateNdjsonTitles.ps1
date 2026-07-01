# Fix mojibake in rule-candidates.ndjson title/rule_text (PS 5.1 .ps1 literal encoding).
param(
    [string]$WorkspaceRoot = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$kitRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
. (Join-Path $scriptDir "RuleSignalCommon.ps1")

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = $kitRoot
}

$path = Join-Path $WorkspaceRoot "docs\agent\rule-candidates.ndjson"
if (-not (Test-Path -LiteralPath $path)) {
    Write-Host "No candidates file: $path"
    exit 0
}

$config = Get-RuleSignalPatterns -WorkspaceRoot $WorkspaceRoot
$templates = Get-RuleCandidateTemplates -Config $config
$items = Read-RuleCandidateNdjson -Path $path
$lines = New-Object System.Collections.Generic.List[string]

foreach ($item in $items) {
    $clone = [ordered]@{}
    foreach ($p in $item.PSObject.Properties) {
        $clone[$p.Name] = $p.Value
    }

    $clusterKey = [string]$clone.cluster_key
    $snippet = [string]$clone.user_snippet
    $source = [string]$clone.source

    if (-not [string]::IsNullOrWhiteSpace($clusterKey)) {
        $clone.title = Expand-RuleCandidateTemplate -Template $templates.batchTitle -Placeholders @{ cluster_key = $clusterKey }
    }
    if (-not [string]::IsNullOrWhiteSpace($snippet)) {
        $tpl = if ($source -eq "hook:beforeSubmitPrompt") { $templates.realtimeRuleText } else { $templates.batchRuleText }
        $clone.rule_text = Expand-RuleCandidateTemplate -Template $tpl -Placeholders @{ snippet = $snippet }
    }

    $lines.Add(($clone | ConvertTo-Json -Compress))
}

Write-KitUtf8File -Path $path -Content (($lines -join "`n") + "`n")
Write-Host "Repair-RuleCandidateNdjsonTitles: $($lines.Count) line(s) updated -> $path"
exit 0
