#Requires -RunAsAdministrator

<#
.SYNOPSIS
    MSI Claw Optimizer v5.0 - Auto-Installer
    
.DESCRIPTION
    Automatyczny instalator dla MSI Claw Optimizer
    Pobiera, weryfikuje i instaluje framework
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$InstallPath = "$env:ProgramFiles\MSI_Claw_Optimizer",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipVerification
)

$ErrorActionPreference = 'Stop'

# ════════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ════════════════════════════════════════════════════════════════════════════════

$Config = @{
    Version = '5.0.0'
    ReleaseURL = 'https://github.com/anonymousik/msi-claw-aio-tweaker/releases/latest/download'
    VersionCheckURL = 'https://raw.githubusercontent.com/anonymousik/msi-claw-aio-tweaker/main/version.json'
    ZipFileName = 'MSI_Claw_Optimizer_v5.0.zip'
    TempDir = Join-Path $env:TEMP 'MSI_Claw_Installer'
}

# ════════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ════════════════════════════════════════════════════════════════════════════════

function Write-InstallLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $color = switch ($Level) {
        'Info'    { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
    }
    
    $prefix = switch ($Level) {
        'Info'    { '[i]' }
        'Success' { '[✓]' }
        'Warning' { '[!]' }
        'Error'   { '[✗]' }
    }
    
    Write-Host "$prefix $Message" -ForegroundColor $color
}

function Show-Banner {
    $banner = @"

███╗   ███╗███████╗██╗     ██████╗██╗      █████╗ ██╗    ██╗
████╗ ████║██╔════╝██║    ██╔════╝██║     ██╔══██╗██║    ██║
██╔████╔██║███████╗██║    ██║     ██║     ███████║██║ █╗ ██║
██║╚██╔╝██║╚════██║██║    ██║     ██║     ██╔══██║██║███╗██║
██║ ╚═╝ ██║███████║██║    ╚██████╗███████╗██║  ██║╚███╔███╔╝
╚═╝     ╚═╝╚══════╝╚═╝     ╚═════╝╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝

         AUTO-INSTALLER v$($Config.Version)
         
"@
    
    Write-Host $banner -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  Automated installation starting..." -ForegroundColor Gray
    Write-Host "  Install path: $InstallPath" -ForegroundColor Gray
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
}

# ════════════════════════════════════════════════════════════════════════════════
# INSTALLATION STEPS
# ════════════════════════════════════════════════════════════════════════════════

function Test-Prerequisites {
    Write-InstallLog "Checking prerequisites..." -Level Info
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw "PowerShell 5.1+ is required"
    }
    Write-InstallLog "PowerShell version: $($PSVersionTable.PSVersion) - OK" -Level Success
    
    # Check admin rights
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Administrator privileges required"
    }
    Write-InstallLog "Administrator privileges - OK" -Level Success
    
    # Check internet connection
    try {
        $null = Test-Connection -ComputerName '8.8.8.8' -Count 1 -Quiet -ErrorAction Stop
        Write-InstallLog "Internet connection - OK" -Level Success
    }
    catch {
        throw "Internet connection required for installation"
    }
    
    # Check disk space (need at least 100MB)
    $drive = Get-PSDrive -Name $env:SystemDrive.TrimEnd(':')
    $freeSpaceMB = [math]::Round($drive.Free / 1MB, 0)
    
    if ($freeSpaceMB -lt 100) {
        throw "Insufficient disk space. Required: 100MB, Available: ${freeSpaceMB}MB"
    }
    Write-InstallLog "Free disk space: ${freeSpaceMB}MB - OK" -Level Success
}

function Get-LatestVersion {
    Write-InstallLog "Checking latest version..." -Level Info
    
    try {
        $versionInfo = Invoke-RestMethod -Uri $Config.VersionCheckURL -TimeoutSec 10
        Write-InstallLog "Latest version: $($versionInfo.version)" -Level Success
        return $versionInfo
    }
    catch {
        Write-InstallLog "Could not check latest version, using: $($Config.Version)" -Level Warning
        return @{ version = $Config.Version }
    }
}

