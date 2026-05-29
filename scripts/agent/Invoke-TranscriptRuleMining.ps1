# Mine implicit correction signals from Cursor agent-transcripts JSONL (local only).
param(
    [string]$WorkspaceRoot = "",
    [string]$TranscriptsRoot = "",
    [int]$SinceDays = 0,
    [int]$MaxFiles = 5000,
    [switch]$ImportToCandidates,
    [switch]$IncludeAllJsonl,
    [int]$TopClusters = 0,
    [int]$MinConversationHits = 0,
    [int]$MinDistinctConversations = 0
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "RuleSignalCommon.ps1")
$kitRoot = $script:RuleSignalKitRoot

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $WorkspaceRoot = $kitRoot
}
if ([string]::IsNullOrWhiteSpace($TranscriptsRoot)) {
    $TranscriptsRoot = Join-Path $env:USERPROFILE ".cursor\projects"
}

$config = Get-RuleSignalPatterns -WorkspaceRoot $WorkspaceRoot
$batchCfg = $config.batch
if ($TopClusters -lt 1) {
    $TopClusters = [int]$batchCfg.topClusters
    if ($TopClusters -lt 1) { $TopClusters = 30 }
}
$minHits = if ($MinConversationHits -gt 0) { $MinConversationHits } else { [int]$batchCfg.minConversationHits }
if ($minHits -lt 1) { $minHits = 3 }
$minConv = if ($MinDistinctConversations -gt 0) { $MinDistinctConversations } else { [int]$batchCfg.minDistinctConversations }
if ($minConv -lt 1) { $minConv = 2 }

$cutoff = $null
if ($SinceDays -gt 0) {
    $cutoff = (Get-Date).AddDays(-$SinceDays)
}

$stateDir = Join-Path $WorkspaceRoot ".cursor\state"
$reportJsonPath = Join-Path $stateDir "rule-mined-report.json"
$reportMdPath = Join-Path $stateDir "rule-mined-report.md"
$candidatePath = Join-Path $WorkspaceRoot "docs\agent\rule-candidates.ndjson"

# clusterKey -> { hits, conversations (hashset), signal_type, topic_id, suggested_target, sample_snippets }
$clusters = @{}

function Get-ProjectSlugFromPath {
    param([string]$JsonlPath)
    if ($JsonlPath -match '[\\/]projects[\\/]([^\\/]+)[\\/]') {
        return $Matches[1]
    }
    return "unknown"
}

function Get-ConversationIdFromPath {
    param([string]$JsonlPath)
    $dir = Split-Path -Parent $JsonlPath
    return (Split-Path -Leaf $dir)
}

function Add-ClusterHit {
    param(
        [string]$ClusterKey,
        [string]$SignalType,
        [string]$TopicId,
        [string]$SuggestedTarget,
        [string]$ConversationId,
        [string]$Snippet,
        [string]$PatternId
    )

    if (-not $clusters.ContainsKey($ClusterKey)) {
        $clusters[$ClusterKey] = @{
            cluster_key       = $ClusterKey
            signal_type       = $SignalType
            topic_id          = $TopicId
            suggested_target  = $SuggestedTarget
            pattern_id        = $PatternId
            hits              = 0
            conversation_ids  = @{}
            sample_snippets   = New-Object System.Collections.Generic.List[string]
        }
    }

    $c = $clusters[$ClusterKey]
    $c.hits++
    $c.conversation_ids[$ConversationId] = $true
    if ($c.sample_snippets.Count -lt 3 -and -not [string]::IsNullOrWhiteSpace($Snippet)) {
        $dup = $false
        foreach ($s in $c.sample_snippets) {
            if ($s -eq $Snippet) { $dup = $true; break }
        }
        if (-not $dup) { $c.sample_snippets.Add($Snippet) }
    }
}

$fileCount = 0
$userLineCount = 0
$signalHitCount = 0

if (-not (Test-Path -LiteralPath $TranscriptsRoot)) {
    Write-Error "TranscriptsRoot not found: $TranscriptsRoot"
}

