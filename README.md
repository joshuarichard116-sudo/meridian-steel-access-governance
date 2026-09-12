# meridian-steel-access-governance
Hybrid AD/Entra RBAC and access governance lab project
[README.md](https://github.com/user-attachments/files/32148485/README.md)
# Meridian Steel & Fabrication — Access Governance & RBAC Implementation

A hands-on identity and access management project built in a hybrid Active Directory / Microsoft Entra ID lab, designed around a fictional structural steel fabrication company to model realistic, department-based access governance.

## 📋 Project Overview

**Scenario:** Meridian Steel & Fabrication is a fictional 50-employee structural steel fabrication and construction company, used as the reference profile for every access decision in this project. Real organizations rarely need "generic" AD structure — they need access mapped to how the business is actually organized, so this project treats Meridian Steel as a real client engagement.

**Departments modeled:**
- Executive
- Finance / Accounting
- HR
- Project Management / Estimating
- Engineering / Drafting
- Shop / Fabrication
- Field / Site Supervisors
- IT / Admin
- Sales / Business Development

**Environment:** Single-domain hybrid AD/Entra lab (`lab.local`, synced to Entra tenant via Azure AD Connect).

## 🎯 Goals

- Design a role-based access model that's realistic for a mid-size business, not just a lab exercise
- Enforce least-privilege access at the department and tier level
- Layer in modern identity security controls (Conditional Access, PIM) on top of the on-prem foundation
- Build toward automated provisioning so access follows HR events, not manual tickets

## 🏗️ Access Model Design

**Group structure:** Global security groups applied directly to NTFS permissions (AGDLP's Domain Local layer was deliberately dropped — with a single domain, it added complexity without a real benefit).

**Staff vs. management tiering per department**, e.g.:
- `SG-Finance-Staff` → Read + Modify
- `SG-Finance-Managers` → Full Control

This mirrors how access actually needs to differ within a department, not just between departments.

**Where groups/OUs live:** Created on-prem in AD (not cloud-side), since the file server/DC permission chain is on-prem and cloud-created groups don't sync downward.

## 📁 File Share Infrastructure

Department shares are hosted as on-prem shared folders directly on the Domain Controller (not SharePoint, not a dedicated file server) — built from scratch to fully control and demonstrate the permissioning model:

- Added a second virtual disk to the DC VM (KVM/virt-manager)
- Formatted and mounted as a dedicated drive
- Hosts the `MeridianShares` folder structure, with NTFS permissions tied to the department/tier group structure above

## 🔐 Identity Security Layer

Extended beyond baseline AD/file permissions into modern conditional access and privileged access management:

**Conditional Access:**
- *Require MFA for All Users* — break-glass admin account excluded; validated in Report-only mode against sign-in logs before enforcing
- *Manager-tier policy* — MFA + Hybrid Azure AD join required, scoped to `SG-AllManagers`

**Privileged Identity Management (PIM):**
- Sync/admin account converted from permanent to **Eligible-only** for Global Administrator
- Break-glass and personal admin accounts retained as permanent **Active** assignments (by design, for recovery scenarios)

## 🚀 In Progress / Planned

- **HR-driven onboarding automation** — using Paylocity as the trigger to create AD users, sync to Entra, and auto-assign to the correct groups
- **Automated SaaS provisioning** based on group membership (GoTo, Foxit Admin Console) — validated the Entra-side SAML/SCIM configuration; full end-to-end testing is currently blocked by paid-tier licensing gates on the SaaS side rather than any issue with the Entra configuration itself

## 💡 Why This Project

This was built to demonstrate real-world access governance thinking — not just "how do I create a security group," but how access should be structured, tiered, and automated for an actual organization. It's also directly informed by gaps observed in real onboarding workflows at my day-to-day work, which is what motivated the automated provisioning direction.

## 🛠️ Tech / Tools Used

Active Directory · Microsoft Entra ID · Azure AD Connect · Conditional Access · Privileged Identity Management (PIM) · KVM/virt-manager · NTFS permissions

---
📫 [LinkedIn](your-linkedin-url-here)
