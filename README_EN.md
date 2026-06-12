<div align="center">
# MSI Claw Optimizer (v5.0.0)
Polish Version

Version

PowerShell

**Advanced framework for comprehensive optimization of the MSI Claw Handheld Gaming PC**
📥 Download Latest Release •
📖 Documentation •
🐛 Report a Bug •
📱 Live Monitor (Demo)
</div>
> [!WARNING]
> **Disclaimer:** This software modifies Windows Registry keys, system services, and power plans. It is provided "AS IS" without warranty of any kind. Use at your own risk. This tool is not an official product of MSI or Intel and may theoretically affect warranty conditions.
> 
## What is MSI Claw Optimizer?
An All-In-One optimization framework written in PowerShell, specifically designed for the MSI Claw series. Its primary goal is to reduce system overhead, improve battery life, and stabilize game frametimes through deep Windows 11 environment modifications.
### 📊 Community Benchmarks (Data from r/MSIClaw)
| Parameter / Game | Before Optimization | After Optimization (v5.0) | Improvement |
|---|---|---|---|
| **Battery Drain (Sleep)** | -10% to -20% | **0%** (Hibernate) | Stable environment |
| **Temperatures (Load)** | 85°C - 95°C | **65°C - 75°C** | **-15°C** |
| **Cyberpunk 2077** (Low) | ~35 FPS, 45 min battery | ~45 FPS, 90 min battery | **+28% FPS** / +100% Battery |
| **EA FC 25** (Medium) | 40 min battery | 90 - 120 min battery | **+150% Battery** |
| **Game Stuttering** | Noticeable | Eliminated | Smooth gameplay |
## 🚀 Quick Start
> [!IMPORTANT]
> Administrator privileges are required for the script to execute successfully.
> 
### Automatic Installation (Recommended)
Open **PowerShell as Administrator** and execute the following command:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Invoke-RestMethod -Uri "[https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1](https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1)" | Invoke-Expression

```
The script will automatically:
 1. Fetch the latest stable release from the repository.
 2. Verify the SHA-256 checksum of the package.
 3. Launch the diagnostic module and propose optimizations.
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
For detailed troubleshooting instructions, refer to INSTALLATION.md.
## 🛠️ What's New in v5.0
### Security & Architecture
 * **Enterprise-grade Security:** Complete elimination of Invoke-Expression in core logic (preventing command injection), rigorous input sanitization, and digital signature verification. All network connections are restricted to HTTPS.
 * **Auto-Diagnostics & Self-Healing:** The tool automatically detects hardware revisions (A1M / 8 AI+ Lunar Lake), audits the Windows 11 environment (HVCI, VBS), and verifies driver compliance (Intel Arc 32.0.101.6877+ and BIOS 109+).
 * **Modular Architecture:** Implements Separation of Concerns (SoC) by dividing logic into diagnostic, optimization, utility, and backup modules. I/O operations are now executed asynchronously.
## ⚙️ Under the Hood (What is actually modified?)
This tool operates with full transparency. Below are the key environment modifications:
### Windows Registry Optimization
```diff
- Memory Integrity (HVCI): ENABLED
+ Memory Integrity (HVCI): DISABLED
# Reduces CPU overhead, improving gaming performance by 15-25%.

- Virtual Machine Platform: ENABLED
+ Virtual Machine Platform: DISABLED
# Limits hardware virtualization overhead.

- Game DVR: ENABLED
+ Game DVR: DISABLED
# Blocks background recording processes and Xbox telemetry.

- Hardware GPU Scheduling: DISABLED
+ Hardware GPU Scheduling: ENABLED
# Decreases communication latency between the CPU and Intel Arc GPU.

```
### Power State Management
```diff
- Default Power Button Action: SLEEP (S0ix)
+ Default Power Button Action: HIBERNATE
# Resolves the "hot backpack" issue - the device consumes 0% battery when turned off.

- Wake Timers: ENABLED
+ Wake Timers: DISABLED
# Prevents the device from waking up automatically due to background system tasks.

```
## 💻 Supported Configurations & CLI Arguments
**Fully Supported Devices:**
 * MSI Claw A1M (Core Ultra 5 135H / Ultra 7 155H + Intel Arc)
 * MSI Claw 8 AI+ (Intel Lunar Lake + Intel Arc)
*Note: MSI-specific modules will not function on devices equipped with AMD/NVIDIA APUs (e.g., ROG Ally, Legion Go).*
### Command-Line Arguments
| Argument | Description | Use Case |
|---|---|---|
| *(none)* | **Interactive Mode.** GUI menu with user prompts for changes. | Standard User |
| -Mode Automatic | **Unattended Mode.** Applies safe baseline settings silently. | Advanced Automation |
| -Mode DiagnosticOnly | **Read-Only Mode.** Audits the environment without applying changes. | Diagnostics / Audit |
| -Mode UpdateOnly | Checks and installs framework updates. | Tool Maintenance |
## 📋 Roadmap and Known Issues
### Future Releases Roadmap
 * [ ] **v5.1:** Native Graphical User Interface (Windows Forms / WPF).
 * [ ] **v5.5:** Cloud integration for backup synchronization (OneDrive).
 * [ ] **v6.0:** Algorithmic, game-specific settings optimization.
### Defect Tracking (Known Issues)
 * [KNOWN] RGB lighting resets after resuming from hibernation (requires manual restore in MSI Center M).
 * [KNOWN] In rare cases (~10%), controllers remain unresponsive after hibernation. (Workaround: Press MSI button -> Close and restart MSI Center M).
 * [FIXED] Audio crackling on the Lunar Lake platform has been resolved (requires Intel Arc driver update to v6877+).
## 🛡️ Security, Privacy, and Documentation
Designed in accordance with software engineering best practices:
 * **Zero Telemetry:** The tool operates entirely locally. We do not collect or transmit background data.
 * **Auto-Rollback:** A system restore point is generated before any modifications are applied.
 * Fully Open Source. Trust, but verify (SECURITY.md).
**Project Documentation Files:**
 * ARCHITECTURE.md - Module architecture schema.
 * CHANGELOG.md - Revision history and implemented features.
 * CONTRIBUTING.md - Guidelines for Pull Requests.
## 🤝 Community and Credits
This Open Source project relies on community contributions. Special thanks to the **Reddit r/MSIClaw** community for thousands of hours spent testing and reporting stability issues, and to the engineers at **SecFERRO DIVISION** for their assistance with security architecture revision.
If this tool has extended your battery life, please consider leaving a star (⭐) on this repository!
<div align="center">


<i>Copyright © 2026 Nieznany Nikomu Anonymousik. Released for educational purposes under the MIT License.</i>
</div>
