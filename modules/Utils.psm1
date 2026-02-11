<#
.SYNOPSIS
    Utils Module - Security & Helper Functions
    
.DESCRIPTION
    Moduł zawierający funkcje pomocnicze i zabezpieczenia
#>

# ════════════════════════════════════════════════════════════════════════════════
# SECURITY FUNCTIONS
# ════════════════════════════════════════════════════════════════════════════════

function Read-HostSanitized {
    <#
    .SYNOPSIS
        Bezpieczne czytanie input od użytkownika z sanityzacją
    .PARAMETER Prompt
        Tekst promptu
    .PARAMETER AllowedChars
        Typ dozwolonych znaków: AlphaNumeric, FilePath, Description
    .PARAMETER MaxLength
        Maksymalna długość (domyślnie 100)
    .EXAMPLE
        $description = Read-HostSanitized -Prompt "Podaj opis" -AllowedChars Description
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('AlphaNumeric', 'FilePath', 'Description', 'Email')]
        [string]$AllowedChars = 'Description',
        
        [Parameter(Mandatory = $false)]
        [int]$MaxLength = 100,
        
        [Parameter(Mandatory = $false)]
        [string]$DefaultValue = ''
    )
    
    $input = Read-Host $Prompt
    
    # Use default if empty
    if ([string]::IsNullOrWhiteSpace($input) -and $DefaultValue) {
        $input = $DefaultValue
    }
    
    # Sanitize based on context
    switch ($AllowedChars) {
        'AlphaNumeric' {
            # Only letters, numbers, underscore, hyphen
            $input = $input -replace '[^a-zA-Z0-9_-]', ''
        }
        'FilePath' {
            # Remove dangerous path characters
            $input = $input -replace '[<>:"|?*]', '_'
            $input = $input -replace '[\\/]{2,}', '\'  # Remove double slashes
        }
        'Description' {
            # Remove potentially dangerous characters
            $input = $input -replace '[<>`$]', ''
            $input = $input -replace '[\r\n]', ' '  # Remove newlines
        }
        'Email' {
            # Basic email validation
            if ($input -notmatch '^[\w\.-]+@[\w\.-]+\.\w+$') {
                Write-Warning "Nieprawidłowy format email"
                return ''
            }
        }
    }
    
    # Trim whitespace
    $input = $input.Trim()
    
    # Enforce max length
    if ($input.Length -gt $MaxLength) {
        $input = $input.Substring(0, $MaxLength)
        Write-Warning "Input obcięty do $MaxLength znaków"
    }
    
    return $input
}

function Invoke-SecureCommand {
    <#
    .SYNOPSIS
        Bezpieczne wykonywanie komend systemowych (zamiennik dla Invoke-Expression)
    .DESCRIPTION
        Używa Start-Process zamiast niebezpiecznego Invoke-Expression
    .EXAMPLE
        Invoke-SecureCommand -FilePath 'reg.exe' -Arguments @('export', $path, $output)
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @(),
        
        [Parameter(Mandatory = $false)]
        [switch]$NoNewWindow,
        
        [Parameter(Mandatory = $false)]
        [switch]$Wait,
        
        [Parameter(Mandatory = $false)]
        [int]$TimeoutSeconds = 300
    )
    
    try {
        $processParams = @{
            FilePath = $FilePath
            ArgumentList = $Arguments
            PassThru = $true
        }
        
        if ($NoNewWindow) {
            $processParams.NoNewWindow = $true
        }
        
        if ($Wait) {
            $processParams.Wait = $true
        }
        
        $process = Start-Process @processParams
        
        # Wait with timeout
        if ($Wait -and $TimeoutSeconds -gt 0) {
            if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
                $process.Kill()
                throw "Process timeout after $TimeoutSeconds seconds"
            }
        }
        
        return @{
            Success = ($process.ExitCode -eq 0)
            ExitCode = $process.ExitCode
            Process = $process
        }
    }
    catch {
        Write-Error "Błąd wykonywania komendy: $_"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Test-FileIntegrity {
    <#
    .SYNOPSIS
        Weryfikuje integralność pliku poprzez SHA256 hash
    .EXAMPLE
        Test-FileIntegrity -FilePath $file -ExpectedHash $hash
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$ExpectedHash
    )
    
    if (-not (Test-Path $FilePath)) {
        throw "Plik nie istnieje: $FilePath"
    }
    
    try {
        $actualHash = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
        
        if ($actualHash -eq $ExpectedHash) {
            Write-Verbose "Integralność pliku OK: $FilePath"
            return $true
        }
        else {
            Write-Error "SHA256 MISMATCH dla $FilePath"
            Write-Error "Oczekiwano: $ExpectedHash"
            Write-Error "Otrzymano:  $actualHash"
            return $false
        }
    }
    catch {
        Write-Error "Błąd weryfikacji integralności: $_"
        return $false
    }
}

