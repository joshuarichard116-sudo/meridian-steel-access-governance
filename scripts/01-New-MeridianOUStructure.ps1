<#
.SYNOPSIS
    Creates the Meridian OU structure (idempotent - safe to re-run).
.EXAMPLE
    .\01-New-MeridianOUStructure.ps1 -WhatIf
#>
#Requires -Modules ActiveDirectory
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'MeridianConfig.psd1')
)

$cfg = Import-PowerShellDataFile -Path $ConfigPath

function New-OUIfMissing {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Name, [string]$Path)
    $dn = "OU=$Name,$Path"
    try {
        Get-ADOrganizationalUnit -Identity $dn -ErrorAction Stop | Out-Null
        Write-Verbose "Exists: $dn"
    } catch {
        if ($PSCmdlet.ShouldProcess($dn, 'Create OU')) {
            New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
            Write-Host "Created: $dn"
        }
    }
    return $dn
}

$root  = New-OUIfMissing -Name $cfg.RootOU -Path $cfg.DomainDN
$users = New-OUIfMissing -Name 'Users' -Path $root

foreach ($ou in 'Groups', 'Computers', 'Service Accounts', 'Admin Accounts', 'Disabled Users') {
    New-OUIfMissing -Name $ou -Path $root | Out-Null
}

foreach ($dept in $cfg.Departments) {
    New-OUIfMissing -Name $dept.Code -Path $users | Out-Null
}
