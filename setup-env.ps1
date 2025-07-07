# =============================================================================
# ENVIRONMENT VARIABLE SETUP AUTOMATION
# =============================================================================
# This script automates the setup of environment variables for the video enhancer project
# Supports both development and production environments

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "production", "staging")]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$false)]
    [string]$BackendUrl = "",
    
    [Parameter(Mandatory=$false)]
    [string]$FrontendUrl = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$Interactive
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

# Environment-specific configurations
$EnvConfigs = @{
    development = @{
        BackendUrl = "http://localhost:8000"
        FrontendUrl = "http://localhost:3000"
        Debug = "true"
        LogLevel = "DEBUG"
        CORSOrigins = "*"
    }
    staging = @{
        BackendUrl = "https://your-staging-backend.onrender.com"
        FrontendUrl = "https://your-staging-frontend.vercel.app"
        Debug = "false"
        LogLevel = "INFO"
        CORSOrigins = "https://your-staging-frontend.vercel.app"
    }
    production = @{
        BackendUrl = "https://your-production-backend.onrender.com"
        FrontendUrl = "https://your-production-frontend.vercel.app"
        Debug = "false"
        LogLevel = "WARNING"
        CORSOrigins = "https://your-production-frontend.vercel.app"
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

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Get-UserInput {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [string]$Validation = ""
    )
    
    if ($Interactive) {
        $input = Read-Host $Prompt
        if ([string]::IsNullOrEmpty($input) -and ![string]::IsNullOrEmpty($Default)) {
            return $Default
        }
        return $input
    }
    return $Default
}

function Test-EnvironmentFile {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        if ($Force) {
            Write-ColorOutput "Environment file exists. Overwriting due to -Force flag." -Color Warning
            return $false
        }
        else {
            $response = Get-UserInput "Environment file already exists. Overwrite? (y/N): " "N"
            return $response -eq "y" -or $response -eq "Y"
        }
    }
    return $true
}

function Generate-RandomSecret {
    param([int]$Length = 32)
    
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
    $random = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $random += $chars[(Get-Random -Maximum $chars.Length)]
    }
    return $random
}

# =============================================================================
# MAIN SETUP FUNCTIONS
# =============================================================================

function Initialize-EnvironmentSetup {
    Write-Header "Environment Variable Setup"
    Write-ColorOutput "Setting up environment variables for: $Environment" -Color Info
    
    # Validate environment
    if (-not $EnvConfigs.ContainsKey($Environment)) {
        Write-ColorOutput "Invalid environment: $Environment" -Color Error
        Write-ColorOutput "Valid environments: development, staging, production" -Color Info
        exit 1
    }
    
    # Get configuration
    $config = $EnvConfigs[$Environment]
    
    # Override URLs if provided
    if (![string]::IsNullOrEmpty($BackendUrl)) {
        $config.BackendUrl = $BackendUrl
    }
    if (![string]::IsNullOrEmpty($FrontendUrl)) {
        $config.FrontendUrl = $FrontendUrl
    }
    
    return $config
}

