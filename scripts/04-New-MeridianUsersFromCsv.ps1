<#
.SYNOPSIS
    JOINER: creates AD users from an HR export and places them in the right
    OU and department/tier group. Entra Connect then syncs them to the cloud,
    where Conditional Access and group-based app assignment apply automatically.

.DESCRIPTION
    Expected CSV columns (see ..\data\sample-hr-export.csv):
        EmployeeId, FirstName, LastName, Department, Title, IsManager, ManagerEmployeeId
    Department must match a Code in MeridianConfig.psd1 (e.g. Finance).

    Each user gets a random temporary password and must change it at first
    logon. Passwords are returned in the output objects only - nothing is
    written to disk. Hand them over through a secure channel (or issue an
    Entra Temporary Access Pass for MFA registration instead).

.EXAMPLE
    .\04-New-MeridianUsersFromCsv.ps1 -CsvPath ..\data\sample-hr-export.csv -WhatIf
.EXAMPLE
    .\04-New-MeridianUsersFromCsv.ps1 -CsvPath .\newhires.csv -StartSync
#>
#Requires -Modules ActiveDirectory
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$CsvPath,
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'MeridianConfig.psd1'),
    # Trigger an Entra Connect delta sync afterwards (run on the server hosting Entra Connect)
    [switch]$StartSync
)

$cfg    = Import-PowerShellDataFile -Path $ConfigPath
$rootDN = "OU=$($cfg.RootOU),$($cfg.DomainDN)"
$codes  = $cfg.Departments.Code

function New-TempPassword {
    param([int]$Length = 16)
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%*?-'.ToCharArray()
    $rng   = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    do {
        $bytes = [byte[]]::new($Length)
        $rng.GetBytes($bytes)
        $pw = -join ($bytes | ForEach-Object { $chars[$_ % $chars.Length] })
    } until ($pw -cmatch '[A-Z]' -and $pw -cmatch '[a-z]' -and $pw -match '\d' -and $pw -match '[^A-Za-z0-9]')
    $pw
}

function Get-UniqueSam {
    param([string]$First, [string]$Last)
    $base = ($First.Substring(0,1) + $Last) -replace '[^A-Za-z0-9]', ''
    $base = $base.ToLower()
    if ($base.Length -gt 18) { $base = $base.Substring(0,18) }
    $sam = $base; $n = 1
    while (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) {
        $n++; $sam = "$base$n"
    }
    $sam
}

$rows = Import-Csv -Path $CsvPath
foreach ($row in $rows) {
    if ($row.Department -notin $codes) {
        Write-Warning "Skipping $($row.EmployeeId): unknown department '$($row.Department)'"
        continue
    }
    if (Get-ADUser -Filter "EmployeeID -eq '$($row.EmployeeId)'" -ErrorAction SilentlyContinue) {
        Write-Warning "Skipping $($row.EmployeeId): an account with this EmployeeID already exists"
        continue
    }

    $isManager = $row.IsManager -match '^(true|yes|1|y)$'
    $tier      = if ($isManager) { 'Managers' } else { 'Staff' }
    $group     = "SG-$($row.Department)-$tier"
    $ou        = "OU=$($row.Department),OU=Users,$rootDN"
    $sam       = Get-UniqueSam -First $row.FirstName -Last $row.LastName
    $upn       = "$sam@$($cfg.UpnSuffix)"
    $display   = "$($row.FirstName) $($row.LastName)"

    $manager = $null
    if ($row.ManagerEmployeeId) {
        $manager = Get-ADUser -Filter "EmployeeID -eq '$($row.ManagerEmployeeId)'" -ErrorAction SilentlyContinue
    }

    if ($PSCmdlet.ShouldProcess("$display ($upn) -> $ou, $group", 'Create user')) {
        $pw = New-TempPassword
        $params = @{
            Name                  = $display
            GivenName             = $row.FirstName
            Surname               = $row.LastName
            DisplayName           = $display
            SamAccountName        = $sam
            UserPrincipalName     = $upn
            EmployeeID            = $row.EmployeeId
            Title                 = $row.Title
            Department            = $row.Department
            Company               = 'Meridian Steel & Fabrication'
            Path                  = $ou
            AccountPassword       = (ConvertTo-SecureString $pw -AsPlainText -Force)
            ChangePasswordAtLogon = $true
            Enabled               = $true
        }
        if ($manager) { $params.Manager = $manager.DistinguishedName }

        New-ADUser @params
        Add-ADGroupMember -Identity $group -Members $sam

        [pscustomobject]@{
            EmployeeId      = $row.EmployeeId
            SamAccountName  = $sam
            UPN             = $upn
            Group           = $group
            TempPassword    = $pw
        }
    }
}

if ($StartSync -and $PSCmdlet.ShouldProcess('Entra Connect', 'Start delta sync')) {
    Import-Module ADSync
    Start-ADSyncSyncCycle -PolicyType Delta | Out-Null
    Write-Host 'Delta sync started.'
}
