#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-AllStringValues {
    param([object]$Node)

    $values = New-Object System.Collections.Generic.List[string]
    if ($null -eq $Node) { return $values }
    if ($Node -is [string]) {
        $values.Add($Node)
        return $values
    }
    if ($Node -is [System.Collections.IDictionary]) {
        foreach ($key in $Node.Keys) {
            foreach ($item in (Get-AllStringValues -Node $Node[$key])) { $values.Add($item) }
        }
        return $values
    }
    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
        foreach ($entry in $Node) {
            foreach ($item in (Get-AllStringValues -Node $entry)) { $values.Add($item) }
        }
        return $values
    }
    foreach ($prop in $Node.PSObject.Properties) {
        foreach ($item in (Get-AllStringValues -Node $prop.Value)) { $values.Add($item) }
    }
    return $values
}

try {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

    $hookDir = $PSScriptRoot
    $projectRoot = (Resolve-Path (Join-Path $hookDir "..\..")).Path
    $commonPath = Join-Path $projectRoot "scripts\agent\RuleSignalCommon.ps1"
    if (-not (Test-Path -LiteralPath $commonPath)) { exit 0 }
    . $commonPath

    $config = Get-RuleSignalPatterns -WorkspaceRoot $projectRoot
    $rtCfg = $config.realtime
    $dedupeHours = 24
    if ($null -ne $rtCfg -and $null -ne $rtCfg.dedupeHours) {
        $dedupeHours = [int]$rtCfg.dedupeHours
    }

    $payload = $raw | ConvertFrom-Json
    $allStrings = Get-AllStringValues -Node $payload
    if (-not $allStrings -or $allStrings.Count -eq 0) { exit 0 }
    $text = ($allStrings -join "`n")

    $userText = Extract-UserQueryText -Text $text
    if (Test-ExcludedUserText -Text $userText -Config $config) { exit 0 }

    $matches = Get-RuleSignalMatches -UserText $userText -Config $config
    if ($matches.Count -eq 0) { exit 0 }

    $conversationId = "unknown"
    if ($null -ne $payload.conversation_id) {
        $conversationId = [string]$payload.conversation_id
    }
    elseif ($null -ne $payload.conversationId) {
        $conversationId = [string]$payload.conversationId
    }

    $m = $matches[0]
    $topic = Get-TopicHintFromContext -UserText $userText -AssistantContext "" -Config $config
    $clusterKey = New-ClusterKey -SignalType $m.signal_type -TopicId $topic.topic_id
    $snippet = Redact-UserSnippet -Text $userText

    $candidatePath = Join-Path $projectRoot "docs\agent\rule-candidates.ndjson"
    $cutoff = (Get-Date).AddHours(-$dedupeHours)

    if (Test-Path -LiteralPath $candidatePath) {
        foreach ($line in (Get-Content -LiteralPath $candidatePath -Encoding UTF8)) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try {
                $item = $line | ConvertFrom-Json
                if ([string]$item.source -ne "hook:beforeSubmitPrompt") { continue }
                if ([string]$item.pattern_id -ne [string]$m.pattern_id) { continue }
                if ([string]$item.conversation_id -ne $conversationId) { continue }
                $created = [datetime]::MinValue
                if (-not [string]::IsNullOrWhiteSpace([string]$item.created_at)) {
                    [void][datetime]::TryParse([string]$item.created_at, [ref]$created)
                }
                if ($created -ge $cutoff) { exit 0 }
            }
            catch { }
        }
    }

    $ts = Get-Date -Format "yyyyMMdd_HHmmss"
    $candidate = [ordered]@{
        id               = "rc_sig_$ts"
        title            = "암묵적 보정 신호 (실시간)"
        scope            = "general"
        target           = "skill"
        target_path      = "shared/skills/$($topic.suggested_target)/SKILL.md"
        rule_text        = "(HUMAN) 검증 가능한 의무로 다듬기 — 신호: $snippet"
        source           = "hook:beforeSubmitPrompt"
        status           = "pending"
        created_at       = (Get-Date).ToString("o")
        signal_type      = $m.signal_type
        confidence       = "low"
        pattern_id       = $m.pattern_id
        conversation_id  = $conversationId
        suggested_target = $topic.suggested_target
        cluster_key      = $clusterKey
        user_snippet     = $snippet
    }
    Write-RuleCandidateNdjsonLine -Path $candidatePath -Candidate $candidate

    # Default: quiet (no additional_context). Enable notifyDailySummary in patterns if needed later.
    exit 0
}
catch {
    exit 0
}
