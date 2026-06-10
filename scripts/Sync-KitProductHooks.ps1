# Sync kit-managed Cursor hook scripts + hooks.json into a product workspace.
# Called from sync-kit-product.ps1 (and Invoke-KitStartSetting.ps1).

param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceRoot,
    [Parameter(Mandatory = $true)]
    [string]$KitRoot
)

$ErrorActionPreference = "Stop"
$WorkspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$KitRoot = (Resolve-Path -LiteralPath $KitRoot).Path

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Merge-HookEntryIntoJson {
    param(
        [string]$HooksPath,
        [string]$EventName,
        [hashtable]$NewEntry,
        [string]$ScriptMarker
    )

    if (-not (Test-Path -LiteralPath $HooksPath)) { return "no hooks.json" }

    $raw = Get-Content -LiteralPath $HooksPath -Raw -Encoding UTF8
    if ($raw -match [regex]::Escape($ScriptMarker)) { return "exists ($ScriptMarker)" }

    $doc = $raw | ConvertFrom-Json
    if (-not $doc.hooks) {
        $doc | Add-Member -NotePropertyName hooks -NotePropertyValue (New-Object PSObject) -Force
    }

    $list = New-Object System.Collections.ArrayList
    [void]$list.Add($NewEntry)
    $existingProp = $doc.hooks.PSObject.Properties | Where-Object { $_.Name -eq $EventName } | Select-Object -First 1
    if ($existingProp -and $existingProp.Value) {
        foreach ($item in @($existingProp.Value)) {
            [void]$list.Add($item)
        }
    }
    $doc.hooks | Add-Member -NotePropertyName $EventName -NotePropertyValue @($list.ToArray()) -Force
    $doc | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $HooksPath -Encoding UTF8
    return "merged ($ScriptMarker)"
}

function Ensure-HooksJsonFile {
    param([string]$Root)

    $hooksPath = Join-Path $Root ".cursor\hooks.json"
    if (Test-Path -LiteralPath $hooksPath) { return }

    Ensure-Dir -Path (Join-Path $Root ".cursor")
    @{
        version = 1
        hooks   = @{}
    } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $hooksPath -Encoding UTF8
}

function Resolve-KitHookScriptSource {
    param(
        [string]$KitRoot,
        [string]$FileName
    )

    $candidates = @(
        (Join-Path $KitRoot "shared\hooks\$FileName"),
        (Join-Path $KitRoot ".cursor\hooks\$FileName"),
        (Join-Path $KitRoot "project-kit\.cursor\hooks\$FileName")
    )
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

function Copy-KitHookScript {
    param(
        [string]$KitRoot,
        [string]$HooksDest,
        [string]$FileName
    )

    $src = Resolve-KitHookScriptSource -KitRoot $KitRoot -FileName $FileName
    if (-not $src) { return $false }
    $dest = Join-Path $HooksDest $FileName
    if (Test-Path -LiteralPath $dest) {
        $srcResolved = (Resolve-Path -LiteralPath $src).Path
        $destResolved = (Resolve-Path -LiteralPath $dest).Path
        if ($srcResolved -ieq $destResolved) {
            return $true
        }
    }
    Ensure-Dir -Path $HooksDest
    Copy-Item -LiteralPath $src -Destination $dest -Force
    return $true
}

function Resolve-ObsidianInstallScript {
    param(
        [string]$WorkspaceRoot,
        [string]$KitRoot
    )

    $local = Join-Path $WorkspaceRoot "scripts\obsidian\install-hook.ps1"
    if (Test-Path -LiteralPath $local) { return $local }

    $fromKit = Join-Path $KitRoot "scripts\obsidian\install-hook.ps1"
    if (Test-Path -LiteralPath $fromKit) { return $fromKit }

    return $null
}

function Copy-KitSlashCommands {
    param(
        [string]$KitRoot,
        [string]$CommandsDest
    )

    $sources = @(
        (Join-Path $KitRoot "project-kit\.cursor\commands"),
        (Join-Path $KitRoot ".cursor\commands")
    )

    $n = 0
    foreach ($srcDir in $sources) {
        if (-not (Test-Path -LiteralPath $srcDir)) { continue }
        if (-not (Test-Path -LiteralPath $CommandsDest)) {
            New-Item -ItemType Directory -Path $CommandsDest -Force | Out-Null
        }
        Get-ChildItem -LiteralPath $srcDir -Filter "*.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = Join-Path $CommandsDest $_.Name
            if (Test-Path -LiteralPath $dest) {
                $srcResolved = (Resolve-Path -LiteralPath $_.FullName).Path
                $destResolved = (Resolve-Path -LiteralPath $dest).Path
                if ($srcResolved -ieq $destResolved) { return }
            }
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
            $n++
        }
    }
    return $n
}

function Test-ObsidianAvailable {
    param(
        [string]$WorkspaceRoot,
        [string]$KitRoot
    )
    return ($null -ne (Resolve-ObsidianInstallScript -WorkspaceRoot $WorkspaceRoot -KitRoot $KitRoot))
}

$hooksDest = Join-Path $WorkspaceRoot ".cursor\hooks"
$hooksPath = Join-Path $WorkspaceRoot ".cursor\hooks.json"
$gitDir = Join-Path $WorkspaceRoot ".git"

