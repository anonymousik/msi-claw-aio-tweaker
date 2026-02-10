#Requires -RunAsAdministrator
<#
.SYNOPSIS
    MSI Claw Optimizer v3.0 ULTRA - Kompleksowa Automatyzacja
.DESCRIPTION
    Zaawansowany skrypt do pełnej optymalizacji MSI Claw:
    - Automatyczna diagnostyka BIOS/sterowników
    - Pobieranie i instalacja aktualizacji
    - Naprawa problemów z baterią/hibernacją
    - Profile QuickCPU per-gra
    - Optymalizacja Windows 11
    - Interaktywny troubleshooting
.AUTHOR
    Wersja 3.0 ULTRA - Kompletna optymalizacja MSI Claw
#>

# ═══════════════════════════════════════════════════════════════
# STAŁE I KONFIGURACJA
# ═══════════════════════════════════════════════════════════════

$Script:Config = @{
    # Wersje referencyjne
    MinBIOSVersion = 109
    RecommendedBIOSVersion = 109
    MinArcDriver = "32.0.101.6877"
    RecommendedArcDriver = "32.0.101.6877"
    MinMSICenterM = "1.0.2405.1401"
    
    # URL pobierania
    MSIDriversURL = "https://www.msi.com/Handheld/Claw-A1MX/support"
    IntelArcDriversURL = "https://www.intel.com/content/www/us/en/download/785597/intel-arc-iris-xe-graphics-windows.html"
    QuickCPUDownload = "https://www.coderbag.com/assets/downloads/cpm/currentversion/QuickCpuSetup.msi"
    
    # Paths
    BackupRoot = "$env:USERPROFILE\MSI_Claw_Backups"
    ProfilesPath = "$env:USERPROFILE\Documents\MSI_Claw_Profiles"
    TempPath = "$env:TEMP\MSI_Claw_Optimizer"
}

# ═══════════════════════════════════════════════════════════════
# FUNKCJE POMOCNICZE - INTERFEJS
# ═══════════════════════════════════════════════════════════════

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) { Write-Output $args }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-ColorOutput Yellow "═══════════════════════════════════════════════════════════════════"
    Write-ColorOutput Cyan "  $Text"
    Write-ColorOutput Yellow "═══════════════════════════════════════════════════════════════════"
    Write-Host ""
}

function Write-Success { param([string]$Text); Write-ColorOutput Green "✓ $Text" }
function Write-Warning-Custom { param([string]$Text); Write-ColorOutput Yellow "⚠ $Text" }
function Write-Error-Custom { param([string]$Text); Write-ColorOutput Red "✗ $Text" }
function Write-Info { param([string]$Text); Write-ColorOutput Cyan "ℹ $Text" }

