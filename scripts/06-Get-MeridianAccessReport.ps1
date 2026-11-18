<#
.SYNOPSIS
    Access review evidence: exports (1) effective membership of every SG-*
    group and (2) the NTFS ACL of every department folder to CSV.
.EXAMPLE
    .\06-Get-MeridianAccessReport.ps1 -OutputFolder C:\Reports
#>
#Requires -Modules ActiveDirectory
[CmdletBinding()]
param(
    [string]$ConfigPath   = (Join-Path $PSScriptRoot 'MeridianConfig.psd1'),
    [string]$OutputFolder = (Join-Path $PSScriptRoot 'reports')
)

$cfg   = Import-PowerShellDataFile -Path $ConfigPath
$stamp = Get-Date -Format 'yyyyMMdd-HHmm'
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

# 1. Group membership (recursive, so nested groups resolve to users)
$membership = foreach ($g in Get-ADGroup -Filter "Name -like 'SG-*'" | Sort-Object Name) {
    $members = Get-ADGroupMember -Identity $g -Recursive | Where-Object objectClass -eq 'user'
    if (-not $members) {
        [pscustomobject]@{ Group = $g.Name; User = '(empty)'; SamAccountName = ''; Enabled = '' }
    }
    foreach ($m in $members) {
        $u = Get-ADUser $m -Properties Enabled
        [pscustomobject]@{ Group = $g.Name; User = $u.Name; SamAccountName = $u.SamAccountName; Enabled = $u.Enabled }
    }
}
$membershipFile = Join-Path $OutputFolder "GroupMembership-$stamp.csv"
$membership | Export-Csv -Path $membershipFile -NoTypeInformation

# 2. NTFS permissions on root + department folders
$folders = @($cfg.ShareRoot) + ($cfg.Departments | ForEach-Object { Join-Path $cfg.ShareRoot $_.Code })
$acl = foreach ($f in $folders) {
    if (-not (Test-Path $f)) { continue }
    foreach ($ace in (Get-Acl -Path $f).Access) {
        [pscustomobject]@{
            Folder      = $f
            Identity    = $ace.IdentityReference
            Rights      = $ace.FileSystemRights
            Type        = $ace.AccessControlType
            Inherited   = $ace.IsInherited
            Inheritance = $ace.InheritanceFlags
        }
    }
}
$aclFile = Join-Path $OutputFolder "FolderPermissions-$stamp.csv"
$acl | Export-Csv -Path $aclFile -NoTypeInformation

# Flag anything that breaks the model: users granted directly, or inherited ACEs on dept folders
$findings = $acl | Where-Object {
    ($_.Folder -ne $cfg.ShareRoot -and $_.Inherited) -or
    ($_.Identity -notmatch 'SG-|SYSTEM|Administrators|Authenticated Users|CREATOR OWNER')
}
if ($findings) {
    Write-Warning "$(@($findings).Count) ACE(s) don't follow the group-based model:"
    $findings | Format-Table Folder, Identity, Rights, Inherited -AutoSize
}

Write-Host "Reports written:`n  $membershipFile`n  $aclFile"