function Get-OptimizerPackage {
    Write-InstallLog "Downloading MSI Claw Optimizer..." -Level Info
    
    # Create temp directory
    if (Test-Path $Config.TempDir) {
        Remove-Item $Config.TempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Config.TempDir -Force | Out-Null
    
    # Download ZIP
    $zipPath = Join-Path $Config.TempDir $Config.ZipFileName
    $downloadURL = "$($Config.ReleaseURL)/$($Config.ZipFileName)"
    
    try {
        Write-InstallLog "Downloading from: $downloadURL" -Level Info
        
        # Use WebClient for progress display
        $webClient = New-Object System.Net.WebClient
        
        # Event handler for progress
        $webClient.DownloadProgressChanged += {
            param($sender, $e)
            Write-Progress -Activity "Downloading" -Status "$($e.ProgressPercentage)% Complete" -PercentComplete $e.ProgressPercentage
        }
        
        # Download
        $task = $webClient.DownloadFileTaskAsync($downloadURL, $zipPath)
        $task.Wait()
        
        Write-Progress -Activity "Downloading" -Completed
        
        if (-not (Test-Path $zipPath)) {
            throw "Download failed - file not found"
        }
        
        $fileSizeMB = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
        Write-InstallLog "Downloaded: ${fileSizeMB}MB" -Level Success
        
        return $zipPath
    }
    catch {
        throw "Download failed: $_"
    }
}

function Install-Optimizer {
    param(
        [string]$ZipPath
    )
    
    Write-InstallLog "Installing MSI Claw Optimizer..." -Level Info
    
    try {
        # Create install directory
        if (Test-Path $InstallPath) {
            Write-InstallLog "Removing old installation..." -Level Warning
            Remove-Item $InstallPath -Recurse -Force
        }
        
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        
        # Extract ZIP
        Write-InstallLog "Extracting files..." -Level Info
        Expand-Archive -Path $ZipPath -DestinationPath $InstallPath -Force
        
        # Verify essential files
        $essentialFiles = @(
            'MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1',
            'config.json',
            'README.md'
        )
        
        foreach ($file in $essentialFiles) {
            $filePath = Join-Path $InstallPath $file
            if (-not (Test-Path $filePath)) {
                throw "Installation verification failed: $file not found"
            }
        }
        
        # Verify modules directory
        $modulesPath = Join-Path $InstallPath 'modules'
        if (-not (Test-Path $modulesPath)) {
            throw "Modules directory not found"
        }
        
        Write-InstallLog "Installation completed successfully" -Level Success
        Write-InstallLog "Installed to: $InstallPath" -Level Info
    }
    catch {
        throw "Installation failed: $_"
    }
}

function Add-PathEnvironment {
    Write-InstallLog "Adding to PATH..." -Level Info
    
    try {
        # Get current PATH
        $currentPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        
        # Check if already in PATH
        if ($currentPath -notlike "*$InstallPath*") {
            # Add to PATH
            $newPath = "$currentPath;$InstallPath"
            [Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
            
            # Update current session
            $env:Path = "$env:Path;$InstallPath"
            
            Write-InstallLog "Added to system PATH" -Level Success
        }
        else {
            Write-InstallLog "Already in system PATH" -Level Info
        }
    }
    catch {
        Write-InstallLog "Could not add to PATH: $_" -Level Warning
        Write-InstallLog "You can run the optimizer from: $InstallPath" -Level Info
    }
}

function Show-NextSteps {
    Write-Host "`n" -NoNewline
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  INSTALLATION COMPLETE!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Open a NEW PowerShell window as Administrator" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  2. Run the optimizer:" -ForegroundColor Yellow
    Write-Host "     cd `"$InstallPath`"" -ForegroundColor White
    Write-Host "     .\MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "  OR if PATH was updated successfully:" -ForegroundColor Yellow
    Write-Host "     MSI_Claw_Optimizer_v5.0_BOOTSTRAP.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Documentation: $InstallPath\README.md" -ForegroundColor Gray
    Write-Host "Installation guide: $InstallPath\INSTALLATION.md" -ForegroundColor Gray
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
}

# ════════════════════════════════════════════════════════════════════════════════
# MAIN INSTALLATION FLOW
# ════════════════════════════════════════════════════════════════════════════════

try {
    # Show banner
    Show-Banner
    
    # Step 1: Prerequisites
    Test-Prerequisites
    
    # Step 2: Get latest version info
    $versionInfo = Get-LatestVersion
    
    # Step 3: Download
    $zipPath = Get-OptimizerPackage
    
    # Step 4: Verify (TODO: SHA256 check when hashes are published)
    if (-not $SkipVerification) {
        Write-InstallLog "Package verification: SKIPPED (hashes not yet published)" -Level Warning
    }
    
    # Step 5: Install
    Install-Optimizer -ZipPath $zipPath
    
    # Step 6: Add to PATH
    Add-PathEnvironment
    
    # Step 7: Cleanup
    Write-InstallLog "Cleaning up temporary files..." -Level Info
    Remove-Item $Config.TempDir -Recurse -Force -ErrorAction SilentlyContinue
    
    # Step 8: Show next steps
    Show-NextSteps
    
    # Success
    exit 0
}
catch {
    Write-InstallLog "Installation failed: $_" -Level Error
    Write-Host "`nStack trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkRed
    
    # Cleanup on failure
    if (Test-Path $Config.TempDir) {
        Remove-Item $Config.TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "`nFor help, visit:" -ForegroundColor Yellow
    Write-Host "https://github.com/anonymousik/msi-claw-aio-tweaker/issues" -ForegroundColor Cyan
    
    exit 1
}