function Create-BackendEnvironmentFile {
    param($Config)
    
    Write-Header "Creating Backend Environment File"
    
    $backendEnvPath = "backend\.env"
    $backendEnvTemplate = @"
# Backend Environment Variables - $Environment
# Generated on $(Get-Date)

# Server Configuration
PORT=8000
HOST=0.0.0.0
DEBUG=$($Config.Debug)
LOG_LEVEL=$($Config.LogLevel)

# CORS Configuration
CORS_ORIGINS=$($Config.CORSOrigins)
CORS_ALLOW_CREDENTIALS=true
CORS_ALLOW_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOW_HEADERS=Content-Type,Authorization

# File Upload Configuration
MAX_FILE_SIZE=100MB
UPLOAD_DIR=videos
TEMP_DIR=/tmp

# Video Processing Configuration
FFMPEG_PATH=/usr/bin/ffmpeg
REALESRGAN_PATH=/usr/local/bin/realesrgan
REALESRGAN_MODEL=realesrgan-x4plus-anime_6B
VIDEO_SCALE_FACTORS=2,4
SUPPORTED_FORMATS=mp4,avi,mov,mkv,webm

# Security Configuration
API_KEY=$(Generate-RandomSecret 32)
JWT_SECRET=$(Generate-RandomSecret 64)
SESSION_SECRET=$(Generate-RandomSecret 32)

# Rate Limiting
RATE_LIMIT_REQUESTS=100
RATE_LIMIT_WINDOW=900

# Monitoring & Logging
LOG_FILE=logs/app.log
LOG_MAX_SIZE=10MB
LOG_BACKUP_COUNT=5
HEALTH_CHECK_INTERVAL=30
HEALTH_CHECK_TIMEOUT=10

# Feature Flags
ENABLE_AUDIO_ANALYSIS=true
ENABLE_VIDEO_PREVIEW=true
ENABLE_BATCH_PROCESSING=false
"@
    
    if (Test-EnvironmentFile $backendEnvPath) {
        $backendEnvTemplate | Out-File -FilePath $backendEnvPath -Encoding UTF8
        Write-ColorOutput "✓ Backend environment file created: $backendEnvPath" -Color Success
    }
    else {
        Write-ColorOutput "✗ Backend environment file creation skipped" -Color Warning
    }
}

function Create-FrontendEnvironmentFile {
    param($Config)
    
    Write-Header "Creating Frontend Environment File"
    
    $frontendEnvPath = "frontend\.env.local"
    $frontendEnvTemplate = @"
# Frontend Environment Variables - $Environment
# Generated on $(Get-Date)

# API Configuration
NEXT_PUBLIC_API_URL=$($Config.BackendUrl)
NEXT_PUBLIC_APP_NAME=Gold Star Evolution Enhancer
NEXT_PUBLIC_APP_VERSION=1.0.0

# Frontend Build Configuration
NEXT_PUBLIC_ENVIRONMENT=$Environment
NEXT_PUBLIC_DEBUG=$($Config.Debug)

# Development Server (for development only)
DEV_SERVER_PORT=3000
DEV_SERVER_HOST=localhost
HOT_RELOAD=true
WATCH_DIRS=backend,frontend
"@
    
    if (Test-EnvironmentFile $frontendEnvPath) {
        $frontendEnvTemplate | Out-File -FilePath $frontendEnvPath -Encoding UTF8
        Write-ColorOutput "✓ Frontend environment file created: $frontendEnvPath" -Color Success
    }
    else {
        Write-ColorOutput "✗ Frontend environment file creation skipped" -Color Warning
    }
}

function Create-RootEnvironmentFile {
    param($Config)
    
    Write-Header "Creating Root Environment File"
    
    $rootEnvPath = ".env"
    $rootEnvTemplate = @"
# Root Environment Variables - $Environment
# Generated on $(Get-Date)

# Environment Configuration
ENVIRONMENT=$Environment
NODE_ENV=$(if ($Environment -eq "production") { "production" } else { "development" })

# Backend Configuration
BACKEND_URL=$($Config.BackendUrl)
BACKEND_PORT=8000

# Frontend Configuration
FRONTEND_URL=$($Config.FrontendUrl)
FRONTEND_PORT=3000

# Deployment Configuration
RENDER_SERVICE_NAME=video-enhancer-backend
RENDER_REGION=oregon
RENDER_PLAN=starter
VERCEL_PROJECT_NAME=video-enhancer-frontend

# Development Tools
DEV_SERVER_PORT=3000
DEV_SERVER_HOST=localhost
HOT_RELOAD=true
WATCH_DIRS=backend,frontend
"@
    
    if (Test-EnvironmentFile $rootEnvPath) {
        $rootEnvTemplate | Out-File -FilePath $rootEnvPath -Encoding UTF8
        Write-ColorOutput "✓ Root environment file created: $rootEnvPath" -Color Success
    }
    else {
        Write-ColorOutput "✗ Root environment file creation skipped" -Color Warning
    }
}

