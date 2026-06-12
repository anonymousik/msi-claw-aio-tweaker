<div align="center">

<a href="https://github.com/anonymousik/msi-claw-aio-tweaker">
  <img src="https://github.com/user-attachments/assets/aab7c14f-4efb-48ba-aebe-1bd32c1490ba" alt="SecFERRO Division - MSI Claw Optimizer Banner" width="100%">
</a>

<br><br>

# MSI Claw Optimizer (v5.0.0)

[![Polish Version](https://img.shields.io/badge/Read_in-Polish-red?style=flat-square)](README.md)
[![Version](https://img.shields.io/badge/version-5.0.0-blue.svg?style=flat-square)](https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-green.svg?style=flat-square)](https://docs.microsoft.com/en-us/powershell/)
[![Platform](https://img.shields.io/badge/platform-Windows%2011-lightgrey.svg?style=flat-square)]()
[![Security](https://img.shields.io/badge/security-SHA256_Verified-success.svg?style=flat-square)]()

**Advanced framework for comprehensive optimization of the MSI Claw Handheld Gaming PC**

[📥 LATEST RELEASE](https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest) •[📖DOCS](docs/INSTALLATION.md)        •[👨‍💻BUG-REPORT](https://github.com/anonymousik/msi-claw-aio-tweaker/issues) 
•[📱 LIVE-MONIT (Demo)](https://anonymousik.is-a.dev/msi-claw-aio-tweaker/mobile_demo)

---
</div>

> [!WARNING]  
> **Disclaimer:** This software modifies Windows Registry keys, system services, and power plans. It is provided "AS IS" without warranty of any kind. Use at your own risk. This tool is not an official product of MSI or Intel and may theoretically affect warranty conditions.

## What is MSI Claw Optimizer?

An All-In-One optimization framework written in PowerShell, specifically designed for the MSI Claw series. Its primary goal is to reduce system overhead, improve battery life, and stabilize game frametimes through deep Windows 11 environment modifications.

## 🚀 Quick Start

> [!IMPORTANT]  
> Administrator privileges are required for the script to execute successfully.

### Automatic Installation (Recommended)

Open **PowerShell as Administrator** and execute the following command:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Invoke-RestMethod -Uri "[https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1](https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1)" | Invoke-Expression

```
### Offline Installation (Manual)
```powershell
# 1. Download the ZIP archive
Invoke-WebRequest -Uri "[https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest/download/MSI_Claw_Optimizer_v5.0.zip](https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest/download/MSI_Claw_Optimizer_v5.0.zip)" -OutFile "MSI_Claw_v5.zip"

# 2. Extract contents
Expand-Archive -Path "MSI_Claw_v5.zip" -DestinationPath "C:\MSI_Claw_Optimizer"

# 3. Execute the bootstrap script
cd C:\MSI_Claw_Optimizer
.\MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1

```
## ⚙️ Key Modifications (Under the Hood)
### Windows Registry Optimization
```diff
- Memory Integrity (HVCI): ENABLED
+ Memory Integrity (HVCI): DISABLED
# Reduces CPU overhead, improving gaming performance.

- Game DVR: ENABLED
+ Game DVR: DISABLED
# Blocks background recording and disables Xbox telemetry.

- Hardware GPU Scheduling: DISABLED
+ Hardware GPU Scheduling: ENABLED
# Decreases communication latency between CPU and Intel Arc GPU.

```
### Power State Management
```diff
- Default Power Button Action: SLEEP
+ Default Power Button Action: HIBERNATE
# Resolves the "hot backpack" issue - device consumes 0% power when idle.

```
## 🤝 Community and Credits
If this tool has stabilized your framerates or extended your battery life, please consider leaving a star (⭐) for this repository!
<div align="center">


<i>Copyright © 2026 Nieznany Nikomu Anonymousik. Released for educational purposes under the MIT License.</i>
</div>