function Get-SecureDownload {
    <#
    .SYNOPSIS
        Bezpieczne pobieranie pliku z weryfikacją SHA256
    .EXAMPLE
        Get-SecureDownload -Url $url -OutputPath $path -ExpectedHash $hash
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory = $true)]
        [string]$ExpectedHash,
        
        [Parameter(Mandatory = $false)]
        [switch]$VerifyAuthenticode
    )
    
    # Enforce HTTPS
    if ($Url -notmatch '^https://') {
        throw "Tylko HTTPS URLs są dozwolone (security policy)"
    }
    
    Write-Host "Pobieranie z: $Url" -ForegroundColor Cyan
    
    try {
        # Download file
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Url, $OutputPath)
        
        Write-Host "Weryfikacja SHA256..." -ForegroundColor Yellow
        
        # Verify SHA256
        if (-not (Test-FileIntegrity -FilePath $OutputPath -ExpectedHash $ExpectedHash)) {
            Remove-Item $OutputPath -Force
            throw "Integralność pliku naruszona - plik został usunięty"
        }
        
        # Verify digital signature (for .exe, .msi, .dll)
        if ($VerifyAuthenticode) {
            $extension = [System.IO.Path]::GetExtension($OutputPath)
            
            if ($extension -in @('.exe', '.msi', '.dll', '.ps1')) {
                Write-Host "Weryfikacja podpisu cyfrowego..." -ForegroundColor Yellow
                
                $signature = Get-AuthenticodeSignature -FilePath $OutputPath
                
                if ($signature.Status -ne 'Valid') {
                    Remove-Item $OutputPath -Force
                    throw "Nieprawidłowy podpis cyfrowy: $($signature.Status)"
                }
                
                Write-Host "  Podpisane przez: $($signature.SignerCertificate.Subject)" -ForegroundColor Green
            }
        }
        
        Write-Host "Plik bezpiecznie pobrany i zweryfikowany" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Błąd podczas bezpiecznego pobierania: $_"
        
        # Cleanup on failure
        if (Test-Path $OutputPath) {
            Remove-Item $OutputPath -Force
        }
        
        return $false
    }
}

# ════════════════════════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ════════════════════════════════════════════════════════════════════════════════

function Write-Log {
    <#
    .SYNOPSIS
        Unified logging function
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Debug', 'Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info',
        
        [Parameter(Mandatory = $false)]
        [string]$LogFile = $null,
        
        [Parameter(Mandatory = $false)]
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff'
    $caller = (Get-PSCallStack)[1].FunctionName
    
    # Structured log entry
    $logEntry = @{
        Timestamp = $timestamp
        Level = $Level
        Message = $Message
        Caller = $caller
        Thread = [Threading.Thread]::CurrentThread.ManagedThreadId
    }
    
    # Console output
    if (-not $NoConsole) {
        $color = switch ($Level) {
            'Debug'   { 'DarkGray' }
            'Info'    { 'Cyan' }
            'Warning' { 'Yellow' }
            'Error'   { 'Red' }
            'Success' { 'Green' }
        }
        
        $prefix = switch ($Level) {
            'Debug'   { '[DBG]' }
            'Info'    { '[INF]' }
            'Warning' { '[WRN]' }
            'Error'   { '[ERR]' }
            'Success' { '[OK ]' }
        }
        
        Write-Host "$timestamp $prefix $Message" -ForegroundColor $color
    }
    
    # File output (JSON Lines format for structured logging)
    if ($LogFile) {
        try {
            $logEntry | ConvertTo-Json -Compress | Add-Content -Path $LogFile -ErrorAction SilentlyContinue
        }
        catch {
            # Fail silently to not interrupt main flow
        }
    }
    
    # Windows Event Log (for errors and warnings)
    if ($Level -in @('Error', 'Warning')) {
        try {
            $eventSource = 'MSI_Claw_Optimizer'
            
            if (-not [System.Diagnostics.EventLog]::SourceExists($eventSource)) {
                New-EventLog -LogName Application -Source $eventSource -ErrorAction SilentlyContinue
            }
            
            $eventType = if ($Level -eq 'Error') { 'Error' } else { 'Warning' }
            $eventId = if ($Level -eq 'Error') { 1001 } else { 1002 }
            
            Write-EventLog -LogName Application -Source $eventSource `
                -EventId $eventId -EntryType $eventType -Message $Message `
                -ErrorAction SilentlyContinue
        }
        catch {
            # Fail silently
        }
    }
}

