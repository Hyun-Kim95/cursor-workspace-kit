# Sync kit SSOT from a kit root (submodule/embedded) into a product workspace .cursor/
# Channel A: project-kit rules + shared/skills + project-kit/skills + shared/agents + harness hooks
# Channel B: full shared + project-kit -> .cursor/rules|skills|agents + harness hooks

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

function Invoke-SyncKitProductHooks {
    param(
        [string]$WorkspaceRoot,
        [string]$KitRoot
    )
    $hooksSync = Join-Path $KitRoot "scripts\Sync-KitProductHooks.ps1"
    if (-not (Test-Path -LiteralPath $hooksSync)) {
        Write-Host "sync-kit-product-hooks: skip (Sync-KitProductHooks.ps1 not found)"
        return
    }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $hooksSync `
        -WorkspaceRoot $WorkspaceRoot -KitRoot $KitRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Sync-KitProductHooks.ps1 failed (exit $LASTEXITCODE)"
    }
}

# Channel A: project-kit rules only + these shared globals (planning/ops defaults).
$script:SharedGlobalRuleNames = @(
    "encoding-utf8-global.mdc"
    "product-monetization-default.mdc"
)

function Copy-SharedGlobalRules {
    param(
        [string]$SharedRulesDir,
        [string]$DestDir
    )
    $n = 0
    Ensure-Dir -Path $DestDir
    foreach ($name in $script:SharedGlobalRuleNames) {
        $src = Join-Path $SharedRulesDir $name
        if (-not (Test-Path -LiteralPath $src)) { continue }
        Copy-Item -LiteralPath $src -Destination (Join-Path $DestDir $name) -Force
        $n++
    }
    return $n
}

$rulesCount = 0
$skillsCount = 0
$agentsCount = 0

if ($Channel -eq "A") {
    $rulesCount = Copy-MdcFiles -SourceDir $projectKitRules -DestDir $rulesDest
    $rulesCount += Copy-SharedGlobalRules -SharedRulesDir $sharedRules -DestDir $rulesDest
    if (Test-Path -LiteralPath $sharedSkills) {
        $skillsCount = Copy-SkillFolders -SourceDir $sharedSkills -DestDir $skillsDest
    }
    $skillsCount += Copy-SkillFolders -SourceDir $projectKitSkills -DestDir $skillsDest
    if (Test-Path -LiteralPath $sharedAgents) {
        $agentsCount = Copy-AgentFiles -SourceDir $sharedAgents -DestDir $agentsDest
    }
    Invoke-SyncKitProductHooks -WorkspaceRoot $WorkspaceRoot -KitRoot $KitRoot
    Write-Host "sync-kit-product (channel A): rules=$rulesCount skill-folders=$skillsCount agents=$agentsCount"
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

    Invoke-SyncKitProductHooks -WorkspaceRoot $WorkspaceRoot -KitRoot $KitRoot
    Write-Host "sync-kit-product (channel B): rules=$rulesCount skills=$skillsCount agents=$agentsCount"
}

$encodingScript = Join-Path $KitRoot "scripts\Ensure-ProductEncodingAssets.ps1"
if (Test-Path -LiteralPath $encodingScript) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $encodingScript -WorkspaceRoot $WorkspaceRoot -KitRoot $KitRoot
    if ($LASTEXITCODE -ne 0) { throw "Ensure-ProductEncodingAssets.ps1 failed (exit $LASTEXITCODE)" }
}
