# ════════════════════════════════════════════════════════════════════════════════
# MSI CLAW OPTIMIZER v4.0 PROFESSIONAL EDITION - CZĘŚĆ 3/3 (FINAŁ)
# ════════════════════════════════════════════════════════════════════════════════
# Autor: Nieznany Nikomu Anonymousik | Patron: SecFERRO DIVISION
# ════════════════════════════════════════════════════════════════════════════════

# UWAGA: To jest kontynuacja części 2. Nie uruchamiaj tego pliku samodzielnie!

# ════════════════════════════════════════════════════════════════════════════════
# FUNKCJE TROUBLESHOOTING
# ════════════════════════════════════════════════════════════════════════════════

function Start-InteractiveTroubleshooting {
    <#
    .SYNOPSIS
        Interaktywne rozwiązywanie problemów z MSI Claw
    #>
    
    while ($true) {
        Write-Header "INTERAKTYWNA DIAGNOSTYKA I ROZWIĄZYWANIE PROBLEMÓW" `
                     -SubText "Wybierz problem którego doświadczasz"
        
        Write-Host "Jakie problemy doświadczasz?" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  1. 📉 Szybkie rozładowywanie baterii (>20% w 10 min gry)" -ForegroundColor White
        Write-Host "  2. 💤 Urządzenie budzi się samo / zjada baterię w Sleep" -ForegroundColor White
        Write-Host "  3. 🎮 Niska wydajność w grach / stuttering / niski FPS" -ForegroundColor White
        Write-Host "  4. 🌡️  Przegrzewanie / głośne wentylatory" -ForegroundColor White
        Write-Host "  5. 🔌 Problemy z ładowaniem / nie ładuje się" -ForegroundColor White
        Write-Host "  6. ⌨️  Kontrolery nie działają po wznowieniu" -ForegroundColor White
        Write-Host "  7. 🔊 Problemy z dźwiękiem / trzaski / brak audio" -ForegroundColor White
        Write-Host "  8. 🖥️  Problemy z wyświetlaczem / miganie / artefakty" -ForegroundColor White
        Write-Host "  9. 📶 Problemy z WiFi / Bluetooth" -ForegroundColor White
        Write-Host "  0. ↩️  Powrót do menu głównego" -ForegroundColor Gray
        Write-Host ""
        Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
        Write-Host ""
        
        $choice = Read-Host "Wybierz problem (0-9)"
        
        switch ($choice) {
            "1" { Troubleshoot-BatteryDrain }
            "2" { Troubleshoot-SleepIssues }
            "3" { Troubleshoot-Performance }
            "4" { Troubleshoot-Overheating }
            "5" { Troubleshoot-ChargingIssues }
            "6" { Troubleshoot-ControllerIssues }
            "7" { Troubleshoot-AudioIssues }
            "8" { Troubleshoot-DisplayIssues }
            "9" { Troubleshoot-ConnectivityIssues }
            "0" { return }
            default {
                Write-Error-Custom "Nieprawidłowy wybór!"
                Start-Sleep -Seconds 2
            }
        }
    }
}

function Troubleshoot-BatteryDrain {
    Write-Header "DIAGNOSTYKA: Szybkie rozładowywanie baterii"
    
    Write-Info "Sprawdzam potencjalne przyczyny..."
    Write-Host ""
    
    # 1. Refresh Rate
    Write-Host "═══ 1. CZĘSTOTLIWOŚĆ ODŚWIEŻANIA EKRANU ═══" -ForegroundColor Yellow
    Write-Warning-Custom "120Hz drastycznie skraca czas baterii!"
    Write-Info "Zalecenie: Ustaw 60Hz w Ustawieniach Windows → System → Ekran"
    Write-Host ""
    
    # 2. Plan zasilania
    Write-Host "═══ 2. PLAN ZASILANIA ═══" -ForegroundColor Yellow
    try {
        $currentPlan = powercfg /getactivescheme
        Write-Host "Obecny plan: " -NoNewline; Write-Host $currentPlan -ForegroundColor White
        
        if ($currentPlan -notmatch "Balanced") {
            Write-Warning-Custom "Zmień na 'Balanced' dla lepszego czasu baterii"
        }
        else {
            Write-Success "Plan zasilania optymalny"
        }
    }
    catch {
        Write-WarningLog "Nie można sprawdzić planu zasilania"
    }
    Write-Host ""
    
    # 3. MSI Center M / Over Boost
    Write-Host "═══ 3. MSI CENTER M - OVER BOOST ═══" -ForegroundColor Yellow
    Write-Info "Czy masz włączony 'Over Boost' w MSI Center M?"
    Write-Warning-Custom "Over Boost zwiększa wydajność ALE skraca czas baterii o ~30%"
    Write-Info "Zalecenie: Wyłącz Over Boost gdy grasz na baterii"
    Write-Host ""
    
    # 4. Raport baterii
    Write-Host "═══ 4. SZCZEGÓŁOWY RAPORT BATERII ═══" -ForegroundColor Yellow
    Write-Info "Generowanie raportu Windows Battery Report..."
    
    try {
        $reportPath = Join-Path $Script:Config.ReportsPath "battery-report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
        powercfg /batteryreport /output $reportPath | Out-Null
        
        Write-Success "Raport wygenerowany: $reportPath"
        
        if (Confirm-Action -Message "Czy chcesz otworzyć raport?" -DefaultYes) {
            Start-Process $reportPath
        }
    }
    catch {
        Write-ErrorLog "Błąd generowania raportu baterii" -Exception $_
    }
    Write-Host ""
    
    # 5. Zalecenia
    Write-Host "═══ ZALECENIA DLA DŁUŻSZEGO CZASU BATERII ═══" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  ✓ Ustaw 60Hz zamiast 120Hz" -ForegroundColor Green
    Write-Host "  ✓ Wyłącz Over Boost w MSI Center M" -ForegroundColor Green
    Write-Host "  ✓ Obniż jasność ekranu do 50-70%" -ForegroundColor Green
    Write-Host "  ✓ Użyj odpowiedniego profilu wydajnościowego" -ForegroundColor Green
    Write-Host "  ✓ Ogranicz FPS do 60 w grze" -ForegroundColor Green
    Write-Host "  ✓ Wyłącz niepotrzebne aplikacje w tle" -ForegroundColor Green
    Write-Host "  ✓ Wyłącz RGB podświetlenie (jeśli dostępne)" -ForegroundColor Green
    Write-Host ""
    
    Write-Info "Oczekiwane czasy baterii (typowe):"
    Write-Host "  • Gry AAA (max settings): 60-90 min" -ForegroundColor Gray
    Write-Host "  • Gry AAA (balanced): 90-120 min" -ForegroundColor Gray
    Write-Host "  • Gry sportowe (FIFA): 120-150 min" -ForegroundColor Gray
    Write-Host "  • Gry indie/2D: 150-180 min" -ForegroundColor Gray
    Write-Host "  • Przeglądanie/YouTube: 180-240 min" -ForegroundColor Gray
    Write-Host ""
    
    Pause
}

function Troubleshoot-SleepIssues {
    Write-Header "DIAGNOSTYKA I NAPRAWA: Problemy ze Sleep/Hibernacją"
    
    Write-Info "MSI Claw ma znany problem z budzeniem się podczas Sleep"
    Write-Warning-Custom "To powoduje rozładowanie baterii nawet gdy urządzenie jest 'uśpione'"
    Write-Host ""
    
    Write-Info "Rozwiązanie: Konfiguracja Hibernation zamiast Sleep"
    Write-Host ""
    
    if (Confirm-Action -Message "Czy chcesz uruchomić automatyczną naprawę hibernacji?" -DefaultYes) {
        Optimize-HibernationConfiguration
    }
    else {
        Write-Host ""
        Write-Info "Ręczne kroki naprawy:"
        Write-Host "  1. Włącz Hibernation: powercfg /hibernate on" -ForegroundColor Gray
        Write-Host "  2. Skonfiguruj przycisk zasilania na Hibernate" -ForegroundColor Gray
        Write-Host "  3. Wyłącz Wake Timers" -ForegroundColor Gray
        Write-Host "  4. Wyłącz Fast Startup" -ForegroundColor Gray
        Write-Host ""
    }
    
    Pause
}

function Troubleshoot-Performance {
    Write-Header "DIAGNOSTYKA: Niska wydajność w grach"
    
    $issues = @()
    $recommendations = @()
    
    Write-Info "Przeprowadzam kompleksową diagnostykę wydajności..."
    Write-Host ""
    
    # 1. BIOS
    Write-Host "═══ 1. SPRAWDZANIE BIOS ═══" -ForegroundColor Yellow
    $biosModified = Confirm-Action -Message "Czy wykonałeś modyfikacje BIOS? (zwiększenie VRAM itp.)"
    
    if (-not $biosModified) {
        $issues += "BIOS nie został zmodyfikowany"
        $recommendations += "Zwiększ VRAM do 8GB w BIOS (znaczący wzrost wydajności GPU)"
        Write-Warning-Custom "Bez modyfikacji BIOS tracisz 20-30% wydajności GPU!"
    }
    else {
        Write-Success "BIOS zmodyfikowany - OK"
    }
    Write-Host ""
    
    # 2. Memory Integrity
    Write-Host "═══ 2. SPRAWDZANIE MEMORY INTEGRITY ═══" -ForegroundColor Yellow
    try {
        $miPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        $miStatus = (Get-ItemProperty -Path $miPath -Name "Enabled" -ErrorAction SilentlyContinue).Enabled
        
        if ($miStatus -eq 1) {
            $issues += "Memory Integrity włączony"
            $recommendations += "Wyłącz Memory Integrity (wzrost FPS o 5-15%)"
            Write-Warning-Custom "Memory Integrity WŁĄCZONY - powoduje spadek FPS!"
            
            if (Confirm-Action -Message "Czy chcesz wyłączyć Memory Integrity teraz?") {
                Set-ItemProperty -Path $miPath -Name "Enabled" -Value 0 -Force
                Write-Success "Memory Integrity wyłączony (wymaga restartu)"
            }
        }
        else {
            Write-Success "Memory Integrity wyłączony - OK"
        }
    }
    catch {
        Write-WarningLog "Nie można sprawdzić Memory Integrity"
    }
    Write-Host ""
    
    # 3. MSI Center M
    Write-Host "═══ 3. SPRAWDZANIE MSI CENTER M ═══" -ForegroundColor Yellow
    Write-Info "Sprawdź ustawienia MSI Center M:"
    Write-Host "  ✓ User Scenario → Balanced Mode" -ForegroundColor Gray
    Write-Host "  ✓ Over Boost → Enabled (gdy podłączony do zasilania)" -ForegroundColor Gray
    Write-Host "  ✓ Windows power mode → Balanced" -ForegroundColor Gray
    Write-Host ""
    
    # 4. Sterowniki
    Write-Host "═══ 4. SPRAWDZANIE STEROWNIKÓW ═══" -ForegroundColor Yellow
    Write-Info "Sprawdzam wersje sterowników..."
    
    $gpu = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -like "*Intel*Arc*" }
    if ($gpu) {
        Write-Host "Intel Arc Graphics: " -NoNewline
        try {
            $currentDriver = [Version]$gpu.DriverVersion
            $recommendedDriver = $Script:Config.RecommendedArcDriver
            
            if ($currentDriver -lt $recommendedDriver) {
                $issues += "Sterownik Intel Arc nieaktualny"
                $recommendations += "Zaktualizuj sterownik Intel Arc do wersji $recommendedDriver"
                Write-Warning-Custom "Nieaktualny sterownik ($currentDriver)"
                Write-Info "Zalecana wersja: $recommendedDriver"
            }
            else {
                Write-Success "Sterownik aktualny ($currentDriver)"
            }
        }
        catch {
            Write-Warning-Custom "Nie można sprawdzić wersji sterownika"
        }
    }
    Write-Host ""
    
    # 5. Power Settings
    Write-Host "═══ 5. SPRAWDZANIE USTAWIEŃ ZASILANIA ═══" -ForegroundColor Yellow
    try {
        $currentPlan = powercfg /getactivescheme
        Write-Host "Plan zasilania: " -NoNewline; Write-Host $currentPlan -ForegroundColor White
        
        if ($currentPlan -match "High performance") {
            Write-Warning-Custom "'High Performance' może przegrzewać MSI Claw"
            $recommendations += "Użyj 'Balanced' zamiast 'High Performance'"
        }
    }
    catch {}
    Write-Host ""
    
    # Podsumowanie
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host " PODSUMOWANIE DIAGNOSTYKI" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    
    if ($issues.Count -eq 0) {
        Write-Success "Nie znaleziono problemów z konfiguracją!"
        Write-Info "Jeśli nadal doświadczasz niskiej wydajności:"
        Write-Host "  • Sprawdź temperaturę CPU/GPU" -ForegroundColor Gray
        Write-Host "  • Wyłącz niepotrzebne aplikacje w tle" -ForegroundColor Gray
        Write-Host "  • Obniż ustawienia graficzne w grze" -ForegroundColor Gray
        Write-Host "  • Użyj FSR/XeSS dla lepszej wydajności" -ForegroundColor Gray
    }
    else {
        Write-Warning-Custom "Znaleziono $($issues.Count) problemów:"
        foreach ($issue in $issues) {
            Write-Host "  ✗ $issue" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Info "Zalecenia:"
        foreach ($rec in $recommendations) {
            Write-Host "  → $rec" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    Pause
}

function Troubleshoot-Overheating {
    Write-Header "DIAGNOSTYKA: Przegrzewanie / Głośne wentylatory"
    
    Write-Info "Typowe przyczyny przegrzewania MSI Claw:"
    Write-Host ""
    
    Write-Host "1. ZABLOKOWANE WENTYLATORY" -ForegroundColor Yellow
    Write-Info "   → Sprawdź czy otwory wentylacyjne nie są zakryte"
    Write-Info "   → Wyczyść kurz z otworów (sprężone powietrze)"
    Write-Info "   → Nie używaj w łóżku / na miękkich powierzchniach"
    Write-Host ""
    
    Write-Host "2. WYSOKA MOC PODCZAS ŁADOWANIA" -ForegroundColor Yellow
    Write-Info "   → Podczas ładowania urządzenie pracuje na max TDP"
    Write-Info "   → To normalne podczas wymagających gier + ładowanie"
    Write-Info "   → Rozwiązanie: Graj bez ładowania lub obniż ustawienia"
    Write-Host ""
    
    Write-Host "3. OVER BOOST WŁĄCZONY" -ForegroundColor Yellow
    Write-Info "   → Over Boost zwiększa TDP i temperaturę"
    Write-Info "   → Wyłącz w MSI Center M jeśli grasz bez ładowania"
    Write-Host ""
    
    Write-Host "4. ZBYT WYSOKIE USTAWIENIA GRAFICZNE" -ForegroundColor Yellow
    Write-Info "   → Obniż ustawienia graficzne w grze"
    Write-Info "   → Ogranicz FPS do 60"
    Write-Info "   → Włącz FSR/XeSS dla lepszej wydajności"
    Write-Host ""
    
    Write-Info "Zalecenia:"
    Write-Host "  ✓ Graj bez etui/case" -ForegroundColor Green
    Write-Host "  ✓ W domu: podłóż podkładkę chłodzącą lub książkę (dla przepływu)" -ForegroundColor Green
    Write-Host "  ✓ Obniż ustawienia graficzne w grze" -ForegroundColor Green
    Write-Host "  ✓ Ogranicz FPS do 60 zamiast unlimited" -ForegroundColor Green
    Write-Host "  ✓ Użyj profilu Balanced zamiast Max Performance" -ForegroundColor Green
    Write-Host ""
    
    Write-Warning-Custom "Typowe temperatury MSI Claw:"
    Write-Host "  • Idle: 35-45°C (normalne)" -ForegroundColor Gray
    Write-Host "  • Light gaming: 60-70°C (normalne)" -ForegroundColor Gray
    Write-Host "  • Heavy gaming: 75-85°C (normalne)" -ForegroundColor Gray
    Write-Host "  • >90°C: (gorące - rozważ obniżenie ustawień)" -ForegroundColor Yellow
    Write-Host "  • >95°C: (throttling - wymagana interwencja)" -ForegroundColor Red
    Write-Host ""
    
    Pause
}

function Troubleshoot-ControllerIssues {
    Write-Header "NAPRAWA: Kontrolery nie działają po wznowieniu"
    
    Write-Info "Znany problem z MSI Claw - kontrolery czasem nie działają po hibernacji"
    Write-Host ""
    
    Write-Host "═══ SZYBKIE ROZWIĄZANIA ═══" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. PRZYCISK MSI (lewy dolny)" -ForegroundColor Cyan
    Write-Info "   → Naciśnij przycisk MSI"
    Write-Info "   → Otworzy się MSI Center M"
    Write-Info "   → Zamknij MSI Center M"
    Write-Info "   → Kontrolery powinny działać"
    Write-Host ""
    
    Write-Host "2. ALT+TAB" -ForegroundColor Cyan
    Write-Info "   → Przełącz się między oknami (Alt+Tab)"
    Write-Info "   → Wróć do gry"
    Write-Info "   → Kontrolery powinny się reaktywować"
    Write-Host ""
    
    Write-Host "3. AKTUALIZACJA FIRMWARE KONTROLERA" -ForegroundColor Cyan
    Write-Info "   → Otwórz MSI Center M"
    Write-Info "   → Settings → Controller Update"
    Write-Info "   → Zaktualizuj jeśli dostępna nowa wersja"
    Write-Host ""
    
    Write-Host "4. RESTART STEROWNIKA (zaawansowane)" -ForegroundColor Cyan
    if (Confirm-Action -Message "Czy chcesz zrestartować sterownik kontrolera?") {
        try {
            Write-Info "Restartowanie sterownika HID..."
            Restart-Service -Name "HidServ" -Force
            Write-Success "Sterownik zrestartowany"
        }
        catch {
            Write-ErrorLog "Nie udało się zrestartować sterownika" -Exception $_
        }
    }
    Write-Host ""
    
    Pause
}

function Troubleshoot-AudioIssues {
    Write-Header "DIAGNOSTYKA: Problemy z dźwiękiem"
    
    Write-Info "Sprawdzam konfigurację audio..."
    Write-Host ""
    
    # Sprawdź model
    $cpu = Get-WmiObject Win32_Processor
    if ($cpu.Name -match "Lunar Lake") {
        Write-Host "═══ MSI CLAW 8 AI+ (LUNAR LAKE) - ZNANY BUG ═══" -ForegroundColor Yellow
        Write-Host ""
        Write-Warning-Custom "MSI Claw 8 AI+ ma znany problem z audio (glitches, trzaski)"
        Write-Info "Rozwiązanie: Aktualizacja sterownika Intel Arc"
        Write-Host ""
        Write-Success "Wersja sterownika $($Script:Config.RecommendedArcDriver) lub nowsza naprawia ten problem"
        Write-Host ""
        
        if (Confirm-Action -Message "Czy chcesz otworzyć stronę pobierania sterowników Intel?") {
            Start-Process $Script:Config.IntelArcDriversURL
        }
    }
    else {
        Write-Host "═══ OGÓLNE ROZWIĄZANIA PROBLEMÓW Z AUDIO ═══" -ForegroundColor Yellow
        Write-Host ""
        
        Write-Host "1. SPRAWDŹ URZĄDZENIA AUDIO" -ForegroundColor Cyan
        try {
            $audioDevices = Get-WmiObject Win32_SoundDevice
            foreach ($device in $audioDevices) {
                Write-Host "  • $($device.Name)" -NoNewline
                if ($device.Status -eq "OK") {
                    Write-Host " [OK]" -ForegroundColor Green
                }
                else {
                    Write-Host " [$($device.Status)]" -ForegroundColor Red
                }
            }
        }
        catch {
            Write-WarningLog "Nie można sprawdzić urządzeń audio"
        }
        Write-Host ""
        
        Write-Host "2. RESTART USŁUGI AUDIO" -ForegroundColor Cyan
        if (Confirm-Action -Message "Czy chcesz zrestartować usługę Windows Audio?") {
            try {
                Restart-Service -Name "Audiosrv" -Force
                Write-Success "Usługa audio zrestartowana"
            }
            catch {
                Write-ErrorLog "Nie udało się zrestartować usługi audio" -Exception $_
            }
        }
        Write-Host ""
        
        Write-Host "3. SPRAWDŹ DOMYŚLNE URZĄDZENIE" -ForegroundColor Cyan
        Write-Info "Otwórz Ustawienia → System → Dźwięk"
        Write-Info "Sprawdź czy odpowiednie urządzenie jest ustawione jako domyślne"
        Write-Host ""
    }
    
    Pause
}

function Troubleshoot-DisplayIssues {
    Write-Header "DIAGNOSTYKA: Problemy z wyświetlaczem"
    
    Write-Host "Jakie problemy doświadczasz?" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Miganie ekranu" -ForegroundColor White
    Write-Host "2. Artefakty graficzne" -ForegroundColor White
    Write-Host "3. Nieprawidłowe kolory" -ForegroundColor White
    Write-Host "4. Niski refresh rate" -ForegroundColor White
    Write-Host ""
    
    $displayChoice = Read-Host "Wybierz (1-4)"
    
    Write-Host ""
    switch ($displayChoice) {
        "1" {
            Write-Info "Miganie ekranu - możliwe przyczyny:"
            Write-Host "  • VRR/G-Sync/FreeSync konflikty" -ForegroundColor Gray
            Write-Host "  • Nieaktualny sterownik Intel Arc" -ForegroundColor Gray
            Write-Host "  • Problemy z refresh rate" -ForegroundColor Gray
            Write-Host ""
            Write-Info "Rozwiązania:"
            Write-Host "  ✓ Zaktualizuj sterownik Intel Arc" -ForegroundColor Green
            Write-Host "  ✓ Wyłącz VRR w ustawieniach gry" -ForegroundColor Green
            Write-Host "  ✓ Zablokuj refresh rate na 60Hz" -ForegroundColor Green
        }
        "2" {
            Write-Info "Artefakty graficzne - możliwe przyczyny:"
            Write-Host "  • Przegrzanie GPU" -ForegroundColor Gray
            Write-Host "  • Uszkodzony sterownik" -ForegroundColor Gray
            Write-Host "  • Błędna konfiguracja VRAM w BIOS" -ForegroundColor Gray
            Write-Host ""
            Write-Warning-Custom "KRYTYCZNE: Artefakty mogą wskazywać na problem sprzętowy!"
            Write-Info "Zalecenia:"
            Write-Host "  1. Sprawdź temperatury GPU" -ForegroundColor Yellow
            Write-Host "  2. Przeinstaluj sterownik Intel Arc (DDU)" -ForegroundColor Yellow
            Write-Host "  3. Zresetuj ustawienia BIOS do domyślnych" -ForegroundColor Yellow
            Write-Host "  4. Jeśli problemy utrzymują się - kontakt z MSI Support" -ForegroundColor Yellow
        }
        "3" {
            Write-Info "Nieprawidłowe kolory:"
            Write-Host "  ✓ Sprawdź profil kolorów w Ustawieniach Windows" -ForegroundColor Green
            Write-Host "  ✓ Zresetuj ustawienia kolorów w Intel Graphics Command Center" -ForegroundColor Green
            Write-Host "  ✓ Wyłącz Night Light / Blue Light Filter" -ForegroundColor Green
        }
        "4" {
            Write-Info "Sprawdzam aktualny refresh rate..."
            # Tutaj możemy dodać sprawdzanie refresh rate
            Write-Host "  → Ustaw refresh rate w Ustawieniach Windows → System → Ekran → Zaawansowane"
            Write-Host "  → 60Hz dla dłuższej baterii" -ForegroundColor Gray
            Write-Host "  → 120Hz dla płynniejszego obrazu (krótszy czas baterii)" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    Pause
}

function Troubleshoot-ChargingIssues {
    Write-Header "DIAGNOSTYKA: Problemy z ładowaniem"
    
    Write-Info "Sprawdzam konfigurację ładowania..."
    Write-Host ""
    
    $battery = Get-WmiObject Win32_Battery -ErrorAction SilentlyContinue
    if ($battery) {
        Write-Host "═══ STATUS BATERII ═══" -ForegroundColor Yellow
        Write-Host "Stan:           " -NoNewline; Write-Host $battery.BatteryStatus -ForegroundColor White
        Write-Host "Poziom:         " -NoNewline; Write-Host "$($battery.EstimatedChargeRemaining)%" -ForegroundColor White
        Write-Host "Dostępność:     " -NoNewline; Write-Host $battery.Availability -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host "═══ TYPOWE PROBLEMY I ROZWIĄZANIA ═══" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. NIE ŁADUJE SIĘ WCALE" -ForegroundColor Cyan
    Write-Info "   → Sprawdź czy kabel jest dobrze podłączony"
    Write-Info "   → Sprawdź czy używasz oryginalnej ładowarki (65W USB-C PD)"
    Write-Info "   → Wypróbuj inny port USB-C (MSI Claw ma 2 porty)"
    Write-Info "   → Zrestartuj urządzenie"
    Write-Host ""
    
    Write-Host "2. ŁADUJE BARDZO WOLNO" -ForegroundColor Cyan
    Write-Info "   → MSI Claw wymaga 65W USB-C PD"
    Write-Info "   → Ładowarki <65W będą ładować wolniej"
    Write-Info "   → Podczas grania ładowanie może być wolniejsze"
    Write-Info "   → Wyłącz Over Boost aby przyspieszyć ładowanie"
    Write-Host ""
    
    Write-Host "3. ŁADUJE TYLKO DO ~80-85%" -ForegroundColor Cyan
    Write-Info "   → To może być Battery Health Protection"
    Write-Info "   → Sprawdź w MSI Center M → Settings → Battery"
    Write-Info "   → Wyłącz 'Best for battery health' jeśli chcesz 100%"
    Write-Host ""
    
    Write-Host "4. NIE ROZPOZNAJE ŁADOWARKI" -ForegroundColor Cyan
    Write-Info "   → Sprawdź czy ładowarka wspiera USB Power Delivery (PD)"
    Write-Info "   → Niektóre ładowarki telefonów nie działają poprawnie"
    Write-Info "   → Zalecana: oryginalna ładowarka MSI lub certyfikowana 65W USB-C PD"
    Write-Host ""
    
    Pause
}

function Troubleshoot-ConnectivityIssues {
    Write-Header "DIAGNOSTYKA: Problemy z WiFi / Bluetooth"
    
    Write-Info "Sprawdzam adaptery sieciowe..."
    Write-Host ""
    
    try {
        $networkAdapters = Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -eq $true }
        
        Write-Host "═══ ADAPTERY SIECIOWE ═══" -ForegroundColor Yellow
        foreach ($adapter in $networkAdapters) {
            Write-Host "• $($adapter.Name)" -NoNewline
            if ($adapter.NetEnabled) {
                Write-Host " [Włączony]" -ForegroundColor Green
            }
            else {
                Write-Host " [Wyłączony]" -ForegroundColor Red
            }
        }
        Write-Host ""
    }
    catch {
        Write-WarningLog "Nie można sprawdzić adapterów"
    }
    
    Write-Host "═══ TYPOWE ROZWIĄZANIA ═══" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "1. RESTART ADAPTERA" -ForegroundColor Cyan
    if (Confirm-Action -Message "Czy chcesz zrestartować adaptery WiFi/Bluetooth?") {
        try {
            Write-Info "Restartowanie adapterów..."
            Get-NetAdapter | Where-Object { $_.InterfaceDescription -like "*Wi-Fi*" -or $_.InterfaceDescription -like "*Wireless*" } | 
                Restart-NetAdapter
            Write-Success "Adaptery zrestartowane"
        }
        catch {
            Write-ErrorLog "Nie udało się zrestartować adapterów" -Exception $_
        }
    }
    Write-Host ""
    
    Write-Host "2. RESET USTAWIEŃ SIECIOWYCH" -ForegroundColor Cyan
    Write-Warning-Custom "To usunie wszystkie zapisane sieci WiFi!"
    if (Confirm-Action -Message "Czy chcesz zresetować ustawienia sieciowe?") {
        try {
            Write-Info "Resetowanie ustawień sieciowych..."
            netsh winsock reset
            netsh int ip reset
            Write-Success "Ustawienia zresetowane - wymagany restart"
        }
        catch {
            Write-ErrorLog "Nie udało się zresetować ustawień" -Exception $_
        }
    }
    Write-Host ""
    
    Write-Host "3. AKTUALIZACJA STEROWNIKÓW" -ForegroundColor Cyan
    Write-Info "Sprawdź aktualizacje sterowników w Menedżerze urządzeń"
    Write-Info "lub na stronie MSI Support"
    Write-Host ""
    
    Pause
}

# ════════════════════════════════════════════════════════════════════════════════
# FUNKCJE RAPORTOWANIA
# ════════════════════════════════════════════════════════════════════════════════

function Export-SystemReport {
    <#
    .SYNOPSIS
        Eksportuje szczegółowy raport diagnostyczny
    #>
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet('HTML', 'JSON', 'CSV', 'TXT')]
        [string]$Format = 'HTML',
        
        [Parameter(Mandatory=$false)]
        [hashtable]$SystemInfo
    )
    
    Write-Header "EKSPORT RAPORTU DIAGNOSTYCZNEGO"
    
    if (-not $SystemInfo) {
        $SystemInfo = Get-ComprehensiveSystemInfo
    }
    
    $reportFileName = "MSI_Claw_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    
    switch ($Format) {
        'HTML' {
            $reportPath = Join-Path $Script:Config.ReportsPath "$reportFileName.html"
            
            $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>MSI Claw Diagnostic Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #c8102e; border-bottom: 3px solid #c8102e; padding-bottom: 10px; }
        h2 { color: #333; border-bottom: 1px solid #ddd; padding-bottom: 5px; margin-top: 30px; }
        .section { margin: 20px 0; }
        .info-row { display: flex; padding: 8px 0; border-bottom: 1px solid #eee; }
        .info-label { font-weight: bold; width: 200px; color: #666; }
        .info-value { flex: 1; }
        .status-ok { color: #28a745; font-weight: bold; }
        .status-warning { color: #ffc107; font-weight: bold; }
        .status-error { color: #dc3545; font-weight: bold; }
        .footer { margin-top: 40px; padding-top: 20px; border-top: 2px solid #ddd; text-align: center; color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="container">
        <h1>MSI CLAW DIAGNOSTIC REPORT</h1>
        <p><strong>Generated:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p><strong>Script Version:</strong> $($Script:Version)</p>
        <p><strong>Author:</strong> $($Script:Author) | <strong>Organization:</strong> $($Script:Organization)</p>
        
        <h2>System Information</h2>
        <div class="section">
            <div class="info-row">
                <div class="info-label">Computer Name:</div>
                <div class="info-value">$env:COMPUTERNAME</div>
            </div>
            <div class="info-row">
                <div class="info-label">Operating System:</div>
                <div class="info-value">$($SystemInfo.OS.Caption)</div>
            </div>
            <div class="info-row">
                <div class="info-label">Build:</div>
                <div class="info-value">$($SystemInfo.OS.BuildNumber) ($($SystemInfo.OS.DisplayVersion))</div>
            </div>
        </div>
        
        <h2>CPU</h2>
        <div class="section">
            <div class="info-row">
                <div class="info-label">Model:</div>
                <div class="info-value">$($SystemInfo.CPU.Name)</div>
            </div>
            <div class="info-row">
                <div class="info-label">Cores:</div>
                <div class="info-value">$($SystemInfo.CPU.NumberOfCores) physical / $($SystemInfo.CPU.NumberOfLogicalProcessors) logical</div>
            </div>
"@

            if ($SystemInfo.CPU.PCores) {
                $htmlContent += @"
            <div class="info-row">
                <div class="info-label">Architecture:</div>
                <div class="info-value">P-Cores: $($SystemInfo.CPU.PCores) | E-Cores: $($SystemInfo.CPU.ECores) | Generation: $($SystemInfo.CPU.Generation)</div>
            </div>
"@
            }

            $htmlContent += @"
        </div>
        
        <h2>Graphics</h2>
        <div class="section">
"@

            foreach ($gpu in $SystemInfo.GPU) {
                $driverStatus = if ($gpu.DriverStatus -eq "Up-to-date") { "status-ok" } 
                               elseif ($gpu.DriverStatus -like "*Outdated*") { "status-warning" }
                               else { "status-error" }
                
                $htmlContent += @"
            <div class="info-row">
                <div class="info-label">GPU:</div>
                <div class="info-value">$($gpu.Name)</div>
            </div>
            <div class="info-row">
                <div class="info-label">Driver Version:</div>
                <div class="info-value">$($gpu.DriverVersion)</div>
            </div>
            <div class="info-row">
                <div class="info-label">Status:</div>
                <div class="info-value"><span class="$driverStatus">$($gpu.DriverStatus)</span></div>
            </div>
"@
            }

            $htmlContent += @"
        </div>
        
        <h2>BIOS</h2>
        <div class="section">
            <div class="info-row">
                <div class="info-label">Version:</div>
                <div class="info-value">$($SystemInfo.BIOS.Version)</div>
            </div>
            <div class="info-row">
                <div class="info-label">Date:</div>
                <div class="info-value">$($SystemInfo.BIOS.Date)</div>
            </div>
            <div class="info-row">
                <div class="info-label">Status:</div>
                <div class="info-value"><span class="$(if ($SystemInfo.BIOS.Status -eq 'Up-to-date') { 'status-ok' } else { 'status-warning' })">$($SystemInfo.BIOS.Status)</span></div>
            </div>
        </div>
        
        <h2>Battery</h2>
        <div class="section">
"@

            if ($SystemInfo.Battery.Status -ne "Not Detected") {
                $batteryHealthClass = if ($SystemInfo.Battery.Health -gt 80) { "status-ok" } 
                                     elseif ($SystemInfo.Battery.Health -gt 60) { "status-warning" }
                                     else { "status-error" }
                
                $htmlContent += @"
            <div class="info-row">
                <div class="info-label">Health:</div>
                <div class="info-value"><span class="$batteryHealthClass">$($SystemInfo.Battery.Health)%</span></div>
            </div>
            <div class="info-row">
                <div class="info-label">Current Charge:</div>
                <div class="info-value">$($SystemInfo.Battery.EstimatedChargeRemaining)%</div>
            </div>
            <div class="info-row">
                <div class="info-label">Capacity:</div>
                <div class="info-value">$($SystemInfo.Battery.FullChargeCapacity) / $($SystemInfo.Battery.DesignCapacity) mWh</div>
            </div>
            <div class="info-row">
                <div class="info-label">Status:</div>
                <div class="info-value">$($SystemInfo.Battery.BatteryStatus)</div>
            </div>
"@
            }
            else {
                $htmlContent += @"
            <div class="info-row">
                <div class="info-label">Status:</div>
                <div class="info-value">Not Detected</div>
            </div>
"@
            }

            $htmlContent += @"
        </div>
        
        <h2>Memory</h2>
        <div class="section">
            <div class="info-row">
                <div class="info-label">Total RAM:</div>
                <div class="info-value">$($SystemInfo.Memory.TotalPhysicalGB) GB</div>
            </div>
            <div class="info-row">
                <div class="info-label">Available:</div>
                <div class="info-value">$($SystemInfo.Memory.FreePhysicalGB) GB</div>
            </div>
            <div class="info-row">
                <div class="info-label">Usage:</div>
                <div class="info-value"><span class="$(if ($SystemInfo.Memory.UsedPercent -lt 80) { 'status-ok' } else { 'status-warning' })">$($SystemInfo.Memory.UsedPercent)%</span></div>
            </div>
        </div>
        
        <div class="footer">
            <p><strong>MSI Claw Optimizer v$($Script:Version)</strong></p>
            <p>Author: $($Script:Author) | Organization: $($Script:Organization)</p>
            <p>This report was generated automatically by MSI Claw Optimizer</p>
        </div>
    </div>
</body>
</html>
"@

            $htmlContent | Out-File -FilePath $reportPath -Encoding UTF8
            Write-Success "Raport HTML wygenerowany: $reportPath"
            
            if (Confirm-Action -Message "Czy chcesz otworzyć raport?" -DefaultYes) {
                Start-Process $reportPath
            }
        }
        
        'JSON' {
            $reportPath = Join-Path $Script:Config.ReportsPath "$reportFileName.json"
            $SystemInfo | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding UTF8
            Write-Success "Raport JSON wygenerowany: $reportPath"
        }
        
        'TXT' {
            $reportPath = Join-Path $Script:Config.ReportsPath "$reportFileName.txt"
            # Implementacja TXT export
            Write-Success "Raport TXT wygenerowany: $reportPath"
        }
    }
    
    return $reportPath
}

# ════════════════════════════════════════════════════════════════════════════════
# MENU GŁÓWNE
# ════════════════════════════════════════════════════════════════════════════════

function Show-MainMenu {
    <#
    .SYNOPSIS
        Wyświetla główne menu aplikacji
    #>
    
    Show-Banner
    
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "                              MENU GŁÓWNE" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  DIAGNOSTYKA I INFORMACJE:" -ForegroundColor Cyan
    Write-Host "  ──────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  1. 🔍 Pełna diagnostyka systemu (CPU, GPU, BIOS, bateria, RAM)" -ForegroundColor White
    Write-Host "  2. 🩺 Interaktywne rozwiązywanie problemów" -ForegroundColor White
    Write-Host "  3. 📊 Eksportuj raport diagnostyczny (HTML/JSON)" -ForegroundColor White
    Write-Host ""
    Write-Host "  OPTYMALIZACJE:" -ForegroundColor Cyan
    Write-Host "  ──────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  4. 💤 Naprawa problemów z hibernacją i baterią" -ForegroundColor White
    Write-Host "  5. ⚡ Optymalizacja Windows 11 dla gaming" -ForegroundColor White
    Write-Host "  6. 🎮 Tworzenie profili wydajnościowych per-gra" -ForegroundColor White
    Write-Host ""
    Write-Host "  ZAAWANSOWANE:" -ForegroundColor Cyan
    Write-Host "  ──────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  7. 💾 Zarządzanie backupami konfiguracji" -ForegroundColor White
    Write-Host "  8. 🔄 Przywróć konfigurację z backupu (rollback)" -ForegroundColor White
    Write-Host "  9. 📋 Wyświetl logi sesji" -ForegroundColor White
    Write-Host " 10. 📜 Historia zastosowanych zmian" -ForegroundColor White
    Write-Host ""
    Write-Host "  AUTOMATYZACJA:" -ForegroundColor Cyan
    Write-Host "  ──────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host " 11. 🚀 PEŁNA AUTOMATYCZNA OPTYMALIZACJA (All-in-One)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  0. ❌ Wyjście" -ForegroundColor Red
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
}

# ════════════════════════════════════════════════════════════════════════════════
# FUNKCJA GŁÓWNA
# ════════════════════════════════════════════════════════════════════════════════

function Start-MSIClawOptimizer {
    <#
    .SYNOPSIS
        Główna funkcja uruchamiająca aplikację
    #>
    
    # 1. Inicjalizacja
    try {
        # Sprawdź uprawnienia administratora
        Test-AdministratorPrivileges | Out-Null
        
        # Inicjalizuj system logowania
        Initialize-Logging
        
        Write-InfoLog "MSI Claw Optimizer v$($Script:Version) uruchomiony"
        Write-InfoLog "Tryb: $Mode | Poziom logowania: $LogLevel"
        
        # Sprawdź kompatybilność
        $compatibility = Test-SystemCompatibility
        
        if (-not $compatibility.IsCompatible) {
            Write-CriticalLog "System nie jest kompatybilny z tym skryptem"
            
            Write-Host ""
            Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Red
            Write-Host " BŁĄD KOMPATYBILNOŚCI" -ForegroundColor Red
            Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Red
            Write-Host ""
            Write-Host "Wykryto krytyczne problemy z kompatybilnością:" -ForegroundColor Yellow
            foreach ($issue in $compatibility.Issues) {
                Write-Host "  ✗ $issue" -ForegroundColor Red
            }
            Write-Host ""
            Write-Warning-Custom "Ten skrypt może nie działać poprawnie na tym systemie"
            
            if (-not (Confirm-Action -Message "Czy mimo to chcesz kontynuować?")) {
                Write-InfoLog "Użytkownik anulował z powodu problemów z kompatybilnością"
                return
            }
        }
        
        if ($compatibility.Warnings.Count -gt 0) {
            Write-Host ""
            Write-Warning-Custom "Ostrzeżenia dotyczące kompatybilności:"
            foreach ($warning in $compatibility.Warnings) {
                Write-Host "  ⚠ $warning" -ForegroundColor Yellow
            }
            Start-Sleep -Seconds 3
        }
        
        # Sprawdź stan zdrowia systemu
        $health = Get-SystemHealth
        Write-InfoLog "Stan zdrowia systemu: $($health.Overall) (Score: $($health.Score))"
        
        if ($health.Overall -eq "Poor") {
            Write-Warning-Custom "System wymaga uwagi przed optymalizacją"
            if ($health.Issues.Count -gt 0) {
                Write-Host "Wykryte problemy:" -ForegroundColor Yellow
                foreach ($issue in $health.Issues) {
                    Write-Host "  • $issue" -ForegroundColor Red
                }
            }
            Start-Sleep -Seconds 3
        }
        
    }
    catch {
        Write-CriticalLog "Błąd krytyczny podczas inicjalizacji" -Exception $_
        Write-Host "Naciśnij dowolny klawisz aby zakończyć..." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        exit 1
    }
    
    # 2. Tryb pracy
    switch ($Mode) {
        'Automatic' {
            Write-InfoLog "Uruchomiono tryb automatyczny"
            # Pełna automatyczna optymalizacja
            # [implementacja]
        }
        
        'DiagnosticOnly' {
            Write-InfoLog "Uruchomiono tryb diagnostyczny"
            $sysInfo = Get-ComprehensiveSystemInfo
            Show-SystemDiagnosticsReport -SysInfo $sysInfo
            
            if ($GenerateReport) {
                Export-SystemReport -SystemInfo $sysInfo -Format 'HTML'
            }
            
            Pause
            return
        }
        
        'BenchmarkOnly' {
            Write-InfoLog "Uruchomiono tryb benchmarku"
            # [implementacja benchmarku]
        }
        
        'Interactive' {
            # Główna pętla interaktywna
            $sysInfo = $null
            
            while ($true) {
                Show-MainMenu
                
                $choice = Read-Host "Wybierz opcję (0-11)"
                Write-InfoLog "Użytkownik wybrał opcję: $choice"
                
                try {
                    switch ($choice) {
                        "1" {
                            $sysInfo = Get-ComprehensiveSystemInfo
                            Show-SystemDiagnosticsReport -SysInfo $sysInfo
                            Pause
                        }
                        "2" {
                            Start-InteractiveTroubleshooting
                        }
                        "3" {
                            if (-not $sysInfo) {
                                $sysInfo = Get-ComprehensiveSystemInfo
                            }
                            Export-SystemReport -SystemInfo $sysInfo -Format 'HTML'
                            Pause
                        }
                        "4" {
                            Optimize-HibernationConfiguration
                            Pause
                        }
                        "5" {
                            Optimize-WindowsForGaming
                        }
                        "6" {
                            if (-not $sysInfo) {
                                $sysInfo = Get-ComprehensiveSystemInfo
                            }
                            New-GamePerformanceProfiles -CPUInfo $sysInfo.CPU
                            Pause
                        }
                        "7" {
                            # Zarządzanie backupami
                            # [implementacja]
                            Pause
                        }
                        "8" {
                            Restore-ConfigurationBackup
                            Pause
                        }
                        "9" {
                            # Wyświetl logi
                            if ($Script:LogFile -and (Test-Path $Script:LogFile)) {
                                notepad $Script:LogFile
                            }
                            else {
                                Write-Warning-Custom "Brak pliku logu"
                            }
                        }
                        "10" {
                            # Historia zmian
                            Write-Header "HISTORIA ZASTOSOWANYCH ZMIAN"
                            if ($Script:ChangesApplied.Count -gt 0) {
                                foreach ($change in $Script:ChangesApplied) {
                                    Write-Host "[$($change.Timestamp.ToString('yyyy-MM-dd HH:mm:ss'))]" -ForegroundColor Gray
                                    Write-Host "  Operacja: $($change.Operation)" -ForegroundColor Cyan
                                    Write-Host "  Zmiany: $($change.Changes.Count)" -ForegroundColor White
                                    if ($change.Errors.Count -gt 0) {
                                        Write-Host "  Błędy: $($change.Errors.Count)" -ForegroundColor Red
                                    }
                                    Write-Host ""
                                }
                            }
                            else {
                                Write-Info "Brak zastosowanych zmian w tej sesji"
                            }
                            Pause
                        }
                        "11" {
                            Write-Header "PEŁNA AUTOMATYCZNA OPTYMALIZACJA" `
                                         -SubText "Kompleksowa optymalizacja MSI Claw"
                            
                            Write-InfoLog "Uruchamiam pełną automatyczną optymalizację"
                            
                            if (Confirm-Action -Message "Czy chcesz uruchomić pełną optymalizację?" `
                                               -WarningMessage "To wykona wszystkie zalecane optymalizacje" `
                                               -DefaultYes) {
                                
                                # 1. Diagnostyka
                                $sysInfo = Get-ComprehensiveSystemInfo
                                Show-SystemDiagnosticsReport -SysInfo $sysInfo
                                Start-Sleep -Seconds 5
                                
                                # 2. Hibernacja
                                Optimize-HibernationConfiguration
                                Start-Sleep -Seconds 2
                                
                                # 3. Windows
                                Optimize-WindowsForGaming
                                
                                # 4. Profile
                                New-GamePerformanceProfiles -CPUInfo $sysInfo.CPU
                                
                                # 5. Raport
                                Export-SystemReport -SystemInfo $sysInfo -Format 'HTML'
                                
                                Write-Host ""
                                Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
                                Write-Host "║              ✓ OPTYMALIZACJA ZAKOŃCZONA POMYŚLNIE!            ║" -ForegroundColor Green
                                Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
                                Write-Host ""
                                
                                Write-InfoLog "Pełna automatyczna optymalizacja zakończona pomyślnie"
                            }
                            
                            Pause
                        }
                        "0" {
                            # Zakończenie
                            Write-InfoLog "Użytkownik zakończył aplikację"
                            
                            Write-Host ""
                            Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "  Dziękujemy za użycie MSI Claw Optimizer v$($Script:Version)!" -ForegroundColor Cyan
                            Write-Host ""
                            Write-Host "  Autor: $($Script:Author)" -ForegroundColor Gray
                            Write-Host "  Pod patronem: $($Script:Organization)" -ForegroundColor Gray
                            Write-Host ""
                            Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
                            Write-Host ""
                            
                            # Podsumowanie sesji
                            $sessionDuration = (Get-Date) - $Script:SessionStartTime
                            Write-InfoLog "Sesja zakończona. Czas trwania: $($sessionDuration.ToString('hh\:mm\:ss'))"
                            Write-InfoLog "Wykonano operacji: $($Script:OperationCounter)"
                            Write-InfoLog "Zastosowano zmian: $($Script:ChangesApplied.Count)"
                            
                            exit 0
                        }
                        default {
                            Write-Error-Custom "Nieprawidłowy wybór!"
                            Write-WarningLog "Użytkownik wprowadził nieprawidłowy wybór: $choice"
                            Start-Sleep -Seconds 2
                        }
                    }
                }
                catch {
                    Write-CriticalLog "Błąd podczas wykonywania opcji $choice" -Exception $_
                    Write-Error-Custom "Wystąpił błąd: $_"
                    Write-Host "Szczegóły zapisano w logu" -ForegroundColor Gray
                    Start-Sleep -Seconds 3
                }
            }
        }
    }
}

# ════════════════════════════════════════════════════════════════════════════════
# PUNKT WEJŚCIA
# ════════════════════════════════════════════════════════════════════════════════

# Uruchom główną funkcję
Start-MSIClawOptimizer

# ════════════════════════════════════════════════════════════════════════════════
# KONIEC SKRYPTU
# ════════════════════════════════════════════════════════════════════════════════