function Write-AuditLog {
    <#
    .SYNOPSIS
        Audit trail logging
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Action,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Details = @{},
        
        [Parameter(Mandatory = $false)]
        [string]$AuditFile
    )
    
    $auditEntry = @{
        Timestamp = (Get-Date).ToString('o')
        User = "$env:USERDOMAIN\$env:USERNAME"
        Computer = $env:COMPUTERNAME
        Action = $Action
        Details = $Details
        SessionId = $PID
    }
    
    if ($AuditFile) {
        try {
            $auditEntry | ConvertTo-Json -Compress | Add-Content -Path $AuditFile
        }
        catch {
            Write-Warning "Nie udało się zapisać audit log: $_"
        }
    }
}

# ════════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ════════════════════════════════════════════════════════════════════════════════

function Show-Progress {
    <#
    .SYNOPSIS
        Enhanced progress bar
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Activity,
        
        [Parameter(Mandatory = $true)]
        [int]$PercentComplete,
        
        [Parameter(Mandatory = $false)]
        [string]$Status = 'Processing...',
        
        [Parameter(Mandatory = $false)]
        [int]$Id = 0
    )
    
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete -Id $Id
}

function Read-HostWithTimeout {
    <#
    .SYNOPSIS
        Read-Host z timeoutem
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        
        [Parameter(Mandatory = $false)]
        [int]$Timeout = 30,
        
        [Parameter(Mandatory = $false)]
        [string]$DefaultValue = 'N'
    )
    
    Write-Host "$Prompt (timeout: ${Timeout}s, domyślnie: $DefaultValue): " -NoNewline -ForegroundColor Yellow
    
    $startTime = Get-Date
    $input = ''
    
    while (((Get-Date) - $startTime).TotalSeconds -lt $Timeout) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            
            if ($key.Key -eq 'Enter') {
                Write-Host ""
                break
            }
            elseif ($key.Key -eq 'Backspace' -and $input.Length -gt 0) {
                $input = $input.Substring(0, $input.Length - 1)
                Write-Host "`b `b" -NoNewline
            }
            elseif ($key.KeyChar -match '\S') {
                $input += $key.KeyChar
                Write-Host $key.KeyChar -NoNewline
            }
        }
        
        Start-Sleep -Milliseconds 100
    }
    
    if ([string]::IsNullOrWhiteSpace($input)) {
        Write-Host "`n(Timeout - używam domyślnej wartości: $DefaultValue)" -ForegroundColor Gray
        return $DefaultValue
    }
    
    return $input
}

function Test-IsElevated {
    <#
    .SYNOPSIS
        Sprawdza czy skrypt ma uprawnienia administratora
    #>
    
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function ConvertTo-PrettyJson {
    <#
    .SYNOPSIS
        Konwertuje obiekt do czytelnego JSON
    #>
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]$InputObject,
        
        [Parameter(Mandatory = $false)]
        [int]$Depth = 10
    )
    
    $InputObject | ConvertTo-Json -Depth $Depth | ForEach-Object {
        # Pretty print with indentation
        $_ -replace '(?m)  (?=\s*")', '  '
    }
}

function Get-ReadableFileSize {
    <#
    .SYNOPSIS
        Konwertuje rozmiar pliku do czytelnej postaci
    #>
    param(
        [Parameter(Mandatory = $true)]
        [long]$Bytes
    )
    
    $sizes = @('B', 'KB', 'MB', 'GB', 'TB')
    $order = 0
    $size = $Bytes
    
    while ($size -ge 1024 -and $order -lt $sizes.Count - 1) {
        $size = $size / 1024
        $order++
    }
    
    return "{0:N2} {1}" -f $size, $sizes[$order]
}

# Export functions
Export-ModuleMember -Function @(
    # Security
    'Read-HostSanitized',
    'Invoke-SecureCommand',
    'Test-FileIntegrity',
    'Get-SecureDownload',
    
    # Logging
    'Write-Log',
    'Write-AuditLog',
    
    # Helpers
    'Show-Progress',
    'Read-HostWithTimeout',
    'Test-IsElevated',
    'ConvertTo-PrettyJson',
    'Get-ReadableFileSize'
)
