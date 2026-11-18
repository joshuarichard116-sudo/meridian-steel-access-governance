<#
.SYNOPSIS
    LEAVER: disables an account, records then removes its group memberships,
    and moves it to the Disabled Users OU. After the next sync the user can no
    longer sign in to Entra ID, and group-based SaaS access is removed.

.DESCRIPTION
    Former groups are written to the account's 'info' (Notes) attribute so
    access can be audited or restored if the termination is reversed.

.EXAMPLE
    .\05-Disable-MeridianUser.ps1 -SamAccountName jsmith -WhatIf
#>
#Requires -Modules ActiveDirectory
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)][string]$SamAccountName,
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'MeridianConfig.psd1')
)

begin {
    $cfg        = Import-PowerShellDataFile -Path $ConfigPath
    $disabledOU = "OU=Disabled Users,OU=$($cfg.RootOU),$($cfg.DomainDN)"
}

process {
    $user   = Get-ADUser -Identity $SamAccountName -Properties MemberOf, info
    $groups = @($user.MemberOf | ForEach-Object { (Get-ADGroup $_).Name })
    $stamp  = Get-Date -Format 'yyyy-MM-dd'

    if ($PSCmdlet.ShouldProcess($SamAccountName, "Disable and remove from $($groups.Count) group(s)")) {
        $note = "Disabled $stamp by $env:USERNAME. Former groups: $($groups -join ', ')"
        $info = if ($user.info) { "$($user.info)`r`n$note" } else { $note }
        Set-ADUser -Identity $user -Replace @{ info = $info } -Description "Disabled $stamp"
        Disable-ADAccount -Identity $user

        foreach ($dn in $user.MemberOf) {
            Remove-ADGroupMember -Identity $dn -Members $user -Confirm:$false
        }

        Move-ADObject -Identity $user.DistinguishedName -TargetPath $disabledOU
        Write-Host "Disabled $SamAccountName; removed from: $($groups -join ', ')"
    }
}
