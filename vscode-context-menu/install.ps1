# Adds "Open this file in VS Code" and "Open folder in VS Code" to the
# Windows Explorer right-click menu for the current user.
#
# It finds Code.exe automatically, so it works on any computer.
# It only writes under HKEY_CURRENT_USER, so it does not need admin rights.
#
# Run:  powershell -ExecutionPolicy Bypass -File .\install.ps1
# Undo: double-click uninstall.reg

$ErrorActionPreference = 'Stop'

function Find-VSCode {
    # 1. The usual install locations (user install first, then system installs)
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\Code.exe'),
        (Join-Path $env:ProgramFiles 'Microsoft VS Code\Code.exe')
    )
    if (${env:ProgramFiles(x86)}) {
        $candidates += (Join-Path ${env:ProgramFiles(x86)} 'Microsoft VS Code\Code.exe')
    }
    foreach ($path in $candidates) {
        if (Test-Path -LiteralPath $path) { return $path }
    }

    # 2. The "code" command on PATH lives in <install folder>\bin\code.cmd
    $cmd = Get-Command code -ErrorAction SilentlyContinue
    if ($cmd) {
        $installDir = Split-Path (Split-Path $cmd.Source -Parent) -Parent
        $exe = Join-Path $installDir 'Code.exe'
        if (Test-Path -LiteralPath $exe) { return $exe }
    }

    return $null
}

$codeExe = Find-VSCode
if (-not $codeExe) {
    Write-Host 'Could not find VS Code (Code.exe). Install VS Code first, or check that "code" works in a terminal.' -ForegroundColor Red
    exit 1
}
Write-Host "Found VS Code: $codeExe"

# Registry keys to create. The .NET API is used because PowerShell treats
# the "*" in "Classes\*" as a wildcard.
$items = @(
    @{ Key = 'Software\Classes\*\shell\OpenInVSCode';                    Label = 'Open this file in VS Code'; Arg = '%1' },
    @{ Key = 'Software\Classes\Directory\shell\OpenInVSCode';            Label = 'Open folder in VS Code';    Arg = '%1' },
    @{ Key = 'Software\Classes\Directory\Background\shell\OpenInVSCode'; Label = 'Open folder in VS Code';    Arg = '%V' }
)

$hkcu = [Microsoft.Win32.Registry]::CurrentUser
foreach ($item in $items) {
    $key = $hkcu.CreateSubKey($item.Key)
    $key.SetValue('', $item.Label)
    $key.SetValue('Icon', $codeExe)
    $key.Close()

    $command = $hkcu.CreateSubKey($item.Key + '\command')
    $command.SetValue('', ('"{0}" "{1}"' -f $codeExe, $item.Arg))
    $command.Close()

    Write-Host "Added: $($item.Label)  ($($item.Key))"
}

Write-Host ''
Write-Host 'Done. Right-click a file, a folder, or empty space inside a folder to see the new items.' -ForegroundColor Green
Write-Host 'On Windows 11 they are under "Show more options", unless you enabled the classic menu (see ..\classic-context-menu).'
