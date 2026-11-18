<#
.SYNOPSIS
    Creates SG-<Dept>-Staff / SG-<Dept>-Managers Global security groups,
    plus SG-AllManagers (contains every *-Managers group; used to scope Conditional Access).
.EXAMPLE
    .\02-New-MeridianSecurityGroups.ps1 -WhatIf
#>
#Requires -Modules ActiveDirectory
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'MeridianConfig.psd1')
)

$cfg      = Import-PowerShellDataFile -Path $ConfigPath
$groupsOU = "OU=Groups,OU=$($cfg.RootOU),$($cfg.DomainDN)"

function New-GroupIfMissing {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Name, [string]$Description)
    if (Get-ADGroup -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue) {
        Write-Verbose "Exists: $Name"
    } elseif ($PSCmdlet.ShouldProcess($Name, 'Create Global security group')) {
        New-ADGroup -Name $Name -SamAccountName $Name -GroupScope Global -GroupCategory Security `
            -Path $groupsOU -Description $Description
        Write-Host "Created: $Name"
    }
}

$managerGroups = @()
foreach ($dept in $cfg.Departments) {
    New-GroupIfMissing -Name "SG-$($dept.Code)-Staff"    -Description "$($dept.Name) - staff (Modify on department share)"
    New-GroupIfMissing -Name "SG-$($dept.Code)-Managers" -Description "$($dept.Name) - managers ($($cfg.ManagerRights) on department share)"
    $managerGroups += "SG-$($dept.Code)-Managers"
}

New-GroupIfMissing -Name 'SG-AllManagers' -Description 'All department manager groups - Conditional Access scope'

if ($PSCmdlet.ShouldProcess('SG-AllManagers', "Nest $($managerGroups.Count) manager groups")) {
    $existing = @(Get-ADGroupMember -Identity 'SG-AllManagers' | Select-Object -ExpandProperty SamAccountName)
    $toAdd    = $managerGroups | Where-Object { $_ -notin $existing }
    if ($toAdd) { Add-ADGroupMember -Identity 'SG-AllManagers' -Members $toAdd }
}
