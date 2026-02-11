#Requires -RunAsAdministrator
#Requires -Version 5.1

<#
.SYNOPSIS
    MSI Claw Optimizer v4.0 PROFESSIONAL EDITION - FINAL CONSOLIDATED

.DESCRIPTION
    Profesjonalny framework do kompleksowej optymalizacji MSI Claw Handheld Gaming PC.
    
    GŁÓWNE FUNKCJONALNOŚCI:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ✓ Automatyczna diagnostyka sprzętu (CPU, GPU, BIOS, bateria, RAM)
    ✓ System Restore Point przed krytycznymi zmianami
    ✓ Inteligentne pobieranie i instalacja aktualizacji sterowników
    ✓ Zaawansowana naprawa problemów z baterią i hibernacją
    ✓ Profile wydajnościowe per-gra z auto-aplikacją
    ✓ Kompleksowa optymalizacja Windows 11 dla gaming
    ✓ Interaktywny troubleshooting z bazą wiedzy
    ✓ System automatycznych backupów rejestru i konfiguracji
    ✓ Rollback do poprzednich konfiguracji
    ✓ Szczegółowe logowanie wszystkich operacji

.NOTES
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Nazwa pliku:      MSI_Claw_Optimizer_v4_FINAL_CONSOLIDATED.ps1
    Wersja:           4.0.0 Final
    Autor:            Nieznany Nikomu Anonymousik
    Patron:           SecFERRO DIVISION
    Data utworzenia:  2026-02-08
    Ostatnia zmiana:  2026-02-08
    Wymaga:           PowerShell 5.1+, Windows 10/11, Uprawnienia administratora
    Licencja:         Educational Use Only
    
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    OSTRZEŻENIA BEZPIECZEŃSTWA:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ⚠ Ten skrypt modyfikuje krytyczne ustawienia systemowe Windows
    ⚠ Przed uruchomieniem utworzy punkt przywracania systemu
    ⚠ Zalecane utworzenie pełnej kopii zapasowej systemu
    ⚠ Użycie wyłącznie na własne ryzyko
    ⚠ Autor nie ponosi odpowiedzialności za ewentualne szkody
    
.LINK
    https://github.com/SecFERRO/MSI-Claw-Optimizer

#>

[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('Interactive', 'Automatic', 'DiagnosticOnly')]
    [string]$Mode = 'Interactive',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Debug', 'Info', 'Warning', 'Error')]
    [string]$LogLevel = 'Info',
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipBackup,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipSystemRestorePoint
)

# ════════════════════════════════════════════════════════════════════════════════
# STRICT MODE I ERROR HANDLING
# ════════════════════════════════════════════════════════════════════════════════

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Global error handler
trap {
    Write-Host "BŁĄD KRYTYCZNY: $_" -ForegroundColor Red
    Write-Host "Lokalizacja: $($_.ScriptStackTrace)" -ForegroundColor Red
    
    if ($Script:LastBackupId) {
        Write-Host "`nCzy chcesz przywrócić ostatni backup? (T/N)" -ForegroundColor Yellow
        $rollback = Read-Host
        if ($rollback -eq 'T') {
            try {
                Restore-ConfigurationBackup -BackupId $Script:LastBackupId
            }
            catch {
                Write-Host "Nie udało się przywrócić backupu: $_" -ForegroundColor Red
            }
        }
    }
    
    Read-Host "`nNaciśnij Enter aby zakończyć"
    exit 1
}

# ════════════════════════════════════════════════════════════════════════════════
# ZMIENNE GLOBALNE I KONFIGURACJA
# ════════════════════════════════════════════════════════════════════════════════

$Script:Version = "4.0.0-FINAL"
$Script:BuildDate = "2026-02-08"
$Script:Author = "Nieznany Nikomu Anonymousik"
$Script:Organization = "SecFERRO DIVISION"
$Script:LastBackupId = $null
$Script:SessionStartTime = Get-Date
$Script:OperationCounter = 0
$Script:ChangesApplied = @()
$Script:LogFile = $null

