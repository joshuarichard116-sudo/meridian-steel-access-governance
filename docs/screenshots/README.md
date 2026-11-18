# Evidence screenshots

Screenshots turn "I configured X" into "here is X working." Save them in this folder with the names below and they can be linked from the main README.

> **Before uploading:** blur tenant IDs, tenant/domain names you don't want public, real email addresses and IP addresses.

| File name | What to capture |
|---|---|
| `01-ou-structure.png` | ADUC showing the Meridian OU tree |
| `02-security-groups.png` | Groups OU with all `SG-*` groups |
| `03-ntfs-finance.png` | Finance folder → Advanced Security showing Staff = Modify, Managers = Full Control, inheritance disabled |
| `04-abe-view.png` | `\\DC\MeridianShares` as a staff user, with only their department visible |
| `05-access-denied.png` | Access denied when opening another department's folder |
| `06-second-disk.png` | Disk Management showing the second virtual disk |
| `07-entra-connect.png` | Entra Connect Sync status / synced users in Entra |
| `08-ca-mfa-all-users.png` | CA policy: assignments and grant controls, with the break-glass exclusion |
| `09-ca-report-only.png` | Sign-in log → Report-only tab showing the policy result |
| `10-ca-managers.png` | Manager policy: MFA + hybrid joined device |
| `11-pim-eligible.png` | PIM showing Global Admin as **Eligible** |
| `12-pim-activation.png` | Activating the role with justification |
| `13-access-report.png` | Output of `06-Get-MeridianAccessReport.ps1` |

Embed in a README with:

```markdown
![Finance NTFS permissions](docs/screenshots/03-ntfs-finance.png)
```
