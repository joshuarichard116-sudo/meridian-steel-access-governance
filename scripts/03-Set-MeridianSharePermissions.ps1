<#
.SYNOPSIS
    Builds the MeridianShares folder tree, applies NTFS permissions from the
    access matrix, and publishes one SMB share with Access-Based Enumeration.

.DESCRIPTION
    Pattern: share permissions are broad (Authenticated Users = Change),
    NTFS does the real enforcement. Department folders have inheritance
    removed and explicit ACEs only:
        SYSTEM, BUILTIN\Administrators   Full Control
        SG-<Dept>-Staff                  Modify
        SG-<Dept>-Managers               Full Control (or Modify - see config)
    The root folder grants Authenticated Users read on "this folder only"
    so users can open the share; ABE hides folders they cannot access.

.EXAMPLE
    .\03-Set-MeridianSharePermissions.ps1 -WhatIf
#>
#Requires -Modules ActiveDirectory, SmbShare
#Requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'MeridianConfig.psd1')
)

$cfg     = Import-PowerShellDataFile -Path $ConfigPath
$netbios = (Get-ADDomain).NetBIOSName
$mgrFlag = if ($cfg.ManagerRights -eq 'Modify') { 'M' } else { 'F' }

function Invoke-Icacls {
    param([string]$Path, [string[]]$Arguments)
    & icacls.exe $Path @Arguments | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "icacls failed on $Path (exit $LASTEXITCODE)" }
}

# --- Root folder ---------------------------------------------------------
if (-not (Test-Path $cfg.ShareRoot)) {
    if ($PSCmdlet.ShouldProcess($cfg.ShareRoot, 'Create folder')) {
        New-Item -ItemType Directory -Path $cfg.ShareRoot | Out-Null
    }
}
if ($PSCmdlet.ShouldProcess($cfg.ShareRoot, 'Set root NTFS ACL')) {
    Invoke-Icacls $cfg.ShareRoot @(
        '/inheritance:r'
        '/grant:r', 'SYSTEM:(OI)(CI)F'
        '/grant:r', 'BUILTIN\Administrators:(OI)(CI)F'
        '/grant:r', 'Authenticated Users:(RX)'     # this folder only - lets users traverse
    )
}

# --- Department folders ---------------------------------------------------
foreach ($dept in $cfg.Departments) {
    $path = Join-Path $cfg.ShareRoot $dept.Code
    if (-not (Test-Path $path)) {
        if ($PSCmdlet.ShouldProcess($path, 'Create folder')) {
            New-Item -ItemType Directory -Path $path | Out-Null
        }
    }
    if ($PSCmdlet.ShouldProcess($path, 'Set department NTFS ACL')) {
        Invoke-Icacls $path @(
            '/inheritance:r'
            '/grant:r', 'SYSTEM:(OI)(CI)F'
            '/grant:r', 'BUILTIN\Administrators:(OI)(CI)F'
            '/grant:r', "$netbios\SG-$($dept.Code)-Staff:(OI)(CI)M"
            '/grant:r', "$netbios\SG-$($dept.Code)-Managers:(OI)(CI)$mgrFlag"
        )
        Write-Host "ACL applied: $path"
    }
}

# --- SMB share with Access-Based Enumeration ------------------------------
if (-not (Get-SmbShare -Name $cfg.ShareName -ErrorAction SilentlyContinue)) {
    if ($PSCmdlet.ShouldProcess($cfg.ShareName, 'Create SMB share')) {
        New-SmbShare -Name $cfg.ShareName -Path $cfg.ShareRoot `
            -FullAccess 'BUILTIN\Administrators' `
            -ChangeAccess 'NT AUTHORITY\Authenticated Users' `
            -FolderEnumerationMode AccessBased | Out-Null
        Write-Host "Share created: \\$env:COMPUTERNAME\$($cfg.ShareName)"
    }
} elseif ($PSCmdlet.ShouldProcess($cfg.ShareName, 'Enable Access-Based Enumeration')) {
    Set-SmbShare -Name $cfg.ShareName -FolderEnumerationMode AccessBased -Force
}
