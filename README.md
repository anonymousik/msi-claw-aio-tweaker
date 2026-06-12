<div align="center">

<a href="https://github.com/anonymousik/msi-claw-aio-tweaker">
  <img src="https://github.com/user-attachments/assets/aab7c14f-4efb-48ba-aebe-1bd32c1490ba" alt="SecFERRO Division - MSI Claw Optimizer Banner" width="100%">
</a>

<br><br>

# MSI Claw Optimizer (v5.0.0)

[![English Version](https://img.shields.io/badge/Read_in-English-blue?style=flat-square)](README_EN.md)
[![Wersja](https://img.shields.io/badge/wersja-5.0.0-blue.svg?style=flat-square)](https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-green.svg?style=flat-square)](https://docs.microsoft.com/pl-pl/powershell/)
[![Platforma](https://img.shields.io/badge/platforma-Windows%2011-lightgrey.svg?style=flat-square)]()
[![Bezpieczeństwo](https://img.shields.io/badge/bezpieczeństwo-SHA256_Zweryfikowane-success.svg?style=flat-square)]()

**Zaawansowany framework do kompleksowej optymalizacji MSI Claw Handheld Gaming PC**

[📥 Pobierz najnowszą wersję](https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest) •
[📖 Dokumentacja](docs/INSTALLATION.md) •
[🐛 Zgłoś błąd](https://github.com/anonymousik/msi-claw-aio-tweaker/issues) •
[📱 Live Monitor (Demo)](https://anonymousik.is-a.dev/msi-claw-aio-tweaker/mobile_demo)

---

</div>

> [!WARNING]  
> **Zastrzeżenie (Disclaimer):** Oprogramowanie bezpośrednio ingeruje w klucze Rejestru Windows, usługi systemowe oraz plany zasilania. Dostarczane jest w formie "AS IS" bez jakiejkolwiek gwarancji. Użytkujesz je na własne ryzyko. Narzędzie nie jest oficjalnym produktem firm MSI ani Intel i teoretycznie może mieć wpływ na warunki gwarancji.

## Czym jest MSI Claw Optimizer?

To kompleksowy framework optymalizacyjny typu All-In-One, napisany w środowisku PowerShell, dedykowany urządzeniom z serii MSI Claw. Jego głównym celem jest redukcja narzutu systemowego (overhead), poprawa czasu pracy na baterii oraz stabilizacja frametime'ów w grach poprzez głęboką modyfikację i debloat środowiska Windows 11.

## 🚀 Szybki Start

> [!IMPORTANT]  
> Do poprawnego działania skryptu bezwzględnie wymagane są uprawnienia Administratora.

### Instalacja automatyczna (Rekomendowana)

Otwórz terminal **PowerShell jako Administrator** i wykonaj poniższe polecenie:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Invoke-RestMethod -Uri "[https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1](https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1)" | Invoke-Expression

```
### Instalacja w trybie Offline (Ręczna)
```powershell
# 1. Pobierz archiwum ZIP
Invoke-WebRequest -Uri "[https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest/download/MSI_Claw_Optimizer_v5.0.zip](https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest/download/MSI_Claw_Optimizer_v5.0.zip)" -OutFile "MSI_Claw_v5.zip"

# 2. Rozpakuj zawartość
Expand-Archive -Path "MSI_Claw_v5.zip" -DestinationPath "C:\MSI_Claw_Optimizer"

# 3. Uruchom skrypt główny
cd C:\MSI_Claw_Optimizer
.\MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1

```
## ⚙️ Co dokładnie modyfikuje skrypt?
### Optymalizacja Rejestru Windows
```diff
- Memory Integrity (HVCI): ENABLED
+ Memory Integrity (HVCI): DISABLED
# Zmniejsza narzut na procesor centralny, poprawiając wydajność w grach.

- Game DVR: ENABLED
+ Game DVR: DISABLED
# Blokuje procesy nagrywania w tle i wyłącza preinstalowaną telemetrię.

- Hardware GPU Scheduling: DISABLED
+ Hardware GPU Scheduling: ENABLED
# Zmniejsza opóźnienia w komunikacji CPU - Intel Arc GPU.

```
## 🤝 Społeczność i Podziękowania
Jeśli to narzędzie ustabilizowało Twoje FPS-y lub przedłużyło życie baterii – rozważ zostawienie gwiazdki (⭐) dla tego repozytorium!
<div align="center">


<i>Copyright © 2026 Nieznany Nikomu Anonymousik. Udostępniono w celach edukacyjnych (MIT License).</i>
</div>

```
