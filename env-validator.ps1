# =============================================================================
# ENVIRONMENT VARIABLE VALIDATOR
# =============================================================================
# This script validates environment variables for the video enhancer project
# Ensures all required variables are set and have valid values

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "production", "staging", "all")]
    [string]$Environment = "all",
    
    [Parameter(Mandatory=$false)]
    [switch]$Fix,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Color codes for output
$Colors = @{
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
    Header = "Magenta"
}

# Required environment variables by component
$RequiredVars = @{
    backend = @{
        required = @(
            "PORT",
            "HOST",
            "DEBUG",
            "LOG_LEVEL",
            "CORS_ORIGINS",
            "MAX_FILE_SIZE",
            "UPLOAD_DIR",
            "FFMPEG_PATH",
            "REALESRGAN_PATH"
        )
        optional = @(
            "TEMP_DIR",
            "REALESRGAN_MODEL",
            "VIDEO_SCALE_FACTORS",
            "SUPPORTED_FORMATS",
            "API_KEY",
            "JWT_SECRET",
            "SESSION_SECRET",
            "RATE_LIMIT_REQUESTS",
            "RATE_LIMIT_WINDOW",
            "LOG_FILE",
            "LOG_MAX_SIZE",
            "LOG_BACKUP_COUNT",
            "HEALTH_CHECK_INTERVAL",
            "HEALTH_CHECK_TIMEOUT",
            "ENABLE_AUDIO_ANALYSIS",
            "ENABLE_VIDEO_PREVIEW",
            "ENABLE_BATCH_PROCESSING"
        )
    }
    frontend = @{
        required = @(
            "NEXT_PUBLIC_API_URL",
            "NEXT_PUBLIC_APP_NAME",
            "NEXT_PUBLIC_APP_VERSION"
        )
        optional = @(
            "NEXT_PUBLIC_ENVIRONMENT",
            "NEXT_PUBLIC_DEBUG",
            "DEV_SERVER_PORT",
            "DEV_SERVER_HOST",
            "HOT_RELOAD",
            "WATCH_DIRS"
        )
    }
    root = @{
        required = @(
            "ENVIRONMENT",
            "NODE_ENV",
            "BACKEND_URL",
            "FRONTEND_URL"
        )
        optional = @(
            "BACKEND_PORT",
            "FRONTEND_PORT",
            "RENDER_SERVICE_NAME",
            "RENDER_REGION",
            "RENDER_PLAN",
            "VERCEL_PROJECT_NAME",
            "DEV_SERVER_PORT",
            "DEV_SERVER_HOST",
            "HOT_RELOAD",
            "WATCH_DIRS"
        )
    }
}

# Validation rules
$ValidationRules = @{
    PORT = @{
        Type = "int"
        Min = 1
        Max = 65535
        Default = 8000
    }
    DEBUG = @{
        Type = "bool"
        Values = @("true", "false")
        Default = "true"
    }
    LOG_LEVEL = @{
        Type = "enum"
        Values = @("DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL")
        Default = "INFO"
    }
    MAX_FILE_SIZE = @{
        Type = "size"
        Default = "100MB"
    }
    NEXT_PUBLIC_API_URL = @{
        Type = "url"
        Default = "http://localhost:8000"
    }
    CORS_ORIGINS = @{
        Type = "string"
        Default = "*"
    }
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Colors[$Color]
}

function Write-Header {
    param([string]$Title)
    Write-ColorOutput "`n" -Color Info
    Write-ColorOutput "=" * 60 -Color Header
    Write-ColorOutput " $Title" -Color Header
    Write-ColorOutput "=" * 60 -Color Header
    Write-ColorOutput "`n" -Color Info
}

