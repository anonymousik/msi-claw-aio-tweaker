# MSI CLAW OPTIMIZER v5.0 🚀 

[![English Version](https://img.shields.io/badge/Read_in-English-blue?style=flat-square)](README_EN.md)

<div align="center">
<a href="https://github.com/anonymousik/msi-claw-aio-tweaker">
<img src="https://github.com/user-attachments/assets/aab7c14f-4efb-48ba-aebe-1bd32c1490ba" alt="SecFERRO Division - MSI Claw Optimizer Banner" width="100%">
</a>
# MSI Claw Optimizer (v5.0.0)
English Version

Wersja

PowerShell

**Zaawansowany framework do kompleksowej optymalizacji MSI Claw Handheld Gaming PC**
📥 Pobierz najnowszą wersję •
📖 Dokumentacja •
🐛 Zgłoś błąd •
📱 Live Monitor (Demo)
</div>
> [!WARNING]
> **Zastrzeżenie (Disclaimer):** Oprogramowanie bezpośrednio ingeruje w klucze Rejestru Windows, usługi systemowe oraz plany zasilania. Dostarczane jest w formie "AS IS" bez jakiejkolwiek gwarancji. Użytkujesz je na własne ryzyko. Narzędzie nie jest oficjalnym produktem firm MSI ani Intel i teoretycznie może mieć wpływ na warunki gwarancji.
> 
## Czym jest MSI Claw Optimizer?
To kompleksowy framework optymalizacyjny typu All-In-One, napisany w środowisku PowerShell, dedykowany urządzeniom z serii MSI Claw. Jego głównym celem jest redukcja narzutu systemowego (overhead), poprawa czasu pracy na baterii oraz stabilizacja frametime'ów w grach poprzez głęboką modyfikację i debloat środowiska Windows 11.
### 📊 Benchmarki (Dane ze społeczności r/MSIClaw)
| Parametr / Gra | Przed optymalizacją | Po optymalizacji (v5.0) | Zysk |
|---|---|---|---|
| **Drenaż baterii (Sleep)** | -10% do -20% | **0%** (Hibernacja) | Środowisko stabilne |
| **Temperatury (Load)** | 85°C - 95°C | **65°C - 75°C** | **-15°C** |
| **Cyberpunk 2077** (Low) | ~35 FPS, 45 min baterii | ~45 FPS, 90 min baterii | **+28% FPS** / +100% Bateria |
| **EA FC 25** (Medium) | 40 min baterii | 90 - 120 min baterii | **+150% Bateria** |
| **Stuttering w grach** | Zauważalny | Wyeliminowany | Płynna rozgrywka |
## 🚀 Szybki Start
> [!IMPORTANT]
> Do poprawnego działania skryptu bezwzględnie wymagane są uprawnienia Administratora.
> 
### Instalacja automatyczna (Rekomendowana)
Otwórz terminal **PowerShell jako Administrator** i wykonaj poniższe polecenie:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Invoke-RestMethod -Uri "[https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1](https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1)" | Invoke-Expression

```
Skrypt automatycznie:
 1. Pobierze najnowszą stabilną paczkę z repozytorium.
 2. Zweryfikuje sumy kontrolne SHA-256 plików.
 3. Uruchomi moduł diagnostyczny i zaproponuje proces optymalizacji.
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
Szczegółowe instrukcje rozwiązywania problemów znajdziesz w pliku INSTALLATION.md.
## 🛠️ Nowości w wersji 5.0
### Architektura i Bezpieczeństwo
 * **Bezpieczeństwo klasy Enterprise:** Całkowita eliminacja Invoke-Expression w logice wewnętrznej (mitygacja command injection), rygorystyczna sanityzacja danych wejściowych oraz weryfikacja podpisów cyfrowych. Zewnętrzne połączenia sieciowe ograniczone wyłącznie do protokołu HTTPS.
 * **Auto-Diagnostics & Self-Healing:** Narzędzie automatycznie rozpoznaje rewizję sprzętową (A1M / 8 AI+ Lunar Lake), audytuje środowisko Windows 11 (status HVCI, VBS) oraz weryfikuje zgodność sterowników.
 * **Architektura Modularna:** Wdrożono paradygmat Separation of Concerns (SoC) dzieląc logikę na niezależne moduły.
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
### Zarządzanie Zasilaniem (Power States)
```diff
- Stan domyślny przycisku Power: SLEEP
+ Stan domyślny przycisku Power: HIBERNATE
# Rozwiązuje problem "gorącego plecaka" - urządzenie zużywa 0% energii w spoczynku.

```
## 📋 Roadmapa i Znane Problemy
### Defekty
 * [KNOWN] Podświetlenie RGB resetuje się po wyjściu z hibernacji.
 * [FIXED] Trzeszczenie dźwięku na platformie Lunar Lake wyeliminowane.
**Dokumentacja:** ARCHITECTURE.md | CHANGELOG.md | CONTRIBUTING.md
<div align="center">


<i>Copyright © 2026 Nieznany Nikomu Anonymousik. Udostępniono w celach edukacyjnych (MIT License).</i>
</div>
