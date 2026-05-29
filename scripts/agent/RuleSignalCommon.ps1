# Shared helpers for transcript rule mining and rule-signal-capture hook.
# Dot-source from Invoke-TranscriptRuleMining.ps1 and rule-signal-capture.ps1

$script:RuleSignalKitRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $script:RuleSignalKitRoot "scripts\Kit-HookCommon.ps1")

function Get-RuleSignalPatternsPath {
    param([string]$WorkspaceRoot)
    $hookPath = Join-Path $WorkspaceRoot ".cursor\hooks\rule-signal-patterns.json"
    if (Test-Path -LiteralPath $hookPath) { return $hookPath }
    $sharedPath = Join-Path $WorkspaceRoot "shared\hooks\rule-signal-patterns.json"
    if (Test-Path -LiteralPath $sharedPath) { return $sharedPath }
    return $null
}

function Get-RuleSignalPatterns {
    param([string]$WorkspaceRoot)

    $path = Get-RuleSignalPatternsPath -WorkspaceRoot $WorkspaceRoot
    if (-not $path) {
        throw "rule-signal-patterns.json not found under workspace."
    }

    $raw = Read-KitUtf8File -Path $path
    return ($raw | ConvertFrom-Json)
}

function Extract-UserQueryText {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }

    $t = $Text.Trim()
    if ($t -match '(?is)<user_query>\s*(.*?)\s*</user_query>') {
        return $Matches[1].Trim()
    }
    return $t
}

function Redact-UserSnippet {
    param(
        [string]$Text,
        [int]$MaxLength = 120
    )
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }

    $s = $Text
    $s = [regex]::Replace($s, '[A-Za-z]:\\[^\s''"<>|]+', '[path]')
    $s = [regex]::Replace($s, '/(?:usr|home|var|tmp|projects)[^\s''"<>|]*', '[path]')
    $s = [regex]::Replace($s, '\b[\w.+-]+@[\w.-]+\.\w+\b', '[email]')
    $s = [regex]::Replace($s, '\bsk-[A-Za-z0-9_-]{8,}\b', '[secret]')
    $s = [regex]::Replace($s, '(?i)Bearer\s+\S+', 'Bearer [redacted]')
    $s = $s -replace '\s+', ' '
    $s = $s.Trim()
    if ($s.Length -gt $MaxLength) {
        $s = $s.Substring(0, $MaxLength) + "..."
    }
    return $s
}

function Test-ExcludedUserText {
    param(
        [string]$Text,
        [object]$Config
    )
    if ([string]::IsNullOrWhiteSpace($Text)) { return $true }
    $minLen = 10
    if ($null -ne $Config.minUserTextLength) { $minLen = [int]$Config.minUserTextLength }
    if ($Text.Length -lt $minLen) { return $true }

    foreach ($pat in $Config.excludePatterns) {
        if ([string]::IsNullOrWhiteSpace($pat)) { continue }
        if ($Text -match $pat) { return $true }
    }
    return $false
}

function Get-TopicHintFromContext {
    param(
        [string]$UserText,
        [string]$AssistantContext,
        [object]$Config
    )

    $combined = "$UserText`n$AssistantContext"
    $defaultTarget = "verify-change"
    if ($null -ne $Config.default_suggested_target) {
        $defaultTarget = [string]$Config.default_suggested_target
    }

    $topicId = "general"
    $target = $defaultTarget
    if ($null -eq $Config.topicHints) {
        return @{ topic_id = $topicId; suggested_target = $target }
    }

    foreach ($hint in $Config.topicHints) {
        $keywords = @($hint.keywords)
        foreach ($kw in $keywords) {
            if ([string]::IsNullOrWhiteSpace($kw)) { continue }
            if ($combined -match [regex]::Escape($kw)) {
                $topicId = [string]$hint.id
                if ($null -ne $hint.suggested_target) {
                    $target = [string]$hint.suggested_target
                }
                return @{ topic_id = $topicId; suggested_target = $target }
            }
        }
    }

    return @{ topic_id = $topicId; suggested_target = $target }
}

function Get-RuleSignalMatches {
    param(
        [string]$UserText,
        [object]$Config
    )

    $results = @()
    if ([string]::IsNullOrWhiteSpace($UserText)) { return $results }
    if (Test-ExcludedUserText -Text $UserText -Config $Config) { return $results }

    foreach ($pat in $Config.patterns) {
        $regex = [string]$pat.regex
        if ([string]::IsNullOrWhiteSpace($regex)) { continue }
        if ($UserText -match $regex) {
            $results += [pscustomobject]@{
                pattern_id   = [string]$pat.id
                signal_type  = [string]$pat.signal_type
            }
        }
    }
    return $results
}

function New-ClusterKey {
    param(
        [string]$SignalType,
        [string]$TopicId
    )
    return "$SignalType|$TopicId"
}

function Read-RuleCandidateNdjson {
    param([string]$Path)

    $items = New-Object System.Collections.Generic.List[object]
    if (-not (Test-Path -LiteralPath $Path)) { return $items }
    foreach ($line in (Get-Content -LiteralPath $Path -Encoding UTF8)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $items.Add(($line | ConvertFrom-Json)) } catch { }
    }
    return $items
}

function Write-RuleCandidateNdjsonLine {
    param(
        [string]$Path,
        [object]$Candidate
    )
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Add-Content -LiteralPath $Path -Value ($Candidate | ConvertTo-Json -Compress) -Encoding UTF8
}
