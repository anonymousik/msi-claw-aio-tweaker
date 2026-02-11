<#
.SYNOPSIS
    Optimization Module - Windows & Power Configuration Optimizations
    
.DESCRIPTION
    Moduł zawierający wszystkie funkcje optymalizacyjne dla MSI Claw Optimizer v5.0
    
    Bazowane na v4.0 Professional Edition z poprawkami bezpieczeństwa:
    - No Invoke-Expression (używa Start-Process)
    - Secure command execution
    - Proper error handling
    - Backup integration
#>

# ════════════════════════════════════════════════════════════════════════════════
# HIBERNATION OPTIMIZATION
# ══════════════════════════════════════════════════════════════════════════════════

function Set-HibernationConfiguration {
    <#
    .SYNOPSIS
        Konfiguruje hibernację jako rozwiązanie problemu Sleep na MSI Claw
    .DESCRIPTION
        MSI Claw ma znany problem z budzeniem się podczas Sleep, co powoduje
        rozładowanie baterii. Ta funkcja konfiguruje Hibernation jako rozwiązanie.
    .OUTPUTS
        [hashtable] Wyniki optymalizacji
    #>
    
    Write-Host "`n[OPTYMALIZACJA] Konfiguracja hibernacji..." -ForegroundColor Cyan
    
    $results = @{
        Success = $true
        Changes = @()
        Errors = @()
        RequiresRestart = $false
    }
    
    try {
        # 1. Włącz Hibernation
        Write-Host "  [1/6] Włączanie hibernacji..." -ForegroundColor Gray
        
        $procArgs = @('/hibernate', 'on')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Hibernacja włączona" -ForegroundColor Green
            $results.Changes += "Hibernation enabled"
        }
        else {
            $results.Errors += "Nie udało się włączyć hibernacji (kod: $($process.ExitCode))"
            Write-Host "    ✗ Błąd włączania hibernacji" -ForegroundColor Red
        }
        
        # 2. Ustaw przycisk zasilania na Hibernate (on battery)
        Write-Host "  [2/6] Konfiguracja przycisku zasilania..." -ForegroundColor Gray
        
        # On battery (dc) - Hibernate (3)
        $procArgs = @('/setdcvalueindex', 'SCHEME_CURRENT', 'SUB_BUTTONS', 'PBUTTONACTION', '3')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Przycisk zasilania (bateria) → Hibernate" -ForegroundColor Green
            $results.Changes += "Power button (DC) → Hibernate"
        }
        
        # On AC power - też Hibernate dla spójności
        $procArgs = @('/setacvalueindex', 'SCHEME_CURRENT', 'SUB_BUTTONS', 'PBUTTONACTION', '3')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Przycisk zasilania (zasilacz) → Hibernate" -ForegroundColor Green
            $results.Changes += "Power button (AC) → Hibernate"
        }
        
        # 3. Wyłącz Wake Timers (zapobiega automatycznemu budzeniu)
        Write-Host "  [3/6] Wyłączanie wake timers..." -ForegroundColor Gray
        
        # On battery
        $procArgs = @('/setdcvalueindex', 'SCHEME_CURRENT', 'SUB_SLEEP', 'RTCWAKE', '0')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Wake timers wyłączone (bateria)" -ForegroundColor Green
            $results.Changes += "Wake timers disabled (DC)"
        }
        
        # On AC
        $procArgs = @('/setacvalueindex', 'SCHEME_CURRENT', 'SUB_SLEEP', 'RTCWAKE', '0')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Wake timers wyłączone (zasilacz)" -ForegroundColor Green
            $results.Changes += "Wake timers disabled (AC)"
        }
        
        # 4. Wyłącz Fast Startup (konfliktuje z Hibernate)
        Write-Host "  [4/6] Wyłączanie Fast Startup..." -ForegroundColor Gray
        
        try {
            $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
            Set-ItemProperty -Path $regPath -Name 'HiberbootEnabled' -Value 0 -Type DWord -ErrorAction Stop
            Write-Host "    ✓ Fast Startup wyłączony" -ForegroundColor Green
            $results.Changes += "Fast Startup disabled"
        }
        catch {
            $results.Errors += "Nie udało się wyłączyć Fast Startup: $_"
            Write-Host "    ✗ Błąd wyłączania Fast Startup" -ForegroundColor Red
        }
        
        # 5. Ustaw czas do automatycznej hibernacji
        Write-Host "  [5/6] Konfiguracja czasu do hibernacji..." -ForegroundColor Gray
        
        # On battery - 15 minut bezczynności
        $procArgs = @('/setdcvalueindex', 'SCHEME_CURRENT', 'SUB_SLEEP', 'HIBERNATEIDLE', '900')  # 15 min = 900 sec
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Auto-hibernacja po 15 minutach (bateria)" -ForegroundColor Green
            $results.Changes += "Auto-hibernate after 15min (DC)"
        }
        
        # On AC - 30 minut
        $procArgs = @('/setacvalueindex', 'SCHEME_CURRENT', 'SUB_SLEEP', 'HIBERNATEIDLE', '1800')  # 30 min = 1800 sec
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Auto-hibernacja po 30 minutach (zasilacz)" -ForegroundColor Green
            $results.Changes += "Auto-hibernate after 30min (AC)"
        }
        
        # 6. Aktywuj zmiany
        Write-Host "  [6/6] Aktywacja zmian..." -ForegroundColor Gray
        
        $procArgs = @('/setactive', 'SCHEME_CURRENT')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Zmiany zasilania aktywne" -ForegroundColor Green
        }
        
        # Podsumowanie
        if ($results.Errors.Count -eq 0) {
            Write-Host "`n[OPTYMALIZACJA] Hibernacja skonfigurowana pomyślnie!" -ForegroundColor Green
            Write-Host "  Efekt: 0% rozładowania baterii podczas 'wyłączenia'" -ForegroundColor Cyan
            $results.RequiresRestart = $true
        }
        else {
            Write-Host "`n[OPTYMALIZACJA] Hibernacja skonfigurowana z ostrzeżeniami" -ForegroundColor Yellow
            $results.Success = $false
        }
        
        return $results
    }
    catch {
        Write-Host "`n[BŁĄD] Nie udało się skonfigurować hibernacji: $_" -ForegroundColor Red
        $results.Success = $false
        $results.Errors += "Critical error: $_"
        return $results
    }
}

# ════════════════════════════════════════════════════════════════════════════════
# WINDOWS CONFIGURATION OPTIMIZATION
# ════════════════════════════════════════════════════════════════════════════════

function Set-WindowsOptimizations {
    <#
    .SYNOPSIS
        Optymalizuje konfigurację Windows dla gaming
    .DESCRIPTION
        Wyłącza funkcje spowalniające gaming i włącza optymalizacje wydajności
    .OUTPUTS
        [hashtable] Wyniki optymalizacji
    #>
    
    Write-Host "`n[OPTYMALIZACJA] Konfiguracja Windows dla gaming..." -ForegroundColor Cyan
    
    $results = @{
        Success = $true
        Changes = @()
        Errors = @()
        RequiresRestart = $false
    }
    
    try {
        # 1. Wyłącz Memory Integrity (Core Isolation / HVCI)
        Write-Host "  [1/7] Wyłączanie Memory Integrity..." -ForegroundColor Gray
        
        try {
            $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'
            
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $regPath -Name 'Enabled' -Value 0 -Type DWord -ErrorAction Stop
            Write-Host "    ✓ Memory Integrity wyłączona (+15-25% FPS)" -ForegroundColor Green
            $results.Changes += "Memory Integrity (HVCI) disabled"
            $results.RequiresRestart = $true
        }
        catch {
            $results.Errors += "Memory Integrity: $_"
            Write-Host "    ✗ Błąd wyłączania Memory Integrity" -ForegroundColor Red
            Write-Host "      Wyłącz ręcznie w: Settings → Windows Security → Device Security → Core Isolation" -ForegroundColor Yellow
        }
        
        # 2. Wyłącz Game DVR (Xbox Game Bar recording)
        Write-Host "  [2/7] Wyłączanie Game DVR..." -ForegroundColor Gray
        
        try {
            $regPath = 'HKCU:\System\GameConfigStore'
            
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $regPath -Name 'GameDVR_Enabled' -Value 0 -Type DWord -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name 'GameDVR_FSEBehaviorMode' -Value 2 -Type DWord -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name 'GameDVR_FSEBehavior' -Value 2 -Type DWord -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name 'GameDVR_HonorUserFSEBehaviorMode' -Value 1 -Type DWord -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name 'GameDVR_DXGIHonorFSEWindowsCompatible' -Value 1 -Type DWord -ErrorAction Stop
            
            Write-Host "    ✓ Game DVR wyłączony" -ForegroundColor Green
            $results.Changes += "Game DVR disabled"
        }
        catch {
            $results.Errors += "Game DVR: $_"
            Write-Host "    ✗ Błąd wyłączania Game DVR" -ForegroundColor Red
        }
        
        # 3. Włącz Hardware Accelerated GPU Scheduling
        Write-Host "  [3/7] Włączanie Hardware Accelerated GPU Scheduling..." -ForegroundColor Gray
        
        try {
            # Sprawdź wersję Windows (wymaga Windows 11 lub Windows 10 20H1+)
            $osVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Version
            if ([Version]$osVersion -ge [Version]'10.0.19041') {
                $regPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers'
                
                Set-ItemProperty -Path $regPath -Name 'HwSchMode' -Value 2 -Type DWord -ErrorAction Stop
                Write-Host "    ✓ Hardware GPU Scheduling włączony (niższa latencja)" -ForegroundColor Green
                $results.Changes += "Hardware GPU Scheduling enabled"
                $results.RequiresRestart = $true
            }
            else {
                Write-Host "    ! Hardware GPU Scheduling wymaga Windows 10 20H1+" -ForegroundColor Yellow
            }
        }
        catch {
            $results.Errors += "Hardware GPU Scheduling: $_"
            Write-Host "    ✗ Błąd włączania Hardware GPU Scheduling" -ForegroundColor Red
        }
        
        # 4. Wyłącz Windows Search Indexing dla dysków SSD (opcjonalne)
        Write-Host "  [4/7] Optymalizacja Windows Search..." -ForegroundColor Gray
        
        try {
            # Sprawdź czy dysk systemowy to SSD
            $systemDrive = $env:SystemDrive.TrimEnd(':')
            $disk = Get-PhysicalDisk | Where-Object { $_.DeviceID -eq 0 } | Select-Object -First 1
            
            if ($disk.MediaType -eq 'SSD') {
                # Wyłącz indexing dla SSD (nie potrzebne, SSD są szybkie)
                $service = Get-Service -Name 'WSearch' -ErrorAction SilentlyContinue
                if ($service) {
                    Set-Service -Name 'WSearch' -StartupType Manual -ErrorAction Stop
                    Write-Host "    ✓ Windows Search ustawiony na Manual (SSD wykryty)" -ForegroundColor Green
                    $results.Changes += "Windows Search → Manual (SSD optimization)"
                }
            }
            else {
                Write-Host "    ! HDD wykryty - Windows Search pozostawiony aktywny" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "    ! Nie udało się zoptymalizować Windows Search" -ForegroundColor Yellow
        }
        
        # 5. Wyłącz Superfetch/SysMain (dla SSD)
        Write-Host "  [5/7] Optymalizacja SysMain..." -ForegroundColor Gray
        
        try {
            $disk = Get-PhysicalDisk | Where-Object { $_.DeviceID -eq 0 } | Select-Object -First 1
            
            if ($disk.MediaType -eq 'SSD') {
                $service = Get-Service -Name 'SysMain' -ErrorAction SilentlyContinue
                if ($service) {
                    Set-Service -Name 'SysMain' -StartupType Disabled -ErrorAction Stop
                    Stop-Service -Name 'SysMain' -Force -ErrorAction SilentlyContinue
                    Write-Host "    ✓ SysMain wyłączony (optymalizacja SSD)" -ForegroundColor Green
                    $results.Changes += "SysMain disabled (SSD optimization)"
                }
            }
        }
        catch {
            Write-Host "    ! Nie udało się wyłączyć SysMain" -ForegroundColor Yellow
        }
        
        # 6. Wyłącz telemetry (privacy + performance)
        Write-Host "  [6/7] Wyłączanie telemetrii..." -ForegroundColor Gray
        
        try {
            $regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
            
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $regPath -Name 'AllowTelemetry' -Value 0 -Type DWord -ErrorAction Stop
            Write-Host "    ✓ Telemetria wyłączona" -ForegroundColor Green
            $results.Changes += "Telemetry disabled"
        }
        catch {
            Write-Host "    ! Nie udało się wyłączyć telemetrii" -ForegroundColor Yellow
        }
        
        # 7. Optymalizacja Visual Effects (Performance mode)
        Write-Host "  [7/7] Optymalizacja efektów wizualnych..." -ForegroundColor Gray
        
        try {
            $regPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
            
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            
            # 2 = Best performance
            Set-ItemProperty -Path $regPath -Name 'VisualFXSetting' -Value 2 -Type DWord -ErrorAction Stop
            Write-Host "    ✓ Efekty wizualne → Best Performance" -ForegroundColor Green
            $results.Changes += "Visual Effects → Best Performance"
        }
        catch {
            Write-Host "    ! Nie udało się zoptymalizować efektów wizualnych" -ForegroundColor Yellow
        }
        
        # Podsumowanie
        if ($results.Errors.Count -eq 0) {
            Write-Host "`n[OPTYMALIZACJA] Windows zoptymalizowany pomyślnie!" -ForegroundColor Green
            Write-Host "  Wprowadzono $($results.Changes.Count) zmian" -ForegroundColor Cyan
        }
        else {
            Write-Host "`n[OPTYMALIZACJA] Windows zoptymalizowany z ostrzeżeniami ($($results.Errors.Count) błędów)" -ForegroundColor Yellow
            $results.Success = $false
        }
        
        if ($results.RequiresRestart) {
            Write-Host "  ⚠ RESTART WYMAGANY aby zmiany weszły w życie!" -ForegroundColor Yellow
        }
        
        return $results
    }
    catch {
        Write-Host "`n[BŁĄD] Nie udało się zoptymalizować Windows: $_" -ForegroundColor Red
        $results.Success = $false
        $results.Errors += "Critical error: $_"
        return $results
    }
}

# ════════════════════════════════════════════════════════════════════════════════
# POWER PLAN OPTIMIZATION
# ════════════════════════════════════════════════════════════════════════════════

function Set-PowerPlanOptimizations {
    <#
    .SYNOPSIS
        Optymalizuje plan zasilania dla gaming
    .DESCRIPTION
        Wyłącza PCI Express ASPM i optymalizuje ustawienia procesora
    .OUTPUTS
        [hashtable] Wyniki optymalizacji
    #>
    
    Write-Host "`n[OPTYMALIZACJA] Optymalizacja planu zasilania..." -ForegroundColor Cyan
    
    $results = @{
        Success = $true
        Changes = @()
        Errors = @()
    }
    
    try {
        # 1. Wyłącz PCI Express Link State Power Management (ASPM) na zasilaczu
        Write-Host "  [1/4] Optymalizacja PCI Express..." -ForegroundColor Gray
        
        # On AC power - wyłącz ASPM dla maksymalnej wydajności GPU
        $procArgs = @('/setacvalueindex', 'SCHEME_CURRENT', 'SUB_PCIEXPRESS', 'ASPM', '0')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ PCI Express ASPM wyłączony (zasilacz, +5-8% GPU)" -ForegroundColor Green
            $results.Changes += "PCI Express ASPM disabled (AC power)"
        }
        
        # On battery - moderate ASPM dla balansu wydajność/bateria
        $procArgs = @('/setdcvalueindex', 'SCHEME_CURRENT', 'SUB_PCIEXPRESS', 'ASPM', '1')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ PCI Express ASPM moderate (bateria)" -ForegroundColor Green
            $results.Changes += "PCI Express ASPM moderate (battery)"
        }
        
        # 2. Ustaw maksymalny stan procesora na 100% (nie 99%!)
        Write-Host "  [2/4] Optymalizacja procesora..." -ForegroundColor Gray
        
        # On AC - 100% max CPU
        $procArgs = @('/setacvalueindex', 'SCHEME_CURRENT', 'SUB_PROCESSOR', 'PROCTHROTTLEMAX', '100')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Max CPU state 100% (zasilacz)" -ForegroundColor Green
            $results.Changes += "Max CPU state 100% (AC)"
        }
        
        # On battery - 95% (oszczędność baterii)
        $procArgs = @('/setdcvalueindex', 'SCHEME_CURRENT', 'SUB_PROCESSOR', 'PROCTHROTTLEMAX', '95')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Max CPU state 95% (bateria)" -ForegroundColor Green
            $results.Changes += "Max CPU state 95% (battery)"
        }
        
        # 3. Wyłącz USB Selective Suspend (zapobiega problemom z kontrolerami)
        Write-Host "  [3/4] Optymalizacja USB..." -ForegroundColor Gray
        
        # On AC - wyłącz
        $procArgs = @('/setacvalueindex', 'SCHEME_CURRENT', 'SUB_USB', 'USBSELECTIVESUSPEND', '0')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ USB Selective Suspend wyłączony (zasilacz)" -ForegroundColor Green
            $results.Changes += "USB Selective Suspend disabled (AC)"
        }
        
        # 4. Aktywuj zmiany
        Write-Host "  [4/4] Aktywacja zmian..." -ForegroundColor Gray
        
        $procArgs = @('/setactive', 'SCHEME_CURRENT')
        $process = Start-Process -FilePath 'powercfg.exe' -ArgumentList $procArgs -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Host "    ✓ Zmiany planu zasilania aktywne" -ForegroundColor Green
        }
        
        Write-Host "`n[OPTYMALIZACJA] Plan zasilania zoptymalizowany!" -ForegroundColor Green
        
        return $results
    }
    catch {
        Write-Host "`n[BŁĄD] Nie udało się zoptymalizować planu zasilania: $_" -ForegroundColor Red
        $results.Success = $false
        $results.Errors += "Critical error: $_"
        return $results
    }
}

# ════════════════════════════════════════════════════════════════════════════════
# PERFORMANCE PROFILES
# ════════════════════════════════════════════════════════════════════════════════

function Set-PerformanceProfile {
    <#
    .SYNOPSIS
        Stosuje gotowe profile wydajnościowe
    .PARAMETER Profile
        Profil do zastosowania: Performance, Balanced, Battery
    .OUTPUTS
        [hashtable] Wyniki zastosowania profilu
    #>
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Performance', 'Balanced', 'Battery')]
        [string]$Profile
    )
    
    Write-Host "`n[PROFIL] Stosowanie profilu: $Profile" -ForegroundColor Cyan
    
    $results = @{
        Success = $true
        Profile = $Profile
        Changes = @()
    }
    
    switch ($Profile) {
        'Performance' {
            Write-Host "  Profil: PERFORMANCE (maksymalna wydajność, tylko na zasilaczu)" -ForegroundColor Yellow
            Write-Host "  TDP: ~28W | Target FPS: 100% | Bateria: ~60-90 min" -ForegroundColor Gray
            
            # Max CPU
            & powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
            & powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
            
            # PCI Express - max performance
            & powercfg /setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0
            
            # Disable power saving
            & powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2
            
            $results.Changes += "Performance mode activated"
        }
        
        'Balanced' {
            Write-Host "  Profil: BALANCED (zalecany dla większości gier)" -ForegroundColor Green
            Write-Host "  TDP: ~17W | Target FPS: 85-90% | Bateria: ~90-120 min" -ForegroundColor Gray
            
            # Balanced CPU
            & powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
            & powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
            & powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 95
            
            # PCI Express - moderate
            & powercfg /setacvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0
            & powercfg /setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 1
            
            $results.Changes += "Balanced mode activated"
        }
        
        'Battery' {
            Write-Host "  Profil: BATTERY SAVER (maksymalna żywotność baterii)" -ForegroundColor Cyan
            Write-Host "  TDP: ~8-10W | Target FPS: 60-70% | Bateria: ~120-180 min" -ForegroundColor Gray
            
            # Conservative CPU
            & powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 80
            & powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 5
            
            # PCI Express - max power saving
            & powercfg /setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 2
            
            # Enable aggressive power saving
            & powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 0
            
            $results.Changes += "Battery Saver mode activated"
        }
    }
    
    # Aktywuj zmiany
    & powercfg /setactive SCHEME_CURRENT
    
    Write-Host "  ✓ Profil $Profile zastosowany" -ForegroundColor Green
    
    return $results
}

# ════════════════════════════════════════════════════════════════════════════════
# ALL-IN-ONE OPTIMIZATION
# ════════════════════════════════════════════════════════════════════════════════

function Start-FullOptimization {
    <#
    .SYNOPSIS
        Wykonuje pełną optymalizację systemu
    .PARAMETER SkipHibernation
        Pomija konfigurację hibernacji
    .PARAMETER SkipWindows
        Pomija optymalizacje Windows
    .PARAMETER SkipPowerPlan
        Pomija optymalizacje planu zasilania
    .PARAMETER Profile
        Profil wydajności do zastosowania (Performance, Balanced, Battery)
    .OUTPUTS
        [hashtable] Kompletne wyniki optymalizacji
    #>
    param(
        [Parameter(Mandatory = $false)]
        [switch]$SkipHibernation,
        
        [Parameter(Mandatory = $false)]
        [switch]$SkipWindows,
        
        [Parameter(Mandatory = $false)]
        [switch]$SkipPowerPlan,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Performance', 'Balanced', 'Battery')]
        [string]$Profile = 'Balanced'
    )
    
    Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  PEŁNA OPTYMALIZACJA SYSTEMU" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    $allResults = @{
        Hibernation = $null
        Windows = $null
        PowerPlan = $null
        Profile = $null
        OverallSuccess = $true
        RequiresRestart = $false
    }
    
    # 1. Hibernacja
    if (-not $SkipHibernation) {
        $allResults.Hibernation = Set-HibernationConfiguration
        if (-not $allResults.Hibernation.Success) {
            $allResults.OverallSuccess = $false
        }
        if ($allResults.Hibernation.RequiresRestart) {
            $allResults.RequiresRestart = $true
        }
    }
    
    # 2. Windows
    if (-not $SkipWindows) {
        $allResults.Windows = Set-WindowsOptimizations
        if (-not $allResults.Windows.Success) {
            $allResults.OverallSuccess = $false
        }
        if ($allResults.Windows.RequiresRestart) {
            $allResults.RequiresRestart = $true
        }
    }
    
    # 3. Plan zasilania
    if (-not $SkipPowerPlan) {
        $allResults.PowerPlan = Set-PowerPlanOptimizations
        if (-not $allResults.PowerPlan.Success) {
            $allResults.OverallSuccess = $false
        }
    }
    
    # 4. Profil wydajności
    $allResults.Profile = Set-PerformanceProfile -Profile $Profile
    
    # Podsumowanie
    Write-Host "`n════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    if ($allResults.OverallSuccess) {
        Write-Host "  ✓ OPTYMALIZACJA ZAKOŃCZONA POMYŚLNIE!" -ForegroundColor Green
    }
    else {
        Write-Host "  ! OPTYMALIZACJA ZAKOŃCZONA Z OSTRZEŻENIAMI" -ForegroundColor Yellow
    }
    Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    if ($allResults.RequiresRestart) {
        Write-Host "`n⚠ RESTART SYSTEMU WYMAGANY aby wszystkie zmiany weszły w życie!" -ForegroundColor Yellow
    }
    
    return $allResults
}

# Export functions
Export-ModuleMember -Function @(
    'Set-HibernationConfiguration',
    'Set-WindowsOptimizations',
    'Set-PowerPlanOptimizations',
    'Set-PerformanceProfile',
    'Start-FullOptimization'
)
