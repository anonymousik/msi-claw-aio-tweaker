## 📋 STRUKTURA PLIKÓW PROJEKTU

```
MSI-Claw-Optimizer/
│
├── MSI_Claw_Optimizer_v4_FINAL_CONSOLIDATED.ps1  ← Główny skrypt (finalny)
│
├── MSI_Claw_Optimizer_v4_PROFESSIONAL_EDITION.ps1  ← Część 1 (framework)
├── MSI_Claw_Optimizer_v4_PART2.ps1                 ← Część 2 (optymalizacje)
├── MSI_Claw_Optimizer_v4_PART3_FINAL.ps1           ← Część 3 (menu i troubleshooting)
│
├── README.md                                       ← Główna dokumentacja
├── INSTALLATION_AND_FIXES.md                       ← Ten dokument
│
└── Backupy i Logi (tworzone automatycznie):
    ├── %USERPROFILE%\MSI_Claw_Backups\
    ├── %USERPROFILE%\MSI_Claw_Logs\
    ├── %USERPROFILE%\MSI_Claw_Reports\
    └── %USERPROFILE%\Documents\MSI_Claw_Profiles\
```

---

## 💾 INSTALACJA I UŻYCIE

### Krok 1: Przygotowanie

```powershell
# 1. Utwórz punkt przywracania systemu Windows (ręcznie):
#    - Wyszukaj "Utwórz punkt przywracania" w Windows
#    - Kliknij "Utwórz..."
#    - Nadaj nazwę np. "Przed MSI Claw Optimizer"

# 2. Upewnij się że masz uprawnienia administratora

# 3. Pobierz wszystkie pliki do jednego katalogu
```

### Krok 2: Uruchomienie

```powershell
# Metoda 1: Kliknięcie prawym przyciskiem (zalecane)
# 1. Kliknij prawym na MSI_Claw_Optimizer_v4_FINAL_CONSOLIDATED.ps1
# 2. Wybierz "Uruchom jako administrator"

# Metoda 2: PowerShell
# Otwórz PowerShell jako administrator i wykonaj:
cd C:\Ścieżka\Do\Plików
.\MSI_Claw_Optimizer_v4_FINAL_CONSOLIDATED.ps1

# Metoda 3: Z parametrami
.\MSI_Claw_Optimizer_v4_FINAL_CONSOLIDATED.ps1 -Mode Automatic -LogLevel Debug
```

### Krok 3: Pierwsze uruchomienie

1. **Wybierz opcję 1** - Pełna diagnostyka
2. **Przejrzyj wyniki** - sprawdź czy wszystko jest rozpoznane poprawnie
3. **Wybierz opcję 3** - Eksportuj raport (zapisz dla referencji)
4. **Wybierz opcję 11** - Pełna automatyczna optymalizacja
   - Skrypt utworzy punkt przywracania
   - Utworzy backup konfiguracji
   - Wykona wszystkie optymalizacje
   - Wygeneruje raport

---

## 🔒 BEZPIECZEŃSTWO

### Zabezpieczenia w skrypcie:

| Warstwa | Funkcja | Opis |
|---------|---------|------|
| **1** | System Restore Point | Punkt przywracania Windows przed zmianami |
| **2** | Configuration Backup | Backup rejestru i konfiguracji |
| **3** | Try-Catch-Finally | Obsługa błędów dla każdej operacji |
| **4** | Rollback | Automatyczne cofanie w przypadku błędu |
| **5** | Logging | Szczegółowe logi wszystkich działań |
| **6** | Confirmation | Potwierdzenia przed krytycznymi zmianami |

### Co się stanie w przypadku błędu?

```
1. Błąd zostanie przechwycony (try-catch)
2. Wyświetlone zostanie pytanie: "Czy przywrócić ostatni backup?"
3. Jeśli użytkownik potwierdzi:
   - Przywracany jest backup rejestru
   - System oferuje restart
4. Jeśli użytkownik odrzuci:
   - Zmiany zostają (częściowo zastosowane)
   - Użytkownik może ręcznie użyć System Restore Point
```

---

## ⚠️ ZNANE OGRANICZENIA I OSTRZEŻENIA

### 1. Wymagane uprawnienia administratora
- Skrypt MUSI być uruchomiony jako administrator
- Brak uprawnień = natychmiastowe zakończenie z jasnym komunikatem