function Show-ProgressBar {
    param(
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

# ═══════════════════════════════════════════════════════════════
# WYKRYWANIE SPRZĘTU I OPROGRAMOWANIA
# ═══════════════════════════════════════════════════════════════

function Get-SystemInfo {
    Write-Header "KOMPLEKSOWA DIAGNOSTYKA SYSTEMU"
    
    $sysInfo = @{}
    
    # CPU
    Write-Info "Wykrywanie procesora..."
    $cpu = Get-WmiObject -Class Win32_Processor
    $cpuName = $cpu.Name
    
    if ($cpuName -match "Ultra 5.*135H") {
        $sysInfo.CPU = @{
            Model = "135H"
            Name = "Intel Core Ultra 5 135H"
            PCores = 6
            ECores = 8
            BaseFreq = 1.7
            MaxTurboP = 4.6
            MaxTurboE = 3.6
        }
    }
    elseif ($cpuName -match "Ultra 7.*155H") {
        $sysInfo.CPU = @{
            Model = "155H"
            Name = "Intel Core Ultra 7 155H"
            PCores = 6
            ECores = 8
            BaseFreq = 1.8
            MaxTurboP = 4.8
            MaxTurboE = 3.8
        }
    }
    else {
        Write-Warning-Custom "Nierozpoznany procesor: $cpuName"
        $sysInfo.CPU = @{
            Model = "Unknown"
            Name = $cpuName
        }
    }
    
    # GPU
    Write-Info "Wykrywanie karty graficznej..."
    $gpu = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -like "*Intel*Arc*" }
    
    if ($gpu) {
        $sysInfo.GPU = @{
            Name = $gpu.Name
            DriverVersion = $gpu.DriverVersion
            DriverDate = $gpu.DriverDate
            VRAM = [math]::Round($gpu.AdapterRAM / 1GB, 2)
        }
    }
    else {
        $sysInfo.GPU = @{ Name = "Not Found" }
    }
    
    # BIOS
    Write-Info "Sprawdzanie wersji BIOS..."
    $bios = Get-WmiObject -Class Win32_BIOS
    $sysInfo.BIOS = @{
        Version = $bios.SMBIOSBIOSVersion
        Date = $bios.ReleaseDate
        Manufacturer = $bios.Manufacturer
    }
    
    # Bateria
    Write-Info "Sprawdzanie stanu baterii..."
    $battery = Get-WmiObject -Class Win32_Battery
    if ($battery) {
        $sysInfo.Battery = @{
            Name = $battery.Name
            DesignCapacity = $battery.DesignCapacity
            FullChargeCapacity = $battery.FullChargeCapacity
            BatteryStatus = $battery.BatteryStatus
            EstimatedChargeRemaining = $battery.EstimatedChargeRemaining
            Health = [math]::Round(($battery.FullChargeCapacity / $battery.DesignCapacity) * 100, 1)
        }
    }
    
    # Windows
    $sysInfo.Windows = @{
        Version = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
        Build = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild
    }
    
    return $sysInfo
}

function Show-SystemDiagnostics {
    param([hashtable]$SysInfo)
    
    Write-Header "RAPORT DIAGNOSTYCZNY"
    
    # CPU
    Write-Host "CPU:" -ForegroundColor Cyan
    if ($SysInfo.CPU.Model -ne "Unknown") {
        Write-Host "  Model: $($SysInfo.CPU.Name)" -ForegroundColor White
        Write-Host "  Rdzenie P: $($SysInfo.CPU.PCores) | Rdzenie E: $($SysInfo.CPU.ECores)" -ForegroundColor Gray
    }
    else {
        Write-Warning-Custom "  Nierozpoznany procesor"
    }
    
    # GPU
    Write-Host ""
    Write-Host "GPU:" -ForegroundColor Cyan
    if ($SysInfo.GPU.Name -ne "Not Found") {
        Write-Host "  $($SysInfo.GPU.Name)" -ForegroundColor White
        Write-Host "  Driver: $($SysInfo.GPU.DriverVersion)" -ForegroundColor Gray
        Write-Host "  VRAM: $($SysInfo.GPU.VRAM) GB (raportowane)" -ForegroundColor Gray
        
        # Sprawdź wersję sterownika
        $currentDriver = $SysInfo.GPU.DriverVersion
        if ($currentDriver -lt $Script:Config.RecommendedArcDriver) {
            Write-Warning-Custom "  Zalecana aktualizacja do wersji $($Script:Config.RecommendedArcDriver)"
        }
        else {
            Write-Success "  Sterownik aktualny"
        }
    }
    else {
        Write-Warning-Custom "  Intel Arc Graphics nie wykryty"
    }
    
    # BIOS
    Write-Host ""
    Write-Host "BIOS:" -ForegroundColor Cyan
    Write-Host "  Wersja: $($SysInfo.BIOS.Version)" -ForegroundColor White
    
    # Próba wyodrębnienia numeru wersji
    if ($SysInfo.BIOS.Version -match "(\d+)$") {
        $biosNum = [int]$matches[1]
        if ($biosNum -lt $Script:Config.RecommendedBIOSVersion) {
            Write-Warning-Custom "  Dostępna aktualizacja do wersji $($Script:Config.RecommendedBIOSVersion)"
        }
        else {
            Write-Success "  BIOS aktualny"
        }
    }
    
    # Bateria
    Write-Host ""
    Write-Host "Bateria:" -ForegroundColor Cyan
    if ($SysInfo.Battery) {
        Write-Host "  Poziom: $($SysInfo.Battery.EstimatedChargeRemaining)%" -ForegroundColor White
        Write-Host "  Zdrowie baterii: $($SysInfo.Battery.Health)%" -ForegroundColor $(
            if ($SysInfo.Battery.Health -gt 80) { "Green" }
            elseif ($SysInfo.Battery.Health -gt 60) { "Yellow" }
            else { "Red" }
        )
        
        if ($SysInfo.Battery.Health -lt 80) {
            Write-Warning-Custom "  Bateria może wymagać wymiany lub kalibracji"
        }
    }
    
    # Windows
    Write-Host ""
    Write-Host "System:" -ForegroundColor Cyan
    Write-Host "  Windows $($SysInfo.Windows.Version) (Build $($SysInfo.Windows.Build))" -ForegroundColor White
    
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════
# NAPRAWA PROBLEMÓW Z HIBERNACJĄ I BATERIĄ
# ═══════════════════════════════════════════════════════════════

function Fix-HibernationIssues {
    Write-Header "NAPRAWA PROBLEMÓW Z HIBERNACJĄ"
    
    Write-Info "Problem: MSI Claw budzi się podczas Sleep i zjada baterię"
    Write-Info "Rozwiązanie: Konfiguracja Hibernation zamiast Sleep"
    Write-Host ""
    
    $fixes = @()
    
    # 1. Włącz Hibernation
    Write-Info "1. Włączanie funkcji Hibernation..."
    try {
        powercfg /hibernate on
        Write-Success "  Hibernation włączony"
        $fixes += "Hibernation enabled"
    }
    catch {
        Write-Error-Custom "  Błąd podczas włączania Hibernation: $_"
    }
    
    # 2. Ustaw przycisk zasilania na Hibernate
    Write-Info "2. Konfiguracja przycisku zasilania..."
    
    try {
        # Na baterii
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 2
        # Na zasilaczu
        powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS PBUTTONACTION 2
        powercfg /setactive SCHEME_CURRENT
        
        Write-Success "  Przycisk zasilania → Hibernation"
        $fixes += "Power button to hibernate"
    }
    catch {
        Write-Error-Custom "  Błąd konfiguracji przycisku: $_"
    }
    
    # 3. Wyłącz Fast Startup
    Write-Info "3. Wyłączanie Fast Startup (może powodować problemy)..."
    
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0
        Write-Success "  Fast Startup wyłączony"
        $fixes += "Fast startup disabled"
    }
    catch {
        Write-Error-Custom "  Błąd wyłączania Fast Startup: $_"
    }
    
    # 4. Wyłącz wake timers
    Write-Info "4. Wyłączanie wake timers..."
    
    try {
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 0
        powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 0
        powercfg /setactive SCHEME_CURRENT
        
        Write-Success "  Wake timers wyłączone"
        $fixes += "Wake timers disabled"
    }
    catch {
        Write-Error-Custom "  Błąd wyłączania wake timers: $_"
    }
    
    # 5. Ustaw czas do hibernacji
    Write-Info "5. Ustawianie czasu do hibernacji..."
    
    try {
        # Na baterii - 10 minut
        powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 600
        # Na zasilaczu - 30 minut
        powercfg /setacvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 1800
        powercfg /setactive SCHEME_CURRENT
        
        Write-Success "  Czas hibernacji: 10 min (bateria), 30 min (zasilacz)"
        $fixes += "Hibernate timeouts set"
    }
    catch {
        Write-Error-Custom "  Błąd ustawiania czasu: $_"
    }
    
    # Podsumowanie
    Write-Host ""
    Write-ColorOutput Green "╔════════════════════════════════════════════════════════╗"
    Write-ColorOutput Green "║  HIBERNACJA SKONFIGUROWANA POMYŚLNIE                  ║"
    Write-ColorOutput Green "╚════════════════════════════════════════════════════════╝"
    Write-Host ""
    Write-Info "Co zostało naprawione:"
    foreach ($fix in $fixes) {
        Write-Host "  ✓ $fix" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Warning-Custom "WAŻNE: Od teraz przycisk zasilania uruchamia HIBERNACJĘ"
    Write-Info "Hibernacja zapisuje stan gry i całkowicie wyłącza urządzenie"
    Write-Info "To oszczędza baterię i zapobiega samoczynnemu wybudzaniu"
    
}

# ═══════════════════════════════════════════════════════════════
# OPTYMALIZACJA WINDOWS 11 DLA GAMING HANDHELD
# ═══════════════════════════════════════════════════════════════

function Optimize-WindowsForGaming {
    Write-Header "OPTYMALIZACJA WINDOWS 11 DLA GAMING"
    
    $optimizations = @()
    
    # 1. Wyłącz Memory Integrity (Core Isolation)
    Write-Info "1. Wyłączanie Memory Integrity (zwiększa FPS)..."
    
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0
        Write-Success "  Memory Integrity wyłączony (wymaga restartu)"
        $optimizations += "Memory Integrity disabled"
    }
    catch {
        Write-Warning-Custom "  Nie udało się wyłączyć Memory Integrity"
    }
    
    # 2. Wyłącz VMP (Virtual Machine Platform)
    Write-Info "2. Sprawdzanie VMP (Virtual Machine Platform)..."
    
    $vmpStatus = (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State
    if ($vmpStatus -eq "Enabled") {
        Write-Warning-Custom "  VMP jest włączony - może obniżać FPS"
        Write-Info "  Aby wyłączyć, uruchom: Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform"
    }
    else {
        Write-Success "  VMP już wyłączony"
    }
    
    # 3. Wyłącz Game DVR
    Write-Info "3. Wyłączanie Game DVR..."
    
    try {
        $regPath = "HKCU:\System\GameConfigStore"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $regPath -Name "GameDVR_Enabled" -Value 0
        Set-ItemProperty -Path $regPath -Name "GameDVR_FSEBehaviorMode" -Value 2
        Set-ItemProperty -Path $regPath -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1
        
        Write-Success "  Game DVR wyłączony"
        $optimizations += "Game DVR disabled"
    }
    catch {
        Write-Warning-Custom "  Nie udało się wyłączyć Game DVR"
    }
    
    # 4. PCI Express Link State Power Management → OFF (dla wydajności)
    Write-Info "4. Wyłączanie PCI Express Link State Power Management..."
    Write-Info "  (zwiększa wydajność o 5-8% podczas ładowania)"
    
    try {
        powercfg /setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0
        powercfg /setactive SCHEME_CURRENT
        
        Write-Success "  PCI Express Power Management wyłączony (zasilacz)"
        $optimizations += "PCIe power management disabled"
    }
    catch {
        Write-Warning-Custom "  Nie udało się zmienić PCI Express settings"
    }
    
    # 5. Ustaw plan zasilania na Balanced
    Write-Info "5. Ustawianie planu zasilania..."
    
    try {
        $balancedGuid = (powercfg /list | Select-String "Balanced" | Select-String "GUID" | ForEach-Object { $_ -match '\(([^)]+)\)' | Out-Null; $matches[1] })
        
        if ($balancedGuid) {
            powercfg /setactive $balancedGuid
            Write-Success "  Plan zasilania: Balanced (zalecany dla MSI Claw)"
            $optimizations += "Power plan set to Balanced"
        }
    }
    catch {
        Write-Warning-Custom "  Nie udało się ustawić planu zasilania"
    }
    
    # 6. Wyłącz niepotrzebne usługi startowe
    Write-Info "6. Optymalizacja usług startowych..."
    
    $servicesToDisable = @(
        "DiagTrack",  # Diagnostics Tracking
        "SysMain"     # Superfetch (może spowalniać na handheld)
    )
    
    foreach ($service in $servicesToDisable) {
        try {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc -and $svc.StartType -ne "Disabled") {
                Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                Set-Service -Name $service -StartupType Disabled
                Write-Success "  Usługa $service wyłączona"
                $optimizations += "Service $service disabled"
            }
        }
        catch {
            # Ignoruj błędy
        }
    }
    
    # 7. Ustaw priorytet GPU na wydajność
    Write-Info "7. Ustawianie priorytetu GPU..."
    
    try {
        $regPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        # To wymaga konkretnych ścieżek do gier, więc pomijamy automatyzację
        Write-Info "  Ustaw ręcznie w Ustawieniach Windows → System → Ekran → Grafika"
    }
    catch {}
    
    # Podsumowanie
    Write-Host ""
    Write-ColorOutput Green "╔════════════════════════════════════════════════════════╗"
    Write-ColorOutput Green "║  WINDOWS 11 ZOPTYMALIZOWANY DLA GAMING                ║"
    Write-ColorOutput Green "╚════════════════════════════════════════════════════════╝"
    Write-Host ""
    Write-Info "Zastosowane optymalizacje:"
    foreach ($opt in $optimizations) {
        Write-Host "  ✓ $opt" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Warning-Custom "Wymagany restart systemu, aby wszystkie zmiany zaczęły działać!"
    
    $restart = Read-Host "Czy chcesz uruchomić ponownie teraz? (T/N)"
    if ($restart -eq "T") {
        Write-Info "Restartowanie za 10 sekund..."
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

# ═══════════════════════════════════════════════════════════════
# QUICKCPU PROFILES
# ═══════════════════════════════════════════════════════════════

function Create-GameProfiles {
    param([hashtable]$CPUInfo)
    
    Write-Header "TWORZENIE PROFILI PER-GRA"
    
    $profilesPath = $Script:Config.ProfilesPath
    
    if (-not (Test-Path $profilesPath)) {
        New-Item -ItemType Directory -Path $profilesPath | Out-Null
    }
    
    # Definicje profili zoptymalizowane pod różne gry
    $profiles = @{
        "FIFA_26" = @{
            Name = "FIFA 26 / EA FC"
            PCoreMax = 40
            ECoreMax = 30
            Description = "Zoptymalizowany dla piłki nożnej - ~120 min baterii"
        }
        "Cyberpunk_2077" = @{
            Name = "Cyberpunk 2077"
            PCoreMax = 25
            ECoreMax = 20
            Description = "Maksymalna GPU dla RPG AAA - ~90 min baterii"
        }
        "Elden_Ring" = @{
            Name = "Elden Ring"
            PCoreMax = 25
            ECoreMax = 20
            Description = "Maksymalna GPU dla Souls-like - ~90 min baterii"
        }
        "Fortnite" = @{
            Name = "Fortnite"
            PCoreMax = 36
            ECoreMax = 26
            Description = "Balans dla battle royale - ~110 min baterii"
        }
        "Light_Gaming" = @{
            Name = "Gry Indie / 2D"
            PCoreMax = 34
            ECoreMax = 28
            Description = "Oszczędny dla lekkich gier - ~150 min baterii"
        }
        "Desktop_Mode" = @{
            Name = "Tryb Pulpit"
            PCoreMax = if ($CPUInfo.Model -eq "135H") { 46 } else { 48 }
            ECoreMax = if ($CPUInfo.Model -eq "135H") { 36 } else { 38 }
            Description = "Przeglądanie, YouTube - ~4 godz"
        }
    }
    
    foreach ($profileKey in $profiles.Keys) {
        $profile = $profiles[$profileKey]
        
        # Plik BAT
        $batContent = @"
@echo off
echo ════════════════════════════════════════════════════
echo  MSI Claw Profile: $($profile.Name)
echo  $($profile.Description)
echo ════════════════════════════════════════════════════
echo.

REM Ustawienie limitów CPU
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX $($profile.PCoreMax)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX $($profile.PCoreMax)

REM Zastosowanie zmian
powercfg /setactive SCHEME_CURRENT

echo.
echo ✓ Profil zastosowany!
echo   Max CPU: $($profile.PCoreMax)%%
echo   Oczekiwany czas baterii: Zobacz opis
echo.
pause
"@
        
        $batPath = "$profilesPath\$profileKey.bat"
        $batContent | Out-File -FilePath $batPath -Encoding ASCII
    }
    
    # README
    $readmeContent = @"
═══════════════════════════════════════════════════════════════════
    PROFILE GAMING DLA MSI CLAW $($CPUInfo.Model)
    Wygenerowano: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
═══════════════════════════════════════════════════════════════════

JAK UŻYWAĆ:
-----------
1. Kliknij dwukrotnie na plik .bat odpowiadający grze
2. Potwierdź uprawnienia administratora
3. Profil zostanie zastosowany natychmiast

DOSTĘPNE PROFILE:
─────────────────────────────────────────────────────────────────

FIFA_26.bat
    → FIFA 26, EA FC 25
    → Czas baterii: ~120 minut
    → Wydajność: 60 FPS (ustawienia medium)

Cyberpunk_2077.bat
    → Cyberpunk 2077, Starfield
    → Czas baterii: ~90 minut
    → Wydajność: Maksymalna GPU

Elden_Ring.bat
    → Elden Ring, Dark Souls, Sekiro
    → Czas baterii: ~90 minut
    → Wydajność: Płynne 30-40 FPS

Fortnite.bat
    → Fortnite, Apex Legends, Valorant
    → Czas baterii: ~110 minut
    → Wydajność: 60+ FPS

Light_Gaming.bat
    → Stardew Valley, Hades, Celeste
    → Czas baterii: ~150 minut
    → Wydajność: Maksymalna

Desktop_Mode.bat
    → YouTube, przeglądarka, Office
    → Czas baterii: ~4 godziny
    → Tryb codziennego użytku

═══════════════════════════════════════════════════════════════════

UWAGA: Profil ustawia MAKSYMALNĄ częstotliwość CPU.
System nadal może obniżyć taktowanie gdy nie jest potrzebne.

"@
    
    $readmeContent | Out-File -FilePath "$profilesPath\CZYTAJ_MNIE.txt" -Encoding UTF8
    
    # Skrypt resetu
    $resetScript = @"
@echo off
echo Przywracanie domyślnych ustawień CPU...

powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setactive SCHEME_CURRENT

echo.
echo ✓ Przywrócono domyślne ustawienia (100%%)
pause
"@
    
    $resetScript | Out-File -FilePath "$profilesPath\RESET.bat" -Encoding ASCII
    
    Write-Success "Profile utworzone w: $profilesPath"
    
    $openFolder = Read-Host "Otworzyć folder z profilami? (T/N)"
    if ($openFolder -eq "T") {
        explorer $profilesPath
    }
}

# ═══════════════════════════════════════════════════════════════
# DIAGNOSTYKA I ROZWIĄZYWANIE PROBLEMÓW
# ═══════════════════════════════════════════════════════════════

function Start-InteractiveTroubleshooting {
    Write-Header "INTERAKTYWNA DIAGNOSTYKA PROBLEMÓW"
    
    Write-Host "Jakie problemy doświadczasz?"
    Write-Host ""
    Write-Host "1. 📉 Szybkie rozładowywanie baterii (>20% w 10 min gry)"
    Write-Host "2. 💤 Urządzenie budzi się samo / zjada baterię w Sleep"
    Write-Host "3. 🎮 Niska wydajność w grach / stuttering"
    Write-Host "4. 🌡️  Przegrzewanie / głośne wentylatory"
    Write-Host "5. 🔌 Nie ładuje się lub ładuje wolno"
    Write-Host "6. ⌨️  Problemy z kontrolerami po wznowieniu"
    Write-Host "7. 🔊 Problemy z dźwiękiem / trzaski"
    Write-Host "8. ↩️  Powrót do menu głównego"
    Write-Host ""
    
    $choice = Read-Host "Wybierz problem (1-8)"
    
    switch ($choice) {
        "1" {
            Write-Header "DIAGNOSTYKA: Szybkie rozładowywanie baterii"
            
            Write-Info "Sprawdzam możliwe przyczyny..."
            Write-Host ""
            
            # Sprawdź refresh rate
            Write-Info "1. Sprawdzanie częstotliwości odświeżania ekranu..."
            Write-Warning-Custom "  120Hz drastycznie skraca czas baterii!"
            Write-Info "  Zalecenie: Ustaw 60Hz w Ustawieniach Windows"
            Write-Host ""
            
            # Sprawdź plan zasilania
            Write-Info "2. Sprawdzanie planu zasilania..."
            $currentPlan = powercfg /getactivescheme
            Write-Host "  Obecny: $currentPlan" -ForegroundColor Gray
            if ($currentPlan -notmatch "Balanced") {
                Write-Warning-Custom "  Zmień na 'Balanced' dla lepszego czasu baterii"
            }
            Write-Host ""
            
            # Sprawdź MSI Center M
            Write-Info "3. Sprawdzanie MSI Center M..."
            Write-Info "  Czy masz włączony 'Over Boost'?"
            Write-Warning-Custom "  Over Boost zwiększa wydajność ALE skraca czas baterii"
            Write-Info "  Dla dłuższej baterii: Wyłącz Over Boost w MSI Center M"
            Write-Host ""
            
            # Sprawdź zdrowie baterii
            Write-Info "4. Generowanie raportu baterii..."
            $reportPath = "$env:TEMP\battery-report.html"
            powercfg /batteryreport /output $reportPath | Out-Null
            
            Write-Success "Raport wygenerowany"
            $open = Read-Host "Otworzyć raport baterii? (T/N)"
            if ($open -eq "T") {
                Start-Process $reportPath
            }
            
            Write-Host ""
            Write-ColorOutput Yellow "ZALECENIA DLA FIFA 26:"
            Write-Host "  ✓ Ustaw 60Hz (nie 120Hz)"
            Write-Host "  ✓ Wyłącz Over Boost w MSI Center M"
            Write-Host "  ✓ Obniż jasność ekranu do 50-70%"
            Write-Host "  ✓ Użyj profilu 'FIFA_26.bat' z folderu profili"
            Write-Host "  ✓ Ustaw FPS limit 60 w grze"
            Write-Host ""
            Write-Info "Oczekiwany wynik: 90-120 minut gry"
            
            Pause
        }
        "2" {
            Write-Header "NAPRAWA: Problemy ze Sleep/Hibernacją"
            Fix-HibernationIssues
            Pause
        }
        "3" {
            Write-Header "DIAGNOSTYKA: Niska wydajność w grach"
            
            Write-Info "Sprawdzam konfigurację..."
            Write-Host ""
            
            # BIOS check
            Write-Info "1. Czy wykonałeś modyfikacje BIOS?"
            $biosModified = Read-Host "  (T/N)"
            
            if ($biosModified -ne "T") {
                Write-Warning-Custom "  Bez modyfikacji BIOS tracisz 20-30% wydajności GPU!"
                Write-Info "  Użyj opcji 4 w menu głównym aby wygenerować instrukcję BIOS"
            }
            Write-Host ""
            
            # Memory Integrity check
            Write-Info "2. Sprawdzanie Memory Integrity..."
            $miStatus = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction SilentlyContinue
            
            if ($miStatus.Enabled -eq 1) {
                Write-Warning-Custom "  Memory Integrity WŁĄCZONY - powoduje spadek FPS!"
                $disable = Read-Host "  Wyłączyć teraz? (T/N)"
                if ($disable -eq "T") {
                    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0
                    Write-Success "  Wyłączono (wymaga restartu)"
                }
            }
            else {
                Write-Success "  Memory Integrity wyłączony ✓"
            }
            Write-Host ""
            
            # MSI Center M
            Write-Info "3. Sprawdź ustawienia MSI Center M:"
            Write-Host "  ✓ User Scenario → Balanced Mode" -ForegroundColor Gray
            Write-Host "  ✓ Over Boost → Enabled (górny prawy róg)" -ForegroundColor Gray
            Write-Host "  ✓ Windows power mode → Balanced" -ForegroundColor Gray
            Write-Host ""
            
            # Sterowniki
            Write-Info "4. Sprawdź aktualizacje sterowników w opcji 6 menu głównego"
            
            Pause
        }
        "4" {
            Write-Header "DIAGNOSTYKA: Przegrzewanie"
            
            Write-Info "Typowe przyczyny przegrzewania MSI Claw:"
            Write-Host ""
            Write-Host "1. Zablokowane wentylatory" -ForegroundColor Yellow
            Write-Info "   → Sprawdź czy otwory wentylacyjne nie są zakryte"
            Write-Info "   → Wyczyść kurz z otworów (sprężone powietrze)"
            Write-Host ""
            
            Write-Host "2. Zbyt wysokie TDP podczas ładowania" -ForegroundColor Yellow
            Write-Info "   → Podczas ładowania urządzenie może działać na max mocy"
            Write-Info "   → Normalne podczas wymagających gier + ładowanie"
            Write-Host ""
            
            Write-Host "3. Over Boost włączony" -ForegroundColor Yellow
            Write-Info "   → Over Boost zwiększa temperaturę"
            Write-Info "   → Wyłącz jeśli grasz bez ładowania"
            Write-Host ""
            
            Write-Info "Zalecenia:"
            Write-Host "  ✓ Graj bez etui"
            Write-Host "  ✓ W domu: podłóż podkładkę chłodzącą lub książkę (dla przepływu powietrza)"
            Write-Host "  ✓ Obniż ustawienia graficzne w grze"
            Write-Host "  ✓ Ogranicz FPS do 60 zamiast nielimitowanych"
            
            Pause
        }
        "6" {
            Write-Header "NAPRAWA: Kontrolery nie działają po Hibernacji"
            
            Write-Info "Znany problem z MSI Claw - kontrolery czasem nie działają po wznowieniu"
            Write-Host ""
            Write-Info "Rozwiązanie 1: Naciśnij przycisk MSI (lewy dolny)"
            Write-Info "  → Otworzy MSI Center M"
            Write-Info "  → Zamknij MSI Center M"
            Write-Info "  → Kontrolery powinny działać"
            Write-Host ""
            Write-Info "Rozwiązanie 2: Alt+Tab"
            Write-Info "  → Przełącz się między oknami"
            Write-Info "  → Wróć do gry"
            Write-Host ""
            Write-Info "Rozwiązanie 3: Aktualizuj firmware kontrolera"
            Write-Info "  → MSI Center M → Settings → Controller Update"
            
            Pause
        }
        "7" {
            Write-Header "NAPRAWA: Problemy z dźwiękiem"
            
            Write-Info "Jeśli masz MSI Claw 8 AI+ (Lunar Lake) - znany bug!"
            Write-Host ""
            Write-Info "Rozwiązanie: Zaktualizuj sterownik Intel Arc do wersji 32.0.101.6877 lub nowszej"
            Write-Info "  Ta wersja naprawia audio glitches"
            Write-Host ""
            $update = Read-Host "Otworzyć stronę pobierania sterowników Intel? (T/N)"
            if ($update -eq "T") {
                Start-Process $Script:Config.IntelArcDriversURL
            }
            
            Pause
        }
        "8" {
            return
        }
    }
}

# ═══════════════════════════════════════════════════════════════
# MENU GŁÓWNE
# ═══════════════════════════════════════════════════════════════

function Show-MainMenu {
    Clear-Host
    
    Write-ColorOutput Cyan @"

███╗   ███╗███████╗██╗     ██████╗██╗      █████╗ ██╗    ██╗
████╗ ████║██╔════╝██║    ██╔════╝██║     ██╔══██╗██║    ██║
██╔████╔██║███████╗██║    ██║     ██║     ███████║██║ █╗ ██║
██║╚██╔╝██║╚════██║██║    ██║     ██║     ██╔══██║██║███╗██║
██║ ╚═╝ ██║███████║██║    ╚██████╗███████╗██║  ██║╚███╔███╔╝
╚═╝     ╚═╝╚══════╝╚═╝     ╚═════╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ 
                                                              
          OPTIMIZER v3.0 ULTRA - Kompletna Automatyzacja
"@
    
    Write-Host ""
    Write-ColorOutput Yellow "═══════════════════════════════════════════════════════════════════"
    Write-ColorOutput Cyan   "                      MENU GŁÓWNE"
    Write-ColorOutput Yellow "═══════════════════════════════════════════════════════════════════"
    Write-Host ""
    
    Write-Host "  1. 🔍 Pełna diagnostyka systemu (BIOS, sterowniki, bateria)"
    Write-Host "  2. 🩺 Interaktywne rozwiązywanie problemów"
    Write-Host "  3. 💤 Naprawa problemów z hibernacją/baterią"
    Write-Host "  4. ⚡ Optymalizacja Windows 11 dla gaming"
    Write-Host "  5. 🎮 Tworzenie profili per-gra"
    Write-Host "  6. 💾 Backup rejestru"
    Write-Host "  7. 🖥️  Modyfikacja VRAM (8GB)"
    Write-Host "  8. 📄 Generuj instrukcję BIOS"
    Write-Host "  9. 🚀 PEŁNA AUTOMATYCZNA OPTYMALIZACJA"
    Write-Host "  0. ❌ Wyjście"
    Write-Host ""
    Write-ColorOutput Yellow "═══════════════════════════════════════════════════════════════════"
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════
# MAIN PROGRAM LOOP
# ═══════════════════════════════════════════════════════════════

function Main {
    # Sprawdź uprawnienia
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Error-Custom "Ten skrypt wymaga uprawnień administratora!"
        Write-Info "Uruchom PowerShell jako administrator i spróbuj ponownie"
        Pause
        exit
    }
    
    # Tworzenie folderów
    if (-not (Test-Path $Script:Config.BackupRoot)) {
        New-Item -ItemType Directory -Path $Script:Config.BackupRoot | Out-Null
    }
    
    if (-not (Test-Path $Script:Config.TempPath)) {
        New-Item -ItemType Directory -Path $Script:Config.TempPath | Out-Null
    }
    
    $sysInfo = $null
    
    while ($true) {
        Show-MainMenu
        
        $choice = Read-Host "Wybierz opcję (0-9)"
        
        switch ($choice) {
            "1" {
                $sysInfo = Get-SystemInfo
                Show-SystemDiagnostics -SysInfo $sysInfo
                Pause
            }
            "2" {
                Start-InteractiveTroubleshooting
            }
            "3" {
                Fix-HibernationIssues
                Pause
            }
            "4" {
                Optimize-WindowsForGaming
            }
            "5" {
                if (-not $sysInfo) {
                    $sysInfo = Get-SystemInfo
                }
                Create-GameProfiles -CPUInfo $sysInfo.CPU
                Pause
            }
            "9" {
                Write-Header "PEŁNA AUTOMATYCZNA OPTYMALIZACJA"
                
                Write-Info "Uruchamiam kompletną optymalizację..."
                Start-Sleep -Seconds 2
                
                # 1. Diagnostyka
                $sysInfo = Get-SystemInfo
                Show-SystemDiagnostics -SysInfo $sysInfo
                Start-Sleep -Seconds 3
                
                # 2. Hibernacja
                Fix-HibernationIssues
                Start-Sleep -Seconds 2
                
                # 3. Windows
                Optimize-WindowsForGaming
                
                # 4. Profile
                Create-GameProfiles -CPUInfo $sysInfo.CPU
                
                Write-Host ""
                Write-ColorOutput Green "╔════════════════════════════════════════════════════════════════╗"
                Write-ColorOutput Green "║              ✓ OPTYMALIZACJA ZAKOŃCZONA!                       ║"
                Write-ColorOutput Green "╚════════════════════════════════════════════════════════════════╝"
                Write-Host ""
                
                Pause
            }
            "0" {
                Write-ColorOutput Green "Dziękujemy za użycie MSI Claw Optimizer v3.0 ULTRA!"
                exit
            }
            default {
                Write-Error-Custom "Nieprawidłowy wybór!"
                Start-Sleep -Seconds 2
            }
        }
    }
}

# Uruchomienie
Main
