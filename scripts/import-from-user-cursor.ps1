# Import User-level Cursor skills and agents into kit SSOT (shared/).
# Use when pulling latest from ~/.cursor into Git SSOT — not for day-to-day edits.
# Excludes: skills-cursor, client-project-lifecycle (project-kit SSOT).

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$UserCursor = Join-Path $env:USERPROFILE ".cursor"
$SkillsSrc = Join-Path $UserCursor "skills"
$AgentsSrc = Join-Path $UserCursor "agents"
$SkillsDest = Join-Path $Root "shared\skills"
$AgentsDest = Join-Path $Root "shared\agents"

$ExcludeSkills = @("client-project-lifecycle")

if (-not $Force) {
    Write-Host "import-from-user-cursor: overwrites shared/skills (except excluded) and shared/agents."
    Write-Host "Re-run with -Force to proceed."
    exit 1
}

if (-not (Test-Path $SkillsSrc)) {
    Write-Host "Skills source not found: $SkillsSrc"
    exit 1
}

New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null
New-Item -ItemType Directory -Path $AgentsDest -Force | Out-Null

$skillCount = 0
Get-ChildItem -Path $SkillsSrc -Directory | ForEach-Object {
    if ($ExcludeSkills -contains $_.Name) {
        Write-Host "  skip skill: $($_.Name)"
        return
    }
    $destDir = Join-Path $SkillsDest $_.Name
    if (Test-Path $destDir) {
        Remove-Item -Path $destDir -Recurse -Force
    }
    Copy-Item -Path $_.FullName -Destination $destDir -Recurse -Force
    $skillCount++
    Write-Host "  skill: $($_.Name)"
}

$agentCount = 0
if (Test-Path $AgentsSrc) {
    Get-ChildItem -Path $AgentsSrc -Filter "*.md" | ForEach-Object {
        $destFile = Join-Path $AgentsDest $_.Name
        Copy-Item -Path $_.FullName -Destination $destFile -Force
        if ($_.BaseName -eq "backend-agent") {
            $content = Get-Content -Path $destFile -Raw -Encoding UTF8
            $content = $content -replace '(?m)^# user-backend-agent\s*$', '# backend-agent'
            Set-Content -Path $destFile -Value $content -Encoding UTF8 -NoNewline
        }
        $agentCount++
        Write-Host "  agent: $($_.Name)"
    }
} else {
    Write-Host "Agents source not found: $AgentsSrc"
}

Write-Host "import-from-user-cursor: $skillCount skill(s), $agentCount agent(s) -> shared/"
Write-Host "Next: powershell -NoProfile -File scripts/sync-kit.ps1"
