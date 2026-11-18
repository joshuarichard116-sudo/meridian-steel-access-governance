# Build & lifecycle scripts

PowerShell scripts that rebuild the Meridian access model and run the identity lifecycle. All values (domain, departments, paths) come from [`MeridianConfig.psd1`](MeridianConfig.psd1). Edit it first.

| Order | Script | What it does |
|---|---|---|
| 1 | `01-New-MeridianOUStructure.ps1` | OUs: Users/<Dept>, Groups, Computers, Service/Admin Accounts, Disabled Users |
| 2 | `02-New-MeridianSecurityGroups.ps1` | `SG-<Dept>-Staff` / `-Managers` and `SG-AllManagers` |
| 3 | `03-Set-MeridianSharePermissions.ps1` | Folder tree, NTFS ACLs, SMB share with Access-Based Enumeration |
| 4 | `04-New-MeridianUsersFromCsv.ps1` | **Joiner**: HR CSV → AD user → correct OU and group (optionally starts a delta sync) |
| 5 | `05-Disable-MeridianUser.ps1` | **Leaver**: disable, record and strip groups, move to Disabled Users |
| 6 | `06-Get-MeridianAccessReport.ps1` | Access review: group membership and folder ACLs to CSV, flags anything off-model |

## How to run

On the domain controller (or a machine with RSAT), in an elevated PowerShell session:

```powershell
cd .\scripts
.\01-New-MeridianOUStructure.ps1 -WhatIf     # preview
.\01-New-MeridianOUStructure.ps1 -Verbose    # apply
```

- Every script supports **`-WhatIf`**. Always preview first.
- Scripts 1–3 are **idempotent**. Re-running them won't create duplicates.
- Script 3 also requires `-RunAsAdministrator`, since it changes NTFS and SMB.
- The `reports/` folder created by script 6 contains real user data. It's git-ignored, so don't commit it.

> These scripts reproduce the lab design as code. Test them in the lab with `-WhatIf` before relying on them.
