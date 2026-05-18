# Sync kit SSOT from a kit root (submodule/embedded) into a product workspace .cursor/
# Channel A: project-kit rules + client-project-lifecycle only (global skills/agents unchanged)
# Channel B: full shared + project-kit -> .cursor/rules|skills|agents

param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceRoot,
    [Parameter(Mandatory = $true)]
    [string]$KitRoot,
    [Parameter(Mandatory = $false)]
    [ValidateSet("A", "B")]
    [string]$Channel = "B"
)

$ErrorActionPreference = "Stop"
$WorkspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$KitRoot = (Resolve-Path -LiteralPath $KitRoot).Path

$cursorDest = Join-Path $WorkspaceRoot ".cursor"
$rulesDest = Join-Path $cursorDest "rules"
$skillsDest = Join-Path $cursorDest "skills"
$agentsDest = Join-Path $cursorDest "agents"

$projectKitRules = Join-Path $KitRoot "project-kit\.cursor\rules"
$projectKitSkills = Join-Path $KitRoot "project-kit\.cursor\skills"
$sharedRules = Join-Path $KitRoot "shared\rules"
$sharedOptional = Join-Path $KitRoot "shared\optional"
$sharedSkills = Join-Path $KitRoot "shared\skills"
$sharedAgents = Join-Path $KitRoot "shared\agents"

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Copy-MdcFiles {
    param([string]$SourceDir, [string]$DestDir)
    if (-not (Test-Path -LiteralPath $SourceDir)) { return 0 }
    Ensure-Dir -Path $DestDir
    $n = 0
    Get-ChildItem -Path $SourceDir -Filter "*.mdc" -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestDir $_.Name) -Force
        $n++
    }
    return $n
}

function Copy-SkillFolders {
    param([string]$SourceDir, [string]$DestDir, [switch]$ReplaceAll)
    if (-not (Test-Path -LiteralPath $SourceDir)) { return 0 }
    Ensure-Dir -Path $DestDir
    if ($ReplaceAll) {
        Get-ChildItem -Path $DestDir -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
    }
    $n = 0
    Get-ChildItem -Path $SourceDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $target = Join-Path $DestDir $_.Name
        if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
        Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
        $n++
    }
    return $n
}

function Copy-AgentFiles {
    param([string]$SourceDir, [string]$DestDir, [switch]$ReplaceAll)
    if (-not (Test-Path -LiteralPath $SourceDir)) { return 0 }
    Ensure-Dir -Path $DestDir
    if ($ReplaceAll) {
        Get-ChildItem -Path $DestDir -Filter "*.md" -ErrorAction SilentlyContinue | Remove-Item -Force
    }
    $n = 0
    Get-ChildItem -Path $SourceDir -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestDir $_.Name) -Force
        $n++
    }
    return $n
}

$rulesCount = 0
$skillsCount = 0
$agentsCount = 0

if ($Channel -eq "A") {
    $rulesCount = Copy-MdcFiles -SourceDir $projectKitRules -DestDir $rulesDest
    $skillsCount = Copy-SkillFolders -SourceDir $projectKitSkills -DestDir $skillsDest
    Write-Host "sync-kit-product (channel A): rules=$rulesCount skill-folders=$skillsCount (project-kit only)"
}
else {
    Ensure-Dir -Path $rulesDest
    Get-ChildItem -Path $rulesDest -Filter "*.mdc" -ErrorAction SilentlyContinue | Remove-Item -Force
    $rulesCount += Copy-MdcFiles -SourceDir $sharedRules -DestDir $rulesDest
    $rulesCount += Copy-MdcFiles -SourceDir $sharedOptional -DestDir $rulesDest
    $rulesCount += Copy-MdcFiles -SourceDir $projectKitRules -DestDir $rulesDest
    $skillsCount = Copy-SkillFolders -SourceDir $sharedSkills -DestDir $skillsDest -ReplaceAll
    $skillsCount += Copy-SkillFolders -SourceDir $projectKitSkills -DestDir $skillsDest
    $agentsCount = Copy-AgentFiles -SourceDir $sharedAgents -DestDir $agentsDest -ReplaceAll

    $hooksDest = Join-Path $cursorDest "hooks"
    $sharedHooks = Join-Path $KitRoot "shared\hooks"
    $hookWhitelist = @("guard-shell.ps1", "guard-shell.patterns.json", "quality-gate.ps1")
    $hooksCount = 0
    if (Test-Path -LiteralPath $sharedHooks) {
        Ensure-Dir -Path $hooksDest
        foreach ($name in $hookWhitelist) {
            $src = Join-Path $sharedHooks $name
            if (Test-Path -LiteralPath $src) {
                Copy-Item -LiteralPath $src -Destination (Join-Path $hooksDest $name) -Force
                $hooksCount++
            }
        }
    }

    Write-Host "sync-kit-product (channel B): rules=$rulesCount skills=$skillsCount agents=$agentsCount harness-hooks=$hooksCount"
}
