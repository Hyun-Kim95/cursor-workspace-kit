# Shared helpers for Cursor hooks on Windows PowerShell 5.1 (UTF-8 stdout, no ConvertFrom-Json -Depth)

function Initialize-KitHookConsole {
    # Cursor reads hook stdout as UTF-8; default console on Korean Windows is often CP949.
    try {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [Console]::InputEncoding = $utf8
        [Console]::OutputEncoding = $utf8
        $global:OutputEncoding = $utf8
    }
    catch { }
}

function Write-HookJson {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Object
    )
    Initialize-KitHookConsole
    $json = $Object | ConvertTo-Json -Compress
    [Console]::Out.WriteLine($json)
}

function Read-HookStdinJson {
    $raw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($raw)) { return $null }
    return ($raw | ConvertFrom-Json)
}

function Get-HookErrorText {
    param(
        [Parameter(Mandatory = $true)]
        $ErrorRecord
    )
    $msg = $ErrorRecord.Exception.Message
    if ([string]::IsNullOrWhiteSpace($msg)) { return "Unknown error in kit hook." }

    # PS 5.1 localized parameter errors (Korean) -> clear English for Cursor UI
    if ($msg -match "Depth") {
        return "PowerShell 5.1 does not support ConvertFrom-Json -Depth. Update kit-start hook scripts from cursor-workspace-kit."
    }
    if ($msg -match "매개 변수 이름 'Depth'" -or $msg -match "parameter name .Depth") {
        return "PowerShell 5.1 does not support ConvertFrom-Json -Depth. Update kit-start hook scripts from cursor-workspace-kit."
    }

    return $msg
}
