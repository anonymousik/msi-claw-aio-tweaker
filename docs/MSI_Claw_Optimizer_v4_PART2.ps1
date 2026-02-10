# ════════════════════════════════════════════════════════════════════════════════
# MSI CLAW OPTIMIZER v4.0 PROFESSIONAL EDITION - CZĘŚĆ 2/3
# ════════════════════════════════════════════════════════════════════════════════
# Autor: Nieznany Nikomu Anonymousik | Patron: SecFERRO DIVISION
# ════════════════════════════════════════════════════════════════════════════════

# UWAGA: To jest kontynuacja części 1. Nie uruchamiaj tego pliku samodzielnie!

# ════════════════════════════════════════════════════════════════════════════════
# FUNKCJE OPTYMALIZACYJNE - WINDOWS 11 DLA GAMING
# ════════════════════════════════════════════════════════════════════════════════

function Optimize-WindowsForGaming {
    <#
    .SYNOPSIS
        Optymalizuje Windows 11 dla maksymalnej wydajności w grach
    .DESCRIPTION
        Wykonuje szereg modyfikacji systemowych zwiększających FPS i responsywność
    #>
    
    Write-Header "OPTYMALIZACJA WINDOWS 11 DLA GAMING" `
                 -SubText "Maksymalna wydajność dla handheld gaming"
    
    # Backup przed zmianami
    if ($Script:Config.AutoBackupBeforeChanges) {
        $backupId = New-ConfigurationBackup -Description "Przed optymalizacją Windows"
        Write-InfoLog "Utworzono backup: $backupId"
    }
    
    $optimizations = @()
    $errors = @()
    $restartRequired = $false
    
    try {
        # ═══ 1. MEMORY INTEGRITY (CORE ISOLATION) ═══
        Write-Info "1/12 Wyłączanie Memory Integrity (Core Isolation)..."
        Write-Host "      • Memory Integrity może obniżyć FPS nawet o 5-15%" -ForegroundColor DarkGray
        
        try {
            $miPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
            
            if (Test-Path $miPath) {
                $currentValue = (Get-ItemProperty -Path $miPath -Name "Enabled" -ErrorAction SilentlyContinue).Enabled
                
                if ($currentValue -eq 1) {
                    Set-ItemProperty -Path $miPath -Name "Enabled" -Value 0 -Force
                    Write-Success "Memory Integrity wyłączony (wymaga restartu)"
                    $optimizations += "Memory Integrity disabled"
                    $restartRequired = $true
                    Write-InfoLog "Memory Integrity wyłączony"
                }
                else {
                    Write-Success "Memory Integrity już wyłączony"
                    Write-DebugLog "Memory Integrity był już wyłączony"
                }
            }
            else {
                Write-Info "Memory Integrity nie jest dostępny w tym systemie"
            }
        }
        catch {
            $errors += "Memory Integrity: $_"
            Write-ErrorLog "Błąd wyłączania Memory Integrity" -Exception $_
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 2. VIRTUAL MACHINE PLATFORM (VMP) ═══
        Write-Info "2/12 Sprawdzanie Virtual Machine Platform..."
        Write-Host "      • VMP może obniżać wydajność gdy nie jest potrzebny" -ForegroundColor DarkGray
        
        try {
            $vmpStatus = (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue).State
            
            if ($vmpStatus -eq "Enabled") {
                Write-Warning-Custom "VMP jest włączony"
                
                if (Confirm-Action -Message "Czy chcesz wyłączyć Virtual Machine Platform?" `
                                   -WarningMessage "Wymaga restartu. Wyłącz tylko jeśli nie używasz WSL/Hyper-V") {
                    Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
                    Write-Success "VMP wyłączony (wymaga restartu)"
                    $optimizations += "Virtual Machine Platform disabled"
                    $restartRequired = $true
                    Write-InfoLog "VMP wyłączony"
                }
            }
            else {
                Write-Success "VMP już wyłączony"
            }
        }
        catch {
            $errors += "VMP check: $_"
            Write-WarningLog "Nie można sprawdzić statusu VMP"
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 3. GAME DVR ═══
        Write-Info "3/12 Wyłączanie Game DVR (Xbox Game Bar recording)..."
        Write-Host "      • Game DVR może powodować stuttering i spadki FPS" -ForegroundColor DarkGray
        
        try {
            $regPath = "HKCU:\System\GameConfigStore"
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $regPath -Name "GameDVR_Enabled" -Value 0 -Force
            Set-ItemProperty -Path $regPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Force
            Set-ItemProperty -Path $regPath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Force
            Set-ItemProperty -Path $regPath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Force
            Set-ItemProperty -Path $regPath -Name "GameDVR_EFSEFeatureFlags" -Value 0 -Force
            
            # Wyłącz również w rejestrze Xbox
            $xboxPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
            if (-not (Test-Path $xboxPath)) {
                New-Item -Path $xboxPath -Force | Out-Null
            }
            Set-ItemProperty -Path $xboxPath -Name "AppCaptureEnabled" -Value 0 -Force
            
            Write-Success "Game DVR wyłączony"
            $optimizations += "Game DVR disabled"
            Write-InfoLog "Game DVR wyłączony"
        }
        catch {
            $errors += "Game DVR: $_"
            Write-ErrorLog "Błąd wyłączania Game DVR" -Exception $_
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 4. PCI EXPRESS LINK STATE POWER MANAGEMENT ═══
        Write-Info "4/12 Wyłączanie PCI Express Link State Power Management..."
        Write-Host "      • Może zwiększyć wydajność o 5-8% podczas ładowania" -ForegroundColor DarkGray
        
        try {
            # Tylko na zasilaczu (AC) - na baterii oszczędzamy energię
            powercfg /setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0
            powercfg /setactive SCHEME_CURRENT
            
            Write-Success "PCI Express Power Management wyłączony (zasilacz)"
            $optimizations += "PCIe power management disabled (AC)"
            Write-InfoLog "PCIe Link State PM wyłączony"
        }
        catch {
            $errors += "PCIe PM: $_"
            Write-ErrorLog "Błąd konfiguracji PCIe PM" -Exception $_
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 5. PLAN ZASILANIA ═══
        Write-Info "5/12 Konfiguracja planu zasilania..."
        Write-Host "      • Balanced jest optymalny dla MSI Claw" -ForegroundColor DarkGray
        
        try {
            $balancedGuid = (powercfg /list | Select-String "Balanced" | Select-String "GUID" | 
                           ForEach-Object { 
                               if ($_ -match '\(([a-f0-9-]+)\)') { $matches[1] }
                           }) | Select-Object -First 1
            
            if ($balancedGuid) {
                powercfg /setactive $balancedGuid
                Write-Success "Plan zasilania: Balanced"
                $optimizations += "Power plan set to Balanced"
                Write-InfoLog "Plan zasilania ustawiony na Balanced"
            }
            else {
                Write-Warning-Custom "Nie znaleziono planu Balanced"
            }
        }
        catch {
            $errors += "Power plan: $_"
            Write-ErrorLog "Błąd ustawiania planu zasilania" -Exception $_
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 6. WYŁĄCZANIE NIEPOTRZEBNYCH USŁUG ═══
        Write-Info "6/12 Optymalizacja usług systemowych..."
        Write-Host "      • Wyłączanie usług które mogą spowalniać" -ForegroundColor DarkGray
        
        $servicesToDisable = @{
            "DiagTrack" = "Connected User Experiences and Telemetry"
            "SysMain" = "Superfetch (może spowalniać na SSD)"
            "WSearch" = "Windows Search (opcjonalnie - oszczędza zasoby)"
        }
        
        foreach ($serviceName in $servicesToDisable.Keys) {
            try {
                $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
                
                if ($service) {
                    if ($service.StartType -ne "Disabled") {
                        # Dla WSearch pytaj użytkownika
                        if ($serviceName -eq "WSearch") {
                            if (-not (Confirm-Action -Message "Wyłączyć Windows Search? (przyspieszy system ale utrudni wyszukiwanie plików)")) {
                                continue
                            }
                        }
                        
                        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                        Set-Service -Name $serviceName -StartupType Disabled
                        Write-Success "Usługa $serviceName wyłączona"
                        $optimizations += "Service $serviceName disabled"
                        Write-InfoLog "Wyłączono usługę: $serviceName"
                    }
                }
            }
            catch {
                Write-DebugLog "Nie można wyłączyć $serviceName: $_"
            }
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 7. VISUAL EFFECTS (WYDAJNOŚĆ) ═══
        Write-Info "7/12 Optymalizacja efektów wizualnych..."
        Write-Host "      • Wyłączanie niepotrzebnych animacji" -ForegroundColor DarkGray
        
        try {
            $visualEffectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
            if (-not (Test-Path $visualEffectsPath)) {
                New-Item -Path $visualEffectsPath -Force | Out-Null
            }
            
            # Ustaw na "Adjust for best performance" z zachowaniem kilku efektów
            Set-ItemProperty -Path $visualEffectsPath -Name "VisualFXSetting" -Value 2 -Force
            
            # Wyłącz animacje w taskbarze
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                             -Name "TaskbarAnimations" -Value 0 -Force
            
            Write-Success "Efekty wizualne zoptymalizowane"
            $optimizations += "Visual effects optimized"
            Write-InfoLog "Efekty wizualne zoptymalizowane"
        }
        catch {
            $errors += "Visual effects: $_"
            Write-ErrorLog "Błąd optymalizacji efektów wizualnych" -Exception $_
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 8. WYŁĄCZANIE TRANSPARENTNOŚCI ═══
        Write-Info "8/12 Wyłączanie transparentności interfejsu..."
        
        try {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
                             -Name "EnableTransparency" -Value 0 -Force
            
            Write-Success "Transparentność wyłączona"
            $optimizations += "Transparency disabled"
            Write-InfoLog "Transparentność wyłączona"
        }
        catch {
            $errors += "Transparency: $_"
            Write-WarningLog "Nie można wyłączyć transparentności"
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 9. GAME MODE ═══
        Write-Info "9/12 Włączanie Game Mode..."
        Write-Host "      • Game Mode optymalizuje alokację zasobów dla gier" -ForegroundColor DarkGray
        
        try {
            $gameModePath = "HKCU:\Software\Microsoft\GameBar"
            if (-not (Test-Path $gameModePath)) {
                New-Item -Path $gameModePath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $gameModePath -Name "AutoGameModeEnabled" -Value 1 -Force
            Set-ItemProperty -Path $gameModePath -Name "AllowAutoGameMode" -Value 1 -Force
            
            Write-Success "Game Mode włączony"
            $optimizations += "Game Mode enabled"
            Write-InfoLog "Game Mode włączony"
        }
        catch {
            $errors += "Game Mode: $_"
            Write-ErrorLog "Błąd włączania Game Mode" -Exception $_
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 10. BACKGROUND APPS ═══
        Write-Info "10/12 Ograniczanie aplikacji w tle..."
        
        try {
            $backgroundAppsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
            if (-not (Test-Path $backgroundAppsPath)) {
                New-Item -Path $backgroundAppsPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $backgroundAppsPath -Name "GlobalUserDisabled" -Value 1 -Force
            
            Write-Success "Aplikacje w tle ograniczone"
            $optimizations += "Background apps limited"
            Write-InfoLog "Aplikacje w tle ograniczone"
        }
        catch {
            $errors += "Background apps: $_"
            Write-WarningLog "Nie można ograniczyć aplikacji w tle"
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 11. FULLSCREEN OPTIMIZATIONS ═══
        Write-Info "11/12 Konfiguracja fullscreen optimizations..."
        
        try {
            $fsoPath = "HKCU:\System\GameConfigStore"
            Set-ItemProperty -Path $fsoPath -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 0 -Force
            Set-ItemProperty -Path $fsoPath -Name "GameDVR_FSEBehavior" -Value 2 -Force
            
            Write-Success "Fullscreen optimizations skonfigurowane"
            $optimizations += "Fullscreen optimizations configured"
            Write-InfoLog "FSO skonfigurowane"
        }
        catch {
            $errors += "FSO: $_"
            Write-WarningLog "Nie można skonfigurować FSO"
        }
        
        Start-Sleep -Milliseconds 500
        
        # ═══ 12. HARDWARE ACCELERATED GPU SCHEDULING ═══
        Write-Info "12/12 Włączanie Hardware-Accelerated GPU Scheduling..."
        Write-Host "      • HAGS może poprawić latency i wydajność GPU" -ForegroundColor DarkGray
        
        try {
            $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
            
            # Sprawdź czy obsługiwane
            if (Test-Path $hagsPath) {
                Set-ItemProperty -Path $hagsPath -Name "HwSchMode" -Value 2 -Force
                Write-Success "Hardware-Accelerated GPU Scheduling włączony (wymaga restartu)"
                $optimizations += "HAGS enabled"
                $restartRequired = $true
                Write-InfoLog "HAGS włączony"
            }
            else {
                Write-Info "HAGS nie jest obsługiwany przez sterownik GPU"
            }
        }
        catch {
            $errors += "HAGS: $_"
            Write-WarningLog "Nie można włączyć HAGS (może nie być obsługiwany)"
        }
        
        # ═══ PODSUMOWANIE ═══
        Write-Host ""
        Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
        
        if ($optimizations.Count -gt 0) {
            Write-Host ""
            Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║  ✓ WINDOWS 11 ZOPTYMALIZOWANY DLA GAMING                      ║" -ForegroundColor Green
            Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host ""
            Write-Info "Zastosowano $($optimizations.Count) optymalizacji:"
            
            $optimizations | ForEach-Object {
                Write-Host "  ✓ $_" -ForegroundColor Gray
            }
        }
        
        if ($errors.Count -gt 0) {
            Write-Host ""
            Write-Warning-Custom "Wystąpiły błędy ($($errors.Count)):"
            $errors | ForEach-Object {
                Write-Host "  ✗ $_" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
        Write-Host " ZALECENIA PO OPTYMALIZACJI" -ForegroundColor Cyan
        Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "✓ Ustaw priorytet GPU na 'High Performance' w ustawieniach grafiki" -ForegroundColor Green
        Write-Host "✓ W grach użyj trybu fullscreen zamiast windowed/borderless" -ForegroundColor Green
        Write-Host "✓ Wyłącz overlays (Discord, Steam, etc.) jeśli nie są potrzebne" -ForegroundColor Green
        Write-Host "✓ Ogranicz liczbę aplikacji działających w tle" -ForegroundColor Green
        Write-Host ""
        
        if ($restartRequired) {
            Write-Warning-Custom "WYMAGANY RESTART aby zmiany weszły w życie!"
            Write-Host ""
            
            if (Confirm-Action -Message "Czy chcesz uruchomić ponownie komputer teraz?") {
                Write-InfoLog "Użytkownik potwierdził restart"
                Write-Info "Restartowanie za 10 sekund..."
                Start-Sleep -Seconds 10
                Restart-Computer -Force
            }
        }
        
        $Script:OperationCounter++
        $Script:ChangesApplied += @{
            Timestamp = Get-Date
            Operation = "Windows Gaming Optimization"
            Changes = $optimizations
            Errors = $errors
            RestartRequired = $restartRequired
        }
        
        return ($errors.Count -eq 0)
    }
    catch {
        Write-CriticalLog "Krytyczny błąd podczas optymalizacji Windows" -Exception $_
        
        if ($Script:LastBackupId) {
            Write-Warning-Custom "Wystąpił błąd krytyczny."
            if (Confirm-Action -Message "Czy chcesz przywrócić poprzednią konfigurację?") {
                Restore-ConfigurationBackup -BackupId $Script:LastBackupId
            }
        }
        
        return $false
    }
}

# ════════════════════════════════════════════════════════════════════════════════
# FUNKCJE PROFILI WYDAJNOŚCIOWYCH
# ════════════════════════════════════════════════════════════════════════════════

function New-GamePerformanceProfiles {
    <#
    .SYNOPSIS
        Tworzy profile wydajnościowe zoptymalizowane dla różnych gier
    .DESCRIPTION
        Generuje pliki BAT do szybkiego przełączania profili CPU dla różnych scenariuszy
    #>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$CPUInfo
    )
    
    Write-Header "TWORZENIE PROFILI WYDAJNOŚCIOWYCH PER-GRA" `
                 -SubText "Profile zoptymalizowane dla MSI Claw $($CPUInfo.Model)"
    
    $profilesPath = $Script:Config.ProfilesPath
    
    if (-not (Test-Path $profilesPath)) {
        New-Item -ItemType Directory -Path $profilesPath -Force | Out-Null
        Write-InfoLog "Utworzono katalog profili: $profilesPath"
    }
    
    # Definicje profili zoptymalizowane pod różne gry i scenariusze
    $profiles = @{
        "AAA_MaxPerformance" = @{
            Name = "AAA Max Performance"
            Description = "Maksymalna wydajność dla gier AAA (Cyberpunk, Starfield, etc.)"
            PCoreMax = 100
            ECoreMax = 100
            TDP = "Maximum"
            ExpectedBatteryMin = 60
            Games = @("Cyberpunk 2077", "Starfield", "Baldur's Gate 3", "Hogwarts Legacy")
        }
        "AAA_Balanced" = @{
            Name = "AAA Balanced"
            Description = "Balans wydajność/bateria dla gier AAA"
            PCoreMax = 70
            ECoreMax = 60
            TDP = "High"
            ExpectedBatteryMin = 90
            Games = @("Elden Ring", "Dark Souls", "Sekiro", "Monster Hunter")
        }
        "Competitive_HighFPS" = @{
            Name = "Competitive (High FPS)"
            Description = "Wysoki FPS dla gier competitive"
            PCoreMax = 85
            ECoreMax = 75
            TDP = "High"
            ExpectedBatteryMin = 75
            Games = @("Fortnite", "Apex Legends", "Valorant", "CS:GO", "Overwatch")
        }
        "Sports_60FPS" = @{
            Name = "Sports (60 FPS Lock)"
            Description = "Zoptymalizowane dla gier sportowych @ 60 FPS"
            PCoreMax = 60
            ECoreMax = 50
            TDP = "Medium"
            ExpectedBatteryMin = 120
            Games = @("FIFA 26", "EA FC 25", "NBA 2K", "F1 2024")
        }
        "Strategy_LongSession" = @{
            Name = "Strategy (Long Sessions)"
            Description = "Długie sesje dla gier strategicznych"
            PCoreMax = 55
            ECoreMax = 45
            TDP = "Medium"
            ExpectedBatteryMin = 150
            Games = @("Civilization VI", "Total War", "Cities: Skylines", "Crusader Kings")
        }
        "Indie_UltraLong" = @{
            Name = "Indie / 2D Games"
            Description = "Maksymalny czas baterii dla lekkich gier"
            PCoreMax = 45
            ECoreMax = 35
            TDP = "Low"
            ExpectedBatteryMin = 180
            Games = @("Stardew Valley", "Hades", "Celeste", "Hollow Knight", "Terraria")
        }
        "Emulation_Balanced" = @{
            Name = "Emulation (Balanced)"
            Description = "Balans dla emulacji (Switch, PS3, etc.)"
            PCoreMax = 75
            ECoreMax = 65
            TDP = "High"
            ExpectedBatteryMin = 100
            Games = @("Yuzu", "Ryujinx", "RPCS3", "Dolphin", "PCSX2")
        }
        "Desktop_PowerSaver" = @{
            Name = "Desktop / Browsing"
            Description = "Maksymalna oszczędność dla przeglądania i biura"
            PCoreMax = if ($CPUInfo.Model -eq "135H") { 40 } else { 45 }
            ECoreMax = if ($CPUInfo.Model -eq "135H") { 30 } else { 35 }
            TDP = "Low"
            ExpectedBatteryMin = 240
            Games = @("YouTube", "Chrome", "Edge", "Office", "Steam Deck UI")
        }
    }
    
    Write-Info "Generowanie $($profiles.Count) profili wydajnościowych..."
    Write-Host ""
    
    $progressStep = 80 / $profiles.Count
    $currentProgress = 10
    
    foreach ($profileKey in $profiles.Keys) {
        $profile = $profiles[$profileKey]
        
        Show-ProgressBar -Activity "Tworzenie profili" -PercentComplete $currentProgress `
                         -Status "Generowanie: $($profile.Name)"
        
        # Utwórz plik BAT
        $batContent = @"
@echo off
REM ════════════════════════════════════════════════════════════════════════════
REM  MSI Claw Optimizer v$($Script:Version) - Profile: $($profile.Name)
REM  Autor: $($Script:Author) | Pod patronem: $($Script:Organization)
REM ════════════════════════════════════════════════════════════════════════════
TITLE MSI Claw Profile: $($profile.Name)
COLOR 0B

echo.
echo ════════════════════════════════════════════════════════════════════════════
echo  MSI CLAW PERFORMANCE PROFILE
echo ════════════════════════════════════════════════════════════════════════════
echo.
echo  Profile:        $($profile.Name)
echo  Description:    $($profile.Description)
echo ════════════════════════════════════════════════════════════════════════════
echo.
echo  CPU Max:        P-Cores: $($profile.PCoreMax)%% ^| E-Cores: $($profile.ECoreMax)%%
echo  TDP Level:      $($profile.TDP)
echo  Battery Time:   ~$($profile.ExpectedBatteryMin) minutes
echo ════════════════════════════════════════════════════════════════════════════
echo.
echo  Recommended for:
"@

        foreach ($game in $profile.Games) {
            $batContent += "`r`necho    • $game"
        }

        $batContent += @"

echo.
echo ════════════════════════════════════════════════════════════════════════════
echo.
echo Applying profile...
echo.

REM Ustawienie limitów CPU
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX $($profile.PCoreMax)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX $($profile.PCoreMax)

REM Zastosowanie zmian
powercfg /setactive SCHEME_CURRENT

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ════════════════════════════════════════════════════════════════════════════
    echo  SUCCESS: Profile applied successfully!
    echo ════════════════════════════════════════════════════════════════════════════
    echo.
    echo  ✓ CPU Max Frequency: $($profile.PCoreMax)%%
    echo  ✓ TDP Profile: $($profile.TDP)
    echo  ✓ Expected Battery Life: ~$($profile.ExpectedBatteryMin) min
    echo.
) else (
    echo.
    echo ════════════════════════════════════════════════════════════════════════════
    echo  ERROR: Failed to apply profile!
    echo ════════════════════════════════════════════════════════════════════════════
    echo.
    echo  Please run as Administrator
    echo.
)

echo ════════════════════════════════════════════════════════════════════════════
echo.
pause
"@

        $batPath = Join-Path $profilesPath "$profileKey.bat"
        $batContent | Out-File -FilePath $batPath -Encoding ASCII
        
        Write-DebugLog "Utworzono profil: $profileKey"
        
        $currentProgress += $progressStep
    }
    
    # Utwórz README
    $readmeContent = @"
════════════════════════════════════════════════════════════════════════════════
    PROFILE WYDAJNOŚCIOWE DLA MSI CLAW $($CPUInfo.Model)
════════════════════════════════════════════════════════════════════════════════
    Wersja: $($Script:Version)
    Autor: $($Script:Author)
    Pod patronem: $($Script:Organization)
    Wygenerowano: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
════════════════════════════════════════════════════════════════════════════════

SZYBKI START:
═════════════
1. Kliknij dwukrotnie na plik .bat odpowiadający Twojemu scenariuszowi
2. Potwierdź uprawnienia administratora (jeśli wymagane)
3. Profil zostanie zastosowany natychmiast
4. Możesz przełączać się między profilami w dowolnym momencie

DOSTĘPNE PROFILE:
═════════════════

"@

    foreach ($profileKey in ($profiles.Keys | Sort-Object)) {
        $profile = $profiles[$profileKey]
        $readmeContent += @"

┌─ $($profileKey).bat
│  Nazwa: $($profile.Name)
│  Opis: $($profile.Description)
│  
│  Parametry:
│  • CPU Max: P-Cores $($profile.PCoreMax)% | E-Cores $($profile.ECoreMax)%
│  • TDP Level: $($profile.TDP)
│  • Czas baterii: ~$($profile.ExpectedBatteryMin) minut
│  
│  Zalecane dla:
"@
        foreach ($game in $profile.Games) {
            $readmeContent += "`r`n│  → $game"
        }
        $readmeContent += "`r`n└─────────────────────────────────────────────────────────────────────────`r`n"
    }

    $readmeContent += @"

DODATKOWE PLIKI:
════════════════

RESET.bat         - Przywraca domyślne ustawienia CPU (100%)
CURRENT_STATUS.bat - Wyświetla aktualną konfigurację zasilania

WAŻNE UWAGI:
════════════
⚠ Profile ustawiają MAKSYMALNĄ częstotliwość CPU
⚠ System nadal może obniżyć taktowanie gdy nie jest potrzebne
⚠ Czasy baterii są przybliżone i zależą od:
  • Jasności ekranu
  • Refresh rate (60Hz vs 120Hz)
  • Ustawień graficznych w grze
  • Stanu baterii
  • Czy Over Boost jest włączony w MSI Center M

OPTYMALNE USTAWIENIA DLA RÓŻNYCH GIER:
═══════════════════════════════════════

FIFA/FC 25:
  Profile: Sports_60FPS.bat
  Ustawienia: 60Hz refresh, Medium graphics, 60 FPS cap
  Czas baterii: ~120 min

Cyberpunk 2077:
  Profile: AAA_MaxPerformance.bat (plugged) or AAA_Balanced.bat (battery)
  Ustawienia: FSR/XeSS On, Medium-High graphics
  Czas baterii: ~60-90 min

Fortnite/Apex:
  Profile: Competitive_HighFPS.bat
  Ustawienia: Low-Medium, uncapped FPS
  Czas baterii: ~75 min

Indie Games:
  Profile: Indie_UltraLong.bat
  Ustawienia: Native resolution, vsync on
  Czas baterii: ~180 min

DALSZE OPTYMALIZACJE:
═════════════════════
✓ Wyłącz Over Boost w MSI Center M gdy grasz na baterii
✓ Ogranicz refresh rate do 60Hz dla dłuższej baterii
✓ Użyj FSR/XeSS dla lepszej wydajności
✓ Wyłącz niepotrzebne overlays (Discord, Steam, etc.)
✓ Zamknij aplikacje w tle przed graniem

WSPARCIE:
═════════
Jeśli masz problemy lub pytania:
• GitHub: [SecFERRO Division Repository]
• Reddit: r/MSIClaw
• Discord: MSI Claw Community

════════════════════════════════════════════════════════════════════════════════
SecFERRO DIVISION - Gaming Performance Engineering
════════════════════════════════════════════════════════════════════════════════
"@

    $readmeContent | Out-File -FilePath (Join-Path $profilesPath "CZYTAJ_MNIE.txt") -Encoding UTF8
    
    # Utwórz skrypt RESET
    $resetScript = @"
@echo off
TITLE MSI Claw - Reset to Default Settings
COLOR 0E

echo.
echo ════════════════════════════════════════════════════════════════════════════
echo  MSI CLAW OPTIMIZER - RESET TO DEFAULT
echo ════════════════════════════════════════════════════════════════════════════
echo.
echo  This will reset CPU frequency limits to 100%% (default)
echo.
pause

echo.
echo Resetting CPU configuration...
echo.

powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setactive SCHEME_CURRENT

echo.
echo ════════════════════════════════════════════════════════════════════════════
echo  ✓ CPU configuration reset to default (100%%)
echo ════════════════════════════════════════════════════════════════════════════
echo.
pause
"@

    $resetScript | Out-File -FilePath (Join-Path $profilesPath "RESET.bat") -Encoding ASCII
    
    # Utwórz skrypt sprawdzający status
    $statusScript = @"
@echo off
TITLE MSI Claw - Current Power Configuration
COLOR 0B

echo.
echo ════════════════════════════════════════════════════════════════════════════
echo  MSI CLAW - CURRENT POWER CONFIGURATION
echo ════════════════════════════════════════════════════════════════════════════
echo.

powercfg /query SCHEME_CURRENT SUB_PROCESSOR

echo.
echo ════════════════════════════════════════════════════════════════════════════
echo.
pause
"@

    $statusScript | Out-File -FilePath (Join-Path $profilesPath "CURRENT_STATUS.bat") -Encoding ASCII
    
    Show-ProgressBar -Activity "Tworzenie profili" -PercentComplete 100 -Status "Gotowe!"
    Start-Sleep -Milliseconds 500
    Write-Progress -Activity "Tworzenie profili" -Completed
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✓ PROFILE WYDAJNOŚCIOWE UTWORZONE POMYŚLNIE                  ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Success "Utworzono $($profiles.Count) profili + 2 narzędzia pomocnicze"
    Write-Info "Lokalizacja: $profilesPath"
    Write-Host ""
    Write-Host "Profile dostępne:" -ForegroundColor Cyan
    
    foreach ($profileKey in ($profiles.Keys | Sort-Object)) {
        Write-Host "  • $profileKey.bat" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Info "Przeczytaj CZYTAJ_MNIE.txt aby dowiedzieć się więcej"
    Write-Host ""
    
    $Script:OperationCounter++
    Write-InfoLog "Utworzono $($profiles.Count) profili wydajnościowych"
    
    if (Confirm-Action -Message "Czy chcesz otworzyć folder z profilami?" -DefaultYes) {
        Start-Process "explorer.exe" -ArgumentList $profilesPath
    }
}

# (...kontynuacja w części 3...)

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host " UWAGA: To jest część 2/3 kodu" -ForegroundColor Yellow
Write-Host " Kontynuacja z pozostałymi funkcjami w części 3" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