### 2. Kompatybilność
- Zoptymalizowane dla MSI Claw (Intel Core Ultra 5/7 + Intel Arc)
- Może działać na innych urządzeniach, ale bez gwarancji
- Windows 11 zalecany, Windows 10 (20H1+) wspierany

### 3. System Restore Point
- Wymaga włączonej "Ochrony Systemu" w Windows
- Jeśli wyłączona, skrypt poprosi o potwierdzenie kontynuacji
- Limit 1 punkt na 24h (skrypt omija to ograniczenie bezpiecznie)

### 4. Restart wymagany
- Wiele optymalizacji wymaga restartu systemu
- Skrypt zapyta użytkownika czy zrestartować teraz czy później
- Bez restartu niektóre zmiany nie będą aktywne

---

## 📞 WSPARCIE I ZGŁASZANIE PROBLEMÓW

### Jeśli coś poszło nie tak:

1. **Sprawdź logi:**
   ```powershell
   # Otwórz w Notatniku najnowszy plik z:
   %USERPROFILE%\MSI_Claw_Logs\
   ```

2. **Przywróć backup:**
   ```powershell
   # Uruchom skrypt i wybierz opcję 8
   # Lub ręcznie przywróć System Restore Point
   ```

3. **Zgłoś problem:**
   - GitHub Issues: https://github.com/SecFERRO/MSI-Claw-Optimizer/issues
   - Dołącz:
     * Wersję skryptu
     * System operacyjny
     * Opis problemu
     * Logi (jeśli możliwe)

---

## 📝 PORÓWNANIE WERSJI

| Funkcja | v3.0 ULTRA (oryginał) | v4.0 Professional | Notatki |
|---------|------------------------|-------------------|---------|
| **Diagnostyka** | Podstawowa | Zaawansowana | +RAM, +Health Check, +Raportowanie |
| **Backupy** | Brak | Automatyczne | Przed każdą zmianą |
| **System Restore** | Problematyczny | Naprawiony | Bezpieczne obejście limitu 24h |
| **Error Handling** | Częściowy | Kompletny | Try-Catch + Trap + Rollback |
| **Logowanie** | Brak | 4-poziomowe | Debug, Info, Warning, Error |
| **Dokumentacja** | Minimalna | Kompletna | Inline + README + Examples |
| **Compliance** | Brak | Full | PSScriptAnalyzer, SDL, PoLP |
| **Kodowanie** | Uszkodzone | UTF-8 | Polskie znaki przywrócone |
| **Parametry** | Brak | Tak | Mode, LogLevel, SkipBackup |
| **Raportowanie** | Brak | HTML/JSON/CSV | Eksport diagnostyki |

---

## 🎯 CHECKLIST PRZED PIERWSZYM UŻYCIEM

- [ ] Utworzyłem punkt przywracania systemu Windows
- [ ] Zamknąłem wszystkie ważne aplikacje
- [ ] Mam uprawnienia administratora
- [ ] Przeczytałem dokumentację OSTRZEŻEŃ
- [ ] Mam backup ważnych danych (opcjonalnie, ale zalecane)
- [ ] Mam co najmniej 30 minut czasu (pełna optymalizacja)
- [ ] Podłączyłem urządzenie do zasilania (zalecane)

---

## 📚 DODATKOWE ZASOBY

### Dokumentacja online:
- MSI Official Support: https://www.msi.com/support
- Intel Arc Drivers: https://www.intel.com/arc-drivers
- PowerShell Docs: https://docs.microsoft.com/powershell

### Community:
- Reddit: r/MSIClaw
- Discord: MSI Claw Community

---

## 📄 LICENCJA I DISCLAIMER

**Copyright © 2026 Nieznany Nikomu Anonymousik / SecFERRO DIVISION**

Educational Use Only

TEN SKRYPT JEST DOSTARCZANY "TAK JAK JEST", BEZ JAKICHKOLWIEK GWARANCJI.
UŻYCIE NA WŁASNE RYZYKO. AUTOR NIE PONOSI ODPOWIEDZIALNOŚCI ZA EWENTUALNE SZKODY.

---

**Made with ❤️ for the MSI Claw Community**

*SecFERRO DIVISION - Gaming Performance Engineering*
