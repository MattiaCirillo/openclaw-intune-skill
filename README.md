# 🔧 OpenClaw Intune Skill – Complete Microsoft Intune Management

> **Author:** Mattia Cirillo
> **License:** MIT
> **Platform:** [OpenClaw](https://github.com/openclaw/openclaw)

A comprehensive OpenClaw skill that gives your AI agent **full control over Microsoft Intune** via the Microsoft Graph API.

## 🚀 What Can It Do? (22 Categories, 110+ Endpoints)

| # | Category | Capabilities |
|---|---|---|
| 1 | 📱 **Device Management** | List, search, sync, reboot, lock, wipe, retire, rename, locate devices |
| 2 | 📋 **Compliance Policies** | List/create/delete compliance policies, check device status |
| 3 | ⚙️ **Configuration Profiles** | Config profiles, Settings Catalog, assignments |
| 4 | 📦 **App Management** | List apps, assignments, detected apps, app configs |
| 5 | 🔒 **Endpoint Security** | Baselines, BitLocker, Firewall, Defender, ASR rules |
| 6 | 🚀 **Windows Autopilot** | Devices, profiles, assign users, delete |
| 7 | 📜 **PowerShell Scripts** | Upload, manage, execution status, proactive remediations |
| 8 | 👥 **Users & Groups** | Search users, manage group memberships, list devices per user |
| 9 | 📊 **Reporting** | Compliance summary, OS distribution, stale devices, exports |
| 10 | 🏷️ **Device Categories** | Categories, enrollment restrictions |
| 11 | 🔄 **RBAC** | Roles and role assignments |
| 12 | 🛡️ **Conditional Access** | Policies, named locations, authentication strengths |
| 13 | 📶 **WLAN, VPN & Certificates** | Wi-Fi profiles, VPN, SCEP, PKCS, trusted root certs |
| 14 | 🔄 **Windows Updates** | Update rings, feature/quality/driver updates, pause/resume |
| 15 | 🍎 **Apple Management** | DEP/ADE, APNS certificate, VPP tokens, activation lock bypass |
| 16 | 🤖 **Android Enterprise** | Managed Store, enrollment profiles, binding status |
| 17 | 📝 **Audit Logs** | Intune audit events, directory audits, sign-in logs |
| 18 | 🏗️ **Settings Catalog & GPO** | Search settings, GPO migration reports, definition files |
| 19 | 📄 **Terms & Notifications** | Terms & conditions, notification templates, test messages |
| 20 | 🔐 **App Protection (MAM)** | iOS/Android/Windows protection policies, per-user status |
| 21 | 📱 **Enrollment Config** | Platform restrictions, ESP, Windows Hello for Business |
| 22 | 🧮 **Filters & Scope Tags** | Assignment filters, scope tags, filter preview |

## 📦 Installation

```bash
# Copy into your OpenClaw workspace
mkdir -p ~/.openclaw/workspace/skills/intune-graph
cp SKILL.md ~/.openclaw/workspace/skills/intune-graph/
```

## 🔑 Setup

1. Create an **App Registration** in Microsoft Entra ID (Azure AD)
2. Grant the required Microsoft Graph API permissions (see SKILL.md)
3. Set environment variables:
```bash
export INTUNE_TENANT_ID="your-tenant-id"
export INTUNE_CLIENT_ID="your-client-id"
export INTUNE_CLIENT_SECRET="your-client-secret"
```

## 💬 Example Usage

> **You:** "Zeig mir alle Geräte die nicht compliant sind"
> **Agent:** "5 Geräte nicht compliant. 3 Windows (fehlende Updates), 2 iOS (kein Passcode). Soll ich die syncen?"

> **You:** "Sync den Laptop von Max Müller"
> **Agent:** "Done ✅ Sync-Befehl an MAX-LAPTOP gesendet."

> **You:** "Wie viele Geräte haben wir insgesamt?"
> **Agent:** "127 Geräte: 89 Windows, 22 iOS, 12 Android, 4 macOS."

## 🛡️ Safety

- Read operations execute without confirmation
- Sync/Reboot requires simple confirmation
- **Wipe/Retire/Delete** always requires explicit double confirmation
- The agent never dumps raw JSON – always formatted Markdown

## 🔗 Links

- 🦞 [OpenClaw](https://github.com/openclaw/openclaw)
- 📖 [Microsoft Graph API Docs](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)

---
Made with ☕ by Mattia Cirillo
