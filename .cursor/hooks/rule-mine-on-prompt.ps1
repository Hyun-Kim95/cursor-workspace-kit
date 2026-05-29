# beforeSubmitPrompt: /kit-rule-mine | /rule-mine — transcript rule mining (no manual terminal)
$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$commonPath = Join-Path $projectRoot "scripts\Kit-HookCommon.ps1"
if (-not (Test-Path -LiteralPath $commonPath)) { exit 0 }
. $commonPath
Initialize-KitHookConsole

function Get-AllStringValues {
    param([object]$Node)
    $values = New-Object System.Collections.Generic.List[string]
    if ($null -eq $Node) { return $values }
    if ($Node -is [string]) { $values.Add($Node); return $values }
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

function Get-PromptText {
    param([object]$Payload)
    if ($null -eq $Payload) { return "" }
    if ($Payload.PSObject.Properties.Name -contains "prompt") { return [string]$Payload.prompt }
    $all = Get-AllStringValues -Node $Payload
    if ($all.Count -eq 0) { return "" }
    return ($all -join "`n")
}

try {
    $payload = Read-HookStdinJson
    if ($null -eq $payload) { exit 0 }

    $prompt = Get-PromptText -Payload $payload
    if ([string]::IsNullOrWhiteSpace($prompt)) { exit 0 }

    $isMine = ($prompt -match '(?im)^\s*/(?:kit-)?rule-mine(\s+|$)')
    $isMineKo = (-not $isMine) -and ($prompt -match '(?im)^\s*규칙\s*마이닝(\s+|$)')
    if (-not $isMine -and -not $isMineKo) { exit 0 }

    $import = ($prompt -match '(?im)\bimport\b') -or ($prompt -match '후보\s*병합|ndjson')
    $sinceDays = 0
    if ($prompt -match '(?im)(?:since|days?|일)\s*[:=]?\s*(\d+)') {
        [void][int]::TryParse($Matches[1], [ref]$sinceDays)
    }
    elseif ($prompt -match '(?im)\b(\d{2,3})\s*일') {
        [void][int]::TryParse($Matches[1], [ref]$sinceDays)
    }

    $scriptPath = Join-Path $projectRoot "scripts\agent\Invoke-TranscriptRuleMining.ps1"
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        Write-HookJson -Object @{
            continue     = $false
            user_message = "Invoke-TranscriptRuleMining.ps1 not found. sync kit or open cursor-workspace-kit repo."
        }
        exit 2
    }

    $args = @(
        "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $scriptPath,
        "-WorkspaceRoot", $projectRoot
    )
    if ($sinceDays -gt 0) {
        $args += @("-SinceDays", [string]$sinceDays)
    }
    if ($import) {
        $args += "-ImportToCandidates"
    }

    & powershell @args
    if ($LASTEXITCODE -ne 0) {
        Write-HookJson -Object @{
            continue     = $false
            user_message = "규칙 마이닝 스크립트 실패 (exit $LASTEXITCODE). 로그 확인."
        }
        exit 2
    }

    $statePath = Join-Path $projectRoot ".cursor\state\rule-mine-last.json"
    $msg = "규칙 마이닝 완료."
    $top = @()
    if (Test-Path -LiteralPath $statePath) {
        try {
            $st = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($st.message) { $msg = [string]$st.message }
            if ($st.top_clusters) { $top = @($st.top_clusters) }
        }
        catch { }
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add($msg)
    $lines.Add("리포트: .cursor/state/rule-mined-report.md")
    if ($import) { $lines.Add("후보: docs/agent/rule-candidates.ndjson (import)") }
    else { $lines.Add("후보 병합: /kit-rule-mine import") }
    $lines.Add("목록: 채팅에 '규칙 후보 목록'")
    if ($top.Count -gt 0) {
        $lines.Add("상위 클러스터:")
        foreach ($t in $top) { $lines.Add("  $t") }
    }

    Write-HookJson -Object @{
        continue         = $true
        user_message     = ($lines -join "`n")
        additional_context = "rule-mine: $($lines[0]). 에이전트는 리포트 요약·HUMAN 검토를 돕고, SSOT 반영은 승인 후 shared/* 만."
    }
    exit 0
}
catch {
    Write-HookJson -Object @{
        continue     = $false
        user_message = "rule-mine hook: $(Get-HookErrorText -ErrorRecord $_)"
    }
    exit 2
}
