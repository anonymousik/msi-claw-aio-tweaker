# 🚀 SZYBKI START - MSI CLAW OPTIMIZER v5.0

## ⚡ 60-SEKUNDOWA INSTALACJA

### Krok 1: Otwórz PowerShell jako Administrator
```
Naciśnij: Windows + X
Wybierz: "Terminal (Admin)" lub "PowerShell (Admin)"
```

### Krok 2: Wykonaj komendę
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
irm https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/install.ps1 | iex
```

### Krok 3: Gotowe! 🎉

---

## 🎯 CO DALEJ?

Skrypt automatycznie:
1. ✅ Wykryje twój sprzęt (MSI Claw?)
2. ✅ Sprawdzi BIOS, sterowniki, konfigurację
3. ✅ **NAPRAWI** wykryte problemy
4. ✅ Zaproponuje optymalizacje

---

## 📊 CZEGO SIĘ SPODZIEWAĆ?

### PRZED optymalizacją:
```
FIFA 26:         40 minut baterii
Cyberpunk 2077:  45 minut baterii
Stuttering:      TAK
Bateria w Sleep: -10-20%
```

### PO optymalizacji:
```
FIFA 26:         90-120 minut baterii ✅ (+150%)
Cyberpunk 2077:  90-120 minut baterii ✅ (+100%)  
Stuttering:      NIE ✅
Bateria w Sleep: 0% (Hibernate) ✅
```

**UWAGA: RESTART WYMAGANY po optymalizacji!**

---

## 🎮 JAK UŻYWAĆ?

### Automatyczna optymalizacja (ZALECANA):
```powershell
.\MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1 -Mode Automatic
```

### Interaktywna (menu krok-po-kroku):
```powershell
.\MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1
```

### Tylko diagnostyka (bez zmian):
```powershell
.\MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1 -Mode DiagnosticOnly
```

---

## ⚙️ CO ZOSTANIE ZMIENIONE?

### ✅ Wyłączone (bo spowalniają gry):
- Memory Integrity (HVCI) - **+15-25% FPS**
- Virtual Machine Platform - **mniej overhead**
- Game DVR - **brak nagrywania w tle**

### ✅ Włączone (bo poprawiają wydajność):
- Hardware GPU Scheduling - **niższa latencja**
- Hibernation - **brak rozładowania baterii**

### ✅ Zaktualizowane (jeśli outdated):
- Intel Arc Graphics → 32.0.101.6877+
- MSI Center M → 1.0.2405.1401+

---

## 🔐 CZY TO BEZPIECZNE?

### TAK! Framework ma:
- ✅ **SHA256 verification** wszystkich plików
- ✅ **Backup automatyczny** przed zmianami
- ✅ **Rollback** jeśli coś pójdzie nie tak
- ✅ **Brak telemetrii** - zero zbierania danych
- ✅ **Open source** - sprawdź kod sam

---

## 🆘 POMOC

### Problem podczas instalacji?
1. Sprawdź [INSTALLATION.md](INSTALLATION.md) - szczegółowa instrukcja
2. Przejrzyj [GitHub Issues](https://github.com/anonymousik/msi-claw-aio-tweaker/issues)
3. Zapytaj na [Reddit r/MSIClaw](https://reddit.com/r/MSIClaw)

### Gra się crashuje po optymalizacji?
```powershell
# Przywróć backup:
.\MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1
# Wybierz: "Restore from Backup"
```

---

## 💡 WSKAZÓWKI PRO

### Dla najlepszych wyników:
1. ✅ Zaktualizuj BIOS do 109 (z MSI.com)
2. ✅ Zaktualizuj Intel Arc do 32.0.101.6877+ (z Intel.com)
3. ✅ Używaj profilu "Balanced" w MSI Center M
4. ✅ 60Hz dla gier na baterii (120Hz tylko na zasilaczu)
5. ✅ Ogranicz FPS do 60 w grach (battery life++)
6. ✅ **RESTART** po pierwszej optymalizacji!

### Ustawienia per-gra:
- **FIFA/FC**: Balanced, 60Hz, Medium → 90-120 min
- **Cyberpunk**: Balanced, 60Hz, Low → 90 min
- **Fortnite**: Balanced, 60Hz, Medium → 110 min
- **Elden Ring**: Balanced, 60Hz, Medium → 90 min

---

## ⭐ PODOBAŁO SIĘ?

Zostaw gwiazdkę na GitHub!

Podziel się wynikami na r/MSIClaw!

---

**Wersja:** 5.0.0  
**Data:** 2026-02-10  
**Pełna dokumentacja:** [INSTALLATION.md](INSTALLATION.md) | [README.md](README.md)