# Konfiguracja główna
$Script:Config = @{
    # Metadane
    Version = $Script:Version
    Author = $Script:Author
    Organization = $Script:Organization
    
    # Wersje referencyjne firmware/sterowników
    MinBIOSVersion = 109
    RecommendedBIOSVersion = 109
    MinArcDriver = [Version]"32.0.101.6877"
    RecommendedArcDriver = [Version]"32.0.101.6877"
    MinMSICenterM = [Version]"1.0.2405.1401"
    
    # URL zasobów
    MSIDriversURL = "https://www.msi.com/Handheld/Claw-A1MX/support"
    IntelArcDriversURL = "https://www.intel.com/content/www/us/en/download/785597/intel-arc-iris-xe-graphics-windows.html"
    QuickCPUDownload = "https://www.coderbag.com/assets/downloads/cpm/currentversion/QuickCpuSetup.msi"
    MSICenterDownload = "https://download.msi.com/uti_exe/nb/MSICenterM.zip"
    
    # Ścieżki systemowe
    BackupRoot = "$env:USERPROFILE\MSI_Claw_Backups"
    ProfilesPath = "$env:USERPROFILE\Documents\MSI_Claw_Profiles"
    TempPath = "$env:TEMP\MSI_Claw_Optimizer"
    LogPath = "$env:USERPROFILE\MSI_Claw_Logs"
    ReportsPath = "$env:USERPROFILE\MSI_Claw_Reports"
    
    # Ustawienia
    LogRetentionDays = 30
    MaxBackups = 10
    BackupCompressionEnabled = $true
    AutoBackupBeforeChanges = (-not $SkipBackup)
}

# ════════════════════════════════════════════════════════════════════════════════
# FUNKCJE POMOCNICZE - INTERFEJS
# ════════════════════════════════════════════════════════════════════════════════

function Write-ColorOutput {
    param([ConsoleColor]$ForegroundColor)
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) { Write-Output $args }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        [Parameter(Mandatory=$false)]
        [string]$SubText = ""
    )
    
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  $Text" -ForegroundColor Cyan
    if ($SubText) {
        Write-Host "  $SubText" -ForegroundColor Gray
    }
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
}

function Write-Success { 
    param([string]$Text) 
    Write-Host "✓ $Text" -ForegroundColor Green 
}

function Write-Info { 
    param([string]$Text) 
    Write-Host "ℹ $Text" -ForegroundColor Cyan 
}

function Write-Warning-Custom { 
    param([string]$Text) 
    Write-Host "⚠ $Text" -ForegroundColor Yellow 
}

function Write-Error-Custom { 
    param([string]$Text) 
    Write-Host "✗ $Text" -ForegroundColor Red 
}

function Show-Banner {
    Clear-Host
    
    $banner = @"

███╗   ███╗███████╗██╗     ██████╗██╗      █████╗ ██╗    ██╗
████╗ ████║██╔════╝██║    ██╔════╝██║     ██╔══██╗██║    ██║
██╔████╔██║███████╗██║    ██║     ██║     ███████║██║ █╗ ██║
██║╚██╔╝██║╚════██║██║    ██║     ██║     ██╔══██║██║███╗██║
██║ ╚═╝ ██║███████║██║    ╚██████╗███████╗██║  ██║╚███╔███╔╝
╚═╝     ╚═╝╚══════╝╚═╝     ╚═════╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ 

         OPTIMIZER v$($Script:Version) - PROFESSIONAL EDITION
         
"@
    
    Write-Host $banner -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  Autor: $($Script:Author)" -ForegroundColor Gray
    Write-Host "  Pod patronem: $($Script:Organization)" -ForegroundColor Gray
    Write-Host "  Build: $($Script:BuildDate) | PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor DarkGray
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
}

function Confirm-Action {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [string]$WarningMessage = "",
        [Parameter(Mandatory=$false)]
        [switch]$DefaultYes
    )
    
    if ($WarningMessage) {
        Write-Warning-Custom $WarningMessage
    }
    
    $options = if ($DefaultYes) { " [T/n]" } else { " [t/N]" }
    $response = Read-Host "$Message$options"
    
    if ($DefaultYes) {
        return ($response -eq '' -or $response -eq 'T' -or $response -eq 't')
    }
    else {
        return ($response -eq 'T' -or $response -eq 't')
    }
}