$jsonlFiles = Get-ChildItem -LiteralPath $TranscriptsRoot -Filter "*.jsonl" -Recurse -File -ErrorAction SilentlyContinue
if (-not $IncludeAllJsonl) {
    $jsonlFiles = $jsonlFiles | Where-Object { $_.FullName -match 'agent-transcripts' }
}

foreach ($file in $jsonlFiles) {
    if ($fileCount -ge $MaxFiles) { break }
    if ($null -ne $cutoff -and $file.LastWriteTime -lt $cutoff) { continue }

    $fileCount++
    $conversationId = Get-ConversationIdFromPath -JsonlPath $file.FullName
    $projectSlug = Get-ProjectSlugFromPath -JsonlPath $file.FullName

    $assistantBuffer = New-Object System.Collections.Generic.List[string]
    $maxAssistantBuffer = 2

    foreach ($line in (Get-Content -LiteralPath $file.FullName -Encoding UTF8)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $row = $null
        try { $row = $line | ConvertFrom-Json } catch { continue }

        $role = [string]$row.role
        $textParts = New-Object System.Collections.Generic.List[string]
        if ($null -ne $row.message -and $null -ne $row.message.content) {
            foreach ($part in $row.message.content) {
                if ($null -ne $part.text) { $textParts.Add([string]$part.text) }
            }
        }
        $rawText = ($textParts -join "`n")

        if ($role -eq "assistant") {
            $assistantBuffer.Add($rawText)
            while ($assistantBuffer.Count -gt $maxAssistantBuffer) {
                $assistantBuffer.RemoveAt(0)
            }
            continue
        }

        if ($role -ne "user") { continue }
        $userLineCount++

        $userText = Extract-UserQueryText -Text $rawText
        if (Test-ExcludedUserText -Text $userText -Config $config) { continue }

        $ctx = ($assistantBuffer -join "`n")
        $topic = Get-TopicHintFromContext -UserText $userText -AssistantContext $ctx -Config $config
        $matches = Get-RuleSignalMatches -UserText $userText -Config $config
        if ($matches.Count -eq 0) { continue }

        $snippet = Redact-UserSnippet -Text $userText
        foreach ($m in $matches) {
            $signalHitCount++
            $clusterKey = New-ClusterKey -SignalType $m.signal_type -TopicId $topic.topic_id
            Add-ClusterHit -ClusterKey $clusterKey `
                -SignalType $m.signal_type `
                -TopicId $topic.topic_id `
                -SuggestedTarget $topic.suggested_target `
                -ConversationId $conversationId `
                -Snippet $snippet `
                -PatternId $m.pattern_id
        }
    }
}

# Filter clusters by batch thresholds
$ranked = @()
foreach ($key in $clusters.Keys) {
    $c = $clusters[$key]
    $convCount = $c.conversation_ids.Count
    if ($c.hits -lt $minHits -or $convCount -lt $minConv) { continue }

    $ranked += [pscustomobject]@{
        cluster_key      = $c.cluster_key
        signal_type      = $c.signal_type
        topic_id         = $c.topic_id
        suggested_target = $c.suggested_target
        pattern_id       = $c.pattern_id
        hits             = $c.hits
        conversations    = $convCount
        sample_snippets  = @($c.sample_snippets)
    }
}

$ranked = @($ranked | Sort-Object -Property hits, conversations -Descending)
if ($ranked.Count -gt $TopClusters) {
    $ranked = $ranked[0..($TopClusters - 1)]
}

$report = [ordered]@{
    generated_at    = (Get-Date).ToString("o")
    transcripts_root = $TranscriptsRoot
    since_days      = $SinceDays
    files_scanned   = $fileCount
    user_lines      = $userLineCount
    signal_hits_raw = $signalHitCount
    clusters        = $ranked
    thresholds      = @{
        min_conversation_hits      = $minHits
        min_distinct_conversations = $minConv
    }
}

Write-KitJsonFile -Path $reportJsonPath -Object $report -Depth 8