$hookFiles = @(
    "kit-start-on-prompt.ps1"
    "work-log-on-prompt.ps1"
    "guard-shell.ps1"
    "guard-shell.patterns.json"
    "quality-gate.ps1"
    "dev-server-harness.ps1"
    "ensure-obsidian-git-hook.ps1"
    "sync-docs-on-doc-change.ps1"
    "bootstrap-obsidian-once.ps1"
)

$copied = 0
foreach ($name in $hookFiles) {
    if (Copy-KitHookScript -KitRoot $KitRoot -HooksDest $hooksDest -FileName $name) {
        $copied++
    }
}

Ensure-HooksJsonFile -Root $WorkspaceRoot

$ps = "powershell -NoProfile -ExecutionPolicy Bypass -File .cursor/hooks/"
$mergeResults = New-Object System.Collections.ArrayList

[void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "beforeSubmitPrompt" -ScriptMarker "kit-start-on-prompt.ps1" -NewEntry @{
    command = ($ps + "kit-start-on-prompt.ps1")
    matcher = "UserPromptSubmit"
    timeout = 120
}))
[void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "beforeSubmitPrompt" -ScriptMarker "work-log-on-prompt.ps1" -NewEntry @{
    command = ($ps + "work-log-on-prompt.ps1")
    matcher = "UserPromptSubmit"
    timeout = 15
}))
[void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "beforeShellExecution" -ScriptMarker "guard-shell.ps1" -NewEntry @{
    command = ($ps + "guard-shell.ps1")
    timeout = 10
}))
[void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "afterShellExecution" -ScriptMarker "dev-server-harness.ps1#afterShellExecution" -NewEntry @{
    command = ($ps + "dev-server-harness.ps1")
    matcher = "npm run dev|pnpm dev|yarn dev|next dev|vite|uvicorn|flask run|ng serve|expo start"
    timeout = 15
}))
[void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "afterAgentResponse" -ScriptMarker "quality-gate.ps1" -NewEntry @{
    command = ($ps + "quality-gate.ps1")
    timeout = 25
}))
[void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "afterAgentResponse" -ScriptMarker "dev-server-harness.ps1#afterAgentResponse" -NewEntry @{
    command = ($ps + "dev-server-harness.ps1")
    timeout = 15
}))
[void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "stop" -ScriptMarker "dev-server-harness.ps1#stop" -NewEntry @{
    command = ($ps + "dev-server-harness.ps1")
    timeout = 30
}))

$obsidianOk = Test-ObsidianAvailable -WorkspaceRoot $WorkspaceRoot -KitRoot $KitRoot
$obsidianPostCommit = "skip"
if ($obsidianOk) {
    [void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "sessionStart" -ScriptMarker "bootstrap-obsidian-once.ps1" -NewEntry @{
        command = ($ps + "bootstrap-obsidian-once.ps1")
        timeout = 30
    }))
    [void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "afterFileEdit" -ScriptMarker "ensure-obsidian-git-hook.ps1" -NewEntry @{
        command = ($ps + "ensure-obsidian-git-hook.ps1")
        matcher = "Write|TabWrite"
        timeout = 20
    }))
    [void]$mergeResults.Add((Merge-HookEntryIntoJson -HooksPath $hooksPath -EventName "afterFileEdit" -ScriptMarker "sync-docs-on-doc-change.ps1" -NewEntry @{
        command = ($ps + "sync-docs-on-doc-change.ps1")
        matcher = "Write|TabWrite"
        timeout = 20
    }))

    if (Test-Path -LiteralPath $gitDir) {
        $installScript = Resolve-ObsidianInstallScript -WorkspaceRoot $WorkspaceRoot -KitRoot $KitRoot
        $ingestCommon = Join-Path (Split-Path -Parent $installScript) "Obsidian-IngestCommon.ps1"
        $noJournal = $true
        if (Test-Path -LiteralPath $ingestCommon) {
            . $ingestCommon
            $ingest = Get-ObsidianIngestSettings -RepoPath $WorkspaceRoot
            $noJournal = -not [bool]$ingest.CommitJournal
        }

        $installArgs = @(
            "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $installScript,
            "-TargetRepo", $WorkspaceRoot
        )
        if ($noJournal) { $installArgs += "-NoCommitJournal" }

        & powershell @installArgs
        if ($LASTEXITCODE -eq 0) {
            $obsidianPostCommit = if ($noJournal) { "post-commit sync-only" } else { "post-commit with journal" }
        }
        else {
            $obsidianPostCommit = "post-commit install failed (exit $LASTEXITCODE)"
        }

        $marker = Join-Path $WorkspaceRoot ".cursor\state\obsidian-post-commit.ok"
        Remove-Item -LiteralPath $marker -Force -ErrorAction SilentlyContinue
    }
}

$commandsDest = Join-Path $WorkspaceRoot ".cursor\commands"
$commandsCopied = Copy-KitSlashCommands -KitRoot $KitRoot -CommandsDest $commandsDest

Write-Host "sync-kit-product-hooks: copied $copied hook file(s); commands=$commandsCopied; hooks.json: $($mergeResults -join '; '); obsidian: $obsidianPostCommit"