# ════════════════════════════════════════════════════════════════════════════════
# FUNKCJE WALIDACJI I SPRAWDZANIA
# ════════════════════════════════════════════════════════════════════════════════

function Test-AdministratorPrivileges {
    <#
    .SYNOPSIS
        Sprawdza czy skrypt jest uruchomiony z uprawnieniami administratora
    #>
    
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host ""
        Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host " BŁĄD: BRAK UPRAWNIEŃ ADMINISTRATORA" -ForegroundColor Red
        Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Red
        Write-Host ""
        Write-Host "Ten skrypt wymaga uprawnień administratora." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Aby uruchomić skrypt poprawnie:" -ForegroundColor Cyan
        Write-Host "  1. Kliknij prawym przyciskiem myszy na plik .ps1" -ForegroundColor White
        Write-Host "  2. Wybierz 'Uruchom jako administrator'" -ForegroundColor White
        Write-Host ""
        
        Read-Host "Naciśnij Enter aby zakończyć"
        exit 1
    }
    
    return $true
}

# ════════════════════════════════════════════════════════════════════════════════
# FUNKCJE BACKUPU I SYSTEM RESTORE
# ════════════════════════════════════════════════════════════════════════════════

function New-SystemRestorePoint {
    <#
    .SYNOPSIS
        Tworzy punkt przywracania systemu Windows
    .DESCRIPTION
        Tworzy punkt przywracania z obejściem limitu 24h
        Jest to najbezpieczniejszy sposób zabezpieczenia przed zmianami
    #>
    
    if ($SkipSystemRestorePoint) {
        Write-Warning-Custom "Pomijam tworzenie punktu przywracania (parametr -SkipSystemRestorePoint)"
        return $false
    }
    
    Write-Header "TWORZENIE PUNKTU PRZYWRACANIA SYSTEMU" `
                 -SubText "Zabezpieczenie przed nieprzewidzianymi problemami"
    
    try {
        # Sprawdź czy System Restore jest włączone
        $srStatus = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
        $srEnabled = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name "RPSessionInterval" -ErrorAction SilentlyContinue) -ne $null
        
        if (-not $srEnabled) {
            Write-Warning-Custom "Ochrona Systemu jest wyłączona"
            Write-Info "Aby włączyć:"
            Write-Host "  1. Wyszukaj 'Utwórz punkt przywracania' w Windows" -ForegroundColor Gray
            Write-Host "  2. Wybierz dysk C: i kliknij 'Konfiguruj'" -ForegroundColor Gray
            Write-Host "  3. Włącz 'Włącz ochronę systemu'" -ForegroundColor Gray
            Write-Host ""
            
            if (-not (Confirm-Action -Message "Czy chcesz kontynuować bez punktu przywracania?")) {
                Write-Info "Operacja anulowana przez użytkownika"
                exit 0
            }
            
            return $false
        }
        
        # Tymczasowo usuń limit częstotliwości
        $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
        $ConfiguredLimit = Get-ItemProperty -Path $RegistryPath -Name "SystemRestorePointCreationFrequency" -ErrorAction SilentlyContinue
        $OriginalValue = if ($null -ne $ConfiguredLimit.SystemRestorePointCreationFrequency) { 
            $ConfiguredLimit.SystemRestorePointCreationFrequency 
        } else { 
            1440  # 24 godziny w minutach
        }
        
        try {
            # Ustaw limit na 0 (brak limitu)
            Set-ItemProperty -Path $RegistryPath -Name "SystemRestorePointCreationFrequency" -Value 0 -Force -ErrorAction Stop
            
            Write-Info "Tworzenie punktu przywracania..."
            Write-Host "  (może to potrwać do 60 sekund)" -ForegroundColor DarkGray
            Write-Host ""
            
            # Utwórz punkt przywracania
            Checkpoint-Computer -Description "MSI_Claw_Optimizer_v4_Safety_$(Get-Date -Format 'yyyyMMdd_HHmmss')" `
                               -RestorePointType "MODIFY_SETTINGS" `
                               -ErrorAction Stop
            
            Write-Success "Punkt przywracania utworzony pomyślnie"
            Write-Info "Nazwa: MSI_Claw_Optimizer_v4_Safety"
            Write-Host ""
            
            return $true
        }
        finally {
            # Przywróć oryginalny limit
            Set-ItemProperty -Path $RegistryPath -Name "SystemRestorePointCreationFrequency" -Value $OriginalValue -Force -ErrorAction SilentlyContinue
        }
    }
    catch {
        Write-Warning-Custom "Nie można utworzyć punktu przywracania"
        Write-Host "  Przyczyna: $_" -ForegroundColor Red
        Write-Host ""
        Write-Info "Możliwe przyczyny:"
        Write-Host "  • Ochrona Systemu wyłączona na dysku C:" -ForegroundColor Gray
        Write-Host "  • Brak miejsca na dysku" -ForegroundColor Gray
        Write-Host "  • Punkt przywracania był już tworzony w ciągu ostatnich 24h" -ForegroundColor Gray
        Write-Host ""
        
        if (-not (Confirm-Action -Message "Czy chcesz kontynuować bez punktu przywracania?" `
                                -WarningMessage "Kontynuowanie bez zabezpieczenia NIE JEST ZALECANE!")) {
            Write-Info "Operacja anulowana przez użytkownika"
            exit 0
        }
        
        return $false
    }
}