function Load-EnvironmentFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return @{}
    }
    
    $envVars = @{}
    $content = Get-Content $FilePath -ErrorAction SilentlyContinue
    
    foreach ($line in $content) {
        $line = $line.Trim()
        
        # Skip comments and empty lines
        if ([string]::IsNullOrEmpty($line) -or $line.StartsWith("#")) {
            continue
        }
        
        # Parse key=value
        if ($line -match "^([^=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Remove quotes if present
            if ($value.StartsWith('"') -and $value.EndsWith('"')) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            elseif ($value.StartsWith("'") -and $value.EndsWith("'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            
            $envVars[$key] = $value
        }
    }
    
    return $envVars
}

function Test-ValueValidation {
    param(
        [string]$Key,
        [string]$Value,
        [hashtable]$Rules
    )
    
    if (-not $Rules.ContainsKey($Key)) {
        return @{ Valid = $true; Message = "" }
    }
    
    $rule = $Rules[$Key]
    
    switch ($rule.Type) {
        "int" {
            if ([int]::TryParse($Value, [ref]$null)) {
                $intValue = [int]$Value
                if ($intValue -ge $rule.Min -and $intValue -le $rule.Max) {
                    return @{ Valid = $true; Message = "" }
                }
                else {
                    return @{ Valid = $false; Message = "Value must be between $($rule.Min) and $($rule.Max)" }
                }
            }
            else {
                return @{ Valid = $false; Message = "Value must be a valid integer" }
            }
        }
        "bool" {
            if ($rule.Values -contains $Value.ToLower()) {
                return @{ Valid = $true; Message = "" }
            }
            else {
                return @{ Valid = $false; Message = "Value must be one of: $($rule.Values -join ', ')" }
            }
        }
        "enum" {
            if ($rule.Values -contains $Value.ToUpper()) {
                return @{ Valid = $true; Message = "" }
            }
            else {
                return @{ Valid = $false; Message = "Value must be one of: $($rule.Values -join ', ')" }
            }
        }
        "url" {
            try {
                $uri = [System.Uri]$Value
                return @{ Valid = $true; Message = "" }
            }
            catch {
                return @{ Valid = $false; Message = "Value must be a valid URL" }
            }
        }
        "size" {
            if ($Value -match "^\d+[KMGT]?B?$") {
                return @{ Valid = $true; Message = "" }
            }
            else {
                return @{ Valid = $false; Message = "Value must be a valid size (e.g., 100MB, 1GB)" }
            }
        }
        default {
            return @{ Valid = $true; Message = "" }
        }
    }
}

function Validate-EnvironmentFile {
    param(
        [string]$FilePath,
        [string]$Component,
        [hashtable]$RequiredVars,
        [hashtable]$ValidationRules
    )
    
    Write-ColorOutput "Validating $Component environment file: $FilePath" -Color Info
    
    if (-not (Test-Path $FilePath)) {
        Write-ColorOutput "✗ File not found: $FilePath" -Color Error
        return @{ Valid = $false; Missing = $RequiredVars.required; Invalid = @() }
    }
    
    $envVars = Load-EnvironmentFile $FilePath
    $missing = @()
    $invalid = @()
    
    # Check required variables
    foreach ($var in $RequiredVars.required) {
        if (-not $envVars.ContainsKey($var)) {
            $missing += $var
        }
        elseif ([string]::IsNullOrEmpty($envVars[$var])) {
            $missing += $var
        }
    }
    
    # Validate values
    foreach ($var in $envVars.Keys) {
        if ($ValidationRules.ContainsKey($var)) {
            $validation = Test-ValueValidation -Key $var -Value $envVars[$var] -Rules $ValidationRules
            if (-not $validation.Valid) {
                $invalid += @{ Variable = $var; Value = $envVars[$var]; Message = $validation.Message }
            }
        }
    }
    
    # Report results
    if ($missing.Count -eq 0 -and $invalid.Count -eq 0) {
        Write-ColorOutput "✓ All required variables present and valid" -Color Success
    }
    else {
        if ($missing.Count -gt 0) {
            Write-ColorOutput "✗ Missing required variables: $($missing -join ', ')" -Color Error
        }
        if ($invalid.Count -gt 0) {
            Write-ColorOutput "✗ Invalid variable values:" -Color Error
            foreach ($inv in $invalid) {
                Write-ColorOutput "  • $($inv.Variable)=$($inv.Value): $($inv.Message)" -Color Error
            }
        }
    }
    
    if ($Verbose) {
        Write-ColorOutput "Found variables: $($envVars.Keys -join ', ')" -Color Info
    }
    
    return @{ Valid = ($missing.Count -eq 0 -and $invalid.Count -eq 0); Missing = $missing; Invalid = $invalid; Variables = $envVars }
}

function Fix-EnvironmentFile {
    param(
        [string]$FilePath,
        [string]$Component,
        [hashtable]$ValidationResult,
        [hashtable]$ValidationRules
    )
    
    Write-ColorOutput "Fixing $Component environment file: $FilePath" -Color Info
    
    if (-not (Test-Path $FilePath)) {
        Write-ColorOutput "✗ Cannot fix non-existent file: $FilePath" -Color Error
        return $false
    }
    
    $envVars = $ValidationResult.Variables
    $fixed = $false
    
    # Fix missing variables
    foreach ($var in $ValidationResult.Missing) {
        if ($ValidationRules.ContainsKey($var)) {
            $defaultValue = $ValidationRules[$var].Default
            $envVars[$var] = $defaultValue
            Write-ColorOutput "  • Added missing variable: $var=$defaultValue" -Color Success
            $fixed = $true
        }
        else {
            Write-ColorOutput "  • Missing variable without default: $var" -Color Warning
        }
    }
    
    # Fix invalid variables
    foreach ($inv in $ValidationResult.Invalid) {
        $var = $inv.Variable
        if ($ValidationRules.ContainsKey($var)) {
            $defaultValue = $ValidationRules[$var].Default
            $envVars[$var] = $defaultValue
            Write-ColorOutput "  • Fixed invalid variable: $var=$defaultValue" -Color Success
            $fixed = $true
        }
    }
    
    if ($fixed) {
        # Write back to file
        $content = @()
        $content += "# $Component Environment Variables"
        $content += "# Updated on $(Get-Date)"
        $content += ""
        
        foreach ($key in $envVars.Keys | Sort-Object) {
            $value = $envVars[$key]
            $content += "$key=$value"
        }
        
        $content | Out-File -FilePath $FilePath -Encoding UTF8
        Write-ColorOutput "✓ Environment file updated: $FilePath" -Color Success
        return $true
    }
    else {
        Write-ColorOutput "✓ No fixes needed for: $FilePath" -Color Success
        return $false
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

try {
    Write-Header "Environment Variable Validation"
    
    $components = @()
    switch ($Environment) {
        "development" { $components = @("backend", "frontend", "root") }
        "production" { $components = @("backend", "frontend", "root") }
        "staging" { $components = @("backend", "frontend", "root") }
        "all" { $components = @("backend", "frontend", "root") }
    }
    
    $filePaths = @{
        backend = "backend\.env"
        frontend = "frontend\.env.local"
        root = ".env"
    }
    
    $overallValid = $true
    $fixResults = @()
    
    foreach ($component in $components) {
        $filePath = $filePaths[$component]
        $requiredVars = $RequiredVars[$component]
        
        $validationResult = Validate-EnvironmentFile -FilePath $filePath -Component $component -RequiredVars $requiredVars -ValidationRules $ValidationRules
        
        if (-not $validationResult.Valid) {
            $overallValid = $false
            
            if ($Fix) {
                $fixResult = Fix-EnvironmentFile -FilePath $filePath -Component $component -ValidationResult $validationResult -ValidationRules $ValidationRules
                $fixResults += @{ Component = $component; Fixed = $fixResult }
            }
        }
    }
    
    # Summary
    Write-Header "Validation Summary"
    
    if ($overallValid) {
        Write-ColorOutput "🎉 All environment files are valid!" -Color Success
    }
    elseif ($Fix) {
        $fixedCount = ($fixResults | Where-Object { $_.Fixed }).Count
        if ($fixedCount -gt 0) {
            Write-ColorOutput "🔧 Fixed $fixedCount environment file(s)" -Color Success
        }
        else {
            Write-ColorOutput "⚠️  Some issues could not be automatically fixed" -Color Warning
        }
    }
    else {
        Write-ColorOutput "❌ Environment validation failed" -Color Error
        Write-ColorOutput "Run with -Fix to automatically fix issues" -Color Info
    }
    
    if ($Fix -and $fixResults.Count -gt 0) {
        Write-ColorOutput "`nFix Results:" -Color Info
        foreach ($result in $fixResults) {
            $status = if ($result.Fixed) { "✓ Fixed" } else { "✗ Failed" }
            Write-ColorOutput "  • $($result.Component): $status" -Color $(if ($result.Fixed) { "Success" } else { "Error" })
        }
    }
    
    exit $(if ($overallValid) { 0 } else { 1 })
}
catch {
    Write-ColorOutput "`n❌ Validation failed: $($_.Exception.Message)" -Color Error
    if ($Verbose) {
        Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" -Color Error
    }
    exit 1
} 