$mdLines = New-Object System.Collections.Generic.List[string]
$mdLines.Add("# Rule mined report")
$mdLines.Add("")
$mdLines.Add("- Generated: $($report.generated_at)")
$mdLines.Add("- Files scanned: $fileCount")
$mdLines.Add("- User lines: $userLineCount")
$mdLines.Add("- Raw signal hits: $signalHitCount")
$mdLines.Add("- Clusters (filtered): $($ranked.Count)")
$mdLines.Add("")
$mdLines.Add("| Rank | cluster | hits | conv | target | samples |")
$mdLines.Add("|------|---------|------|------|--------|---------|")
$rank = 1
foreach ($cl in $ranked) {
    $samples = ($cl.sample_snippets -join " / ") -replace '\|', '/'
    if ($samples.Length -gt 80) { $samples = $samples.Substring(0, 80) + "..." }
    $mdLines.Add("| $rank | $($cl.cluster_key) | $($cl.hits) | $($cl.conversations) | $($cl.suggested_target) | $samples |")
    $rank++
}
Write-KitUtf8File -Path $reportMdPath -Content ($mdLines -join "`n")

$statePath = Join-Path $stateDir "rule-mine-last.json"
$topLines = New-Object System.Collections.Generic.List[string]
$topN = [Math]::Min(5, $ranked.Count)
for ($i = 0; $i -lt $topN; $i++) {
    $cl = $ranked[$i]
    $topLines.Add("#$($i + 1) $($cl.cluster_key) hits=$($cl.hits) conv=$($cl.conversations)")
}
$state = [ordered]@{
    ok              = $true
    message         = "files=$fileCount userLines=$userLineCount clusters=$($ranked.Count)"
    files_scanned   = $fileCount
    user_lines      = $userLineCount
    cluster_count   = $ranked.Count
    report_json     = $reportJsonPath
    report_md       = $reportMdPath
    imported        = $false
    top_clusters    = @($topLines)
    generated_at    = (Get-Date).ToString("o")
}
Write-KitJsonFile -Path $statePath -Object $state -Depth 6

Write-Host "Invoke-TranscriptRuleMining: files=$fileCount userLines=$userLineCount clusters=$($ranked.Count)"
Write-Host "  report: $reportJsonPath"
Write-Host "  report: $reportMdPath"

if ($ImportToCandidates -and $ranked.Count -gt 0) {
    $existing = Read-RuleCandidateNdjson -Path $candidatePath
    $index = @{}
    foreach ($item in $existing) {
        if ($null -eq $item.cluster_key) { continue }
        $st = [string]$item.suggested_target
        $key = "$([string]$item.cluster_key)|$st"
        $index[$key] = $item
    }

    $imported = 0
    foreach ($cl in $ranked) {
        $mapKey = "$($cl.cluster_key)|$($cl.suggested_target)"
        $sampleText = if ($cl.sample_snippets.Count -gt 0) { $cl.sample_snippets[0] } else { $cl.cluster_key }

        if ($index.ContainsKey($mapKey)) {
            $item = $index[$mapKey]
            $item.stats = @{
                hits          = $cl.hits
                conversations = $cl.conversations
            }
            $imported++
            continue
        }

        $ts = Get-Date -Format "yyyyMMdd_HHmmss"
        $candidate = [ordered]@{
            id                = "rc_mined_$ts_$imported"
            title             = "배치 마이닝: $($cl.cluster_key)"
            scope             = "general"
            target            = "skill"
            target_path       = "shared/skills/$($cl.suggested_target)/SKILL.md"
            rule_text         = "(HUMAN) 검증 가능한 의무로 다듬기 — 신호: $sampleText"
            source            = "batch:transcript"
            status            = "pending"
            created_at        = (Get-Date).ToString("o")
            signal_type       = $cl.signal_type
            confidence        = "medium"
            pattern_id        = $cl.pattern_id
            suggested_target  = $cl.suggested_target
            cluster_key       = $cl.cluster_key
            stats             = @{
                hits          = $cl.hits
                conversations = $cl.conversations
            }
            user_snippet      = $sampleText
        }
        Write-RuleCandidateNdjsonLine -Path $candidatePath -Candidate $candidate
        $index[$mapKey] = $candidate
        $imported++
    }

    Write-Host "  ImportToCandidates: touched $imported cluster(s) -> $candidatePath"
    $state.imported = $true
    $state.message = "$($state.message); import=$imported"
    Write-KitJsonFile -Path $statePath -Object $state -Depth 6
}

exit 0