function Update-GitIgnore {
    Write-Header "Updating .gitignore"
    
    $gitignorePath = ".gitignore"
    $envPatterns = @(
        "# Environment files",
        ".env",
        ".env.local",
        ".env.development",
        ".env.production",
        "backend/.env",
        "frontend/.env.local",
        "frontend/.env.development",
        "frontend/.env.production"
    )
    
    if (Test-Path $gitignorePath) {
        $content = Get-Content $gitignorePath -Raw
        foreach ($pattern in $envPatterns) {
            if ($content -notmatch [regex]::Escape($pattern)) {
                Add-Content $gitignorePath "`n$pattern"
            }
        }
        Write-ColorOutput "✓ .gitignore updated with environment file patterns" -Color Success
    }
    else {
        $envPatterns | Out-File -FilePath $gitignorePath -Encoding UTF8
        Write-ColorOutput "✓ .gitignore created with environment file patterns" -Color Success
    }
}

function Test-EnvironmentSetup {
    Write-Header "Testing Environment Setup"
    
    $tests = @(
        @{ Name = "Backend .env"; Path = "backend\.env" },
        @{ Name = "Frontend .env.local"; Path = "frontend\.env.local" },
        @{ Name = "Root .env"; Path = ".env" }
    )
    
    $allPassed = $true
    
    foreach ($test in $tests) {
        if (Test-Path $test.Path) {
            Write-ColorOutput "✓ $($test.Name) exists" -Color Success
        }
        else {
            Write-ColorOutput "✗ $($test.Name) missing" -Color Error
            $allPassed = $false
        }
    }
    
    if ($allPassed) {
        Write-ColorOutput "`n✓ All environment files created successfully!" -Color Success
    }
    else {
        Write-ColorOutput "`n✗ Some environment files are missing" -Color Error
    }
    
    return $allPassed
}

function Show-EnvironmentSummary {
    param($Config)
    
    Write-Header "Environment Setup Summary"
    
    Write-ColorOutput "Environment: $Environment" -Color Info
    Write-ColorOutput "Backend URL: $($Config.BackendUrl)" -Color Info
    Write-ColorOutput "Frontend URL: $($Config.FrontendUrl)" -Color Info
    Write-ColorOutput "Debug Mode: $($Config.Debug)" -Color Info
    Write-ColorOutput "Log Level: $($Config.LogLevel)" -Color Info
    Write-ColorOutput "CORS Origins: $($Config.CORSOrigins)" -Color Info
    
    Write-ColorOutput "`nFiles Created:" -Color Info
    Write-ColorOutput "  • backend\.env" -Color Success
    Write-ColorOutput "  • frontend\.env.local" -Color Success
    Write-ColorOutput "  • .env" -Color Success
    
    Write-ColorOutput "`nNext Steps:" -Color Info
    Write-ColorOutput "  1. Review the generated environment files" -Color Info
    Write-ColorOutput "  2. Update any specific values as needed" -Color Info
    Write-ColorOutput "  3. Start your development servers" -Color Info
    Write-ColorOutput "  4. For production, update URLs in the environment files" -Color Info
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

try {
    # Initialize setup
    $config = Initialize-EnvironmentSetup
    
    # Create environment files
    Create-BackendEnvironmentFile -Config $config
    Create-FrontendEnvironmentFile -Config $config
    Create-RootEnvironmentFile -Config $config
    
    # Update .gitignore
    Update-GitIgnore
    
    # Test setup
    $setupSuccess = Test-EnvironmentSetup
    
    # Show summary
    Show-EnvironmentSummary -Config $config
    
    if ($setupSuccess) {
        Write-ColorOutput "`n🎉 Environment setup completed successfully!" -Color Success
        exit 0
    }
    else {
        Write-ColorOutput "`n⚠️  Environment setup completed with warnings" -Color Warning
        exit 1
    }
}
catch {
    Write-ColorOutput "`n❌ Environment setup failed: $($_.Exception.Message)" -Color Error
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" -Color Error
    exit 1
} 