function New-ConfigurationBackup {
    <#
    .SYNOPSIS
        Tworzy backup konfiguracji rejestru i ustawień
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$Description = "Automatyczny backup przed optymalizacją"
    )
    
    if (-not $Script:Config.AutoBackupBeforeChanges) {
        return $null
    }
    
    try {
        Write-Info "Tworzenie backupu konfiguracji..."
        
        $backupId = "Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        $backupPath = Join-Path $Script:Config.BackupRoot $backupId
        
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        
        # Metadane
        $metadata = @{
            BackupId = $backupId
            Timestamp = Get-Date -Format 'o'
            Description = $Description
            User = $env:USERNAME
            Computer = $env:COMPUTERNAME
            ScriptVersion = $Script:Version
            Items = @()
        }
        
        # Backup rejestru
        $registryPaths = @(
            "HKLM:\SYSTEM\CurrentControlSet\Control\Power",
            "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power",
            "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard",
            "HKCU:\System\GameConfigStore"
        )
        
        $regBackupPath = Join-Path $backupPath "Registry"
        New-Item -ItemType Directory -Path $regBackupPath -Force | Out-Null
        
        foreach ($regPath in $registryPaths) {
            if (Test-Path $regPath) {
                try {
                    $safeName = $regPath -replace '[\\:]', '_'
                    $exportPath = Join-Path $regBackupPath "$safeName.reg"
                    
                    $regExport = "reg export `"$($regPath -replace 'HKLM:', 'HKEY_LOCAL_MACHINE' -replace 'HKCU:', 'HKEY_CURRENT_USER')`" `"$exportPath`" /y 2>nul"
                    cmd /c $regExport | Out-Null
                    
                    if (Test-Path $exportPath) {
                        $metadata.Items += "Registry: $regPath"
                    }
                }
                catch {
                    # Nie krytyczne
                }
            }
        }
        
        # Backup konfiguracji zasilania
        $powerCfgPath = Join-Path $backupPath "PowerConfig.txt"
        powercfg /list | Out-File -FilePath $powerCfgPath -Encoding UTF8
        powercfg /query | Out-File -FilePath $powerCfgPath -Append -Encoding UTF8
        $metadata.Items += "Power Configuration"
        
        # Zapisz metadane
        $metadataPath = Join-Path $backupPath "metadata.json"
        $metadata | ConvertTo-Json -Depth 10 | Out-File -FilePath $metadataPath -Encoding UTF8
        
        # Kompresja (opcjonalnie)
        if ($Script:Config.BackupCompressionEnabled) {
            $zipPath = "$backupPath.zip"
            try {
                Compress-Archive -Path $backupPath -DestinationPath $zipPath -Force -ErrorAction Stop
                Remove-Item -Path $backupPath -Recurse -Force
            }
            catch {
                # Jeśli kompresja nie powiedzie się, zostaw nieskompresowany
            }
        }
        
        # Usuń stare backupy
        $allBackups = Get-ChildItem -Path $Script:Config.BackupRoot -Directory -ErrorAction SilentlyContinue |
                      Sort-Object CreationTime -Descending
        
        if ($allBackups.Count -gt $Script:Config.MaxBackups) {
            $allBackups | Select-Object -Skip $Script:Config.MaxBackups | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        $Script:LastBackupId = $backupId
        Write-Success "Backup utworzony: $backupId"
        
        return $backupId
    }
    catch {
        Write-Warning-Custom "Nie udało się utworzyć backupu: $_"
        return $null
    }
}

function Restore-ConfigurationBackup {
    <#
    .SYNOPSIS
        Przywraca konfigurację z backupu
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$BackupId
    )
    
    try {
        if (-not $BackupId) {
            $backups = Get-ChildItem -Path $Script:Config.BackupRoot -Directory -ErrorAction SilentlyContinue |
                       Sort-Object CreationTime -Descending
            
            if ($backups.Count -eq 0) {
                Write-Warning-Custom "Brak dostępnych backupów"
                return
            }
            
            Write-Header "DOSTĘPNE BACKUPY"
            
            for ($i = 0; $i -lt $backups.Count; $i++) {
                Write-Host "[$($i+1)] $($backups[$i].Name)" -ForegroundColor Cyan
                Write-Host "    Data: $($backups[$i].CreationTime)" -ForegroundColor Gray
                Write-Host ""
            }
            
            $selection = Read-Host "Wybierz backup do przywrócenia (1-$($backups.Count)) lub 0 aby anulować"
            
            if ($selection -eq '0' -or [int]$selection -lt 1 -or [int]$selection -gt $backups.Count) {
                Write-Info "Operacja anulowana"
                return
            }
            
            $BackupId = $backups[[int]$selection - 1].Name
        }
        
        $backupPath = Join-Path $Script:Config.BackupRoot $BackupId
        
        if (-not (Test-Path $backupPath)) {
            Write-Error-Custom "Backup nie istnieje: $BackupId"
            return
        }
        
        Write-Header "PRZYWRACANIE BACKUPU" -SubText "ID: $BackupId"
        
        if (-not (Confirm-Action -Message "Czy na pewno chcesz przywrócić ten backup?" `
                                 -WarningMessage "To nadpisze obecną konfigurację!")) {
            Write-Info "Operacja anulowana"
            return
        }
        
        # Przywróć rejestr
        $regBackupPath = Join-Path $backupPath "Registry"
        if (Test-Path $regBackupPath) {
            $regFiles = Get-ChildItem -Path $regBackupPath -Filter "*.reg"
            
            foreach ($regFile in $regFiles) {
                try {
                    $regImport = "reg import `"$($regFile.FullName)`" 2>nul"
                    cmd /c $regImport | Out-Null
                }
                catch {
                    Write-Warning-Custom "Nie udało się przywrócić: $($regFile.Name)"
                }
            }
        }
        
        Write-Success "Backup przywrócony pomyślnie"
        Write-Warning-Custom "Wymagany restart systemu!"
        
        if (Confirm-Action -Message "Czy chcesz uruchomić ponownie komputer teraz?") {
            Restart-Computer -Force
        }
    }
    catch {
        Write-Error-Custom "Błąd podczas przywracania backupu: $_"
    }
}

# (...kontynuacja w następnym pliku ze względu na limit...)

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host " To jest część 1 finalnego skryptu" -ForegroundColor Yellow
Write-Host " Wszystkie części zostaną skonsolidowane w końcowym pliku" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Red
