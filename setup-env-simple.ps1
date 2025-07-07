# =============================================================================
# SIMPLIFIED ENVIRONMENT VARIABLE SETUP
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "production", "staging")]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$false)]
    [string]$BackendUrl = "",
    
    [Parameter(Mandatory=$false)]
    [string]$FrontendUrl = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Blue"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    param([string]$Title)
    Write-ColorOutput "`n================================================" $Blue
    Write-ColorOutput " $Title" $Blue
    Write-ColorOutput "================================================" $Blue
    Write-ColorOutput ""
}

# Environment configurations
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

function Test-EnvironmentFile {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        if ($Force) {
            Write-ColorOutput "Environment file exists. Overwriting due to -Force flag." $Yellow
            return $true
        }
        else {
            $response = Read-Host "Environment file already exists. Overwrite? (y/N)"
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

# Main execution
try {
    Write-Header "Environment Variable Setup"
    Write-ColorOutput "Setting up environment variables for: $Environment" $Blue
    
    # Get configuration
    $config = $EnvConfigs[$Environment]
    
    # Override URLs if provided
    if (![string]::IsNullOrEmpty($BackendUrl)) {
        $config.BackendUrl = $BackendUrl
    }
    if (![string]::IsNullOrEmpty($FrontendUrl)) {
        $config.FrontendUrl = $FrontendUrl
    }
    
    # Create backend environment file
    Write-Header "Creating Backend Environment File"
    $backendEnvPath = "backend\.env"
    
    if (Test-EnvironmentFile $backendEnvPath) {
        $backendContent = @"
# Backend Environment Variables - $Environment
# Generated on $(Get-Date)

# Server Configuration
PORT=8000
HOST=0.0.0.0
DEBUG=$($config.Debug)
LOG_LEVEL=$($config.LogLevel)

# CORS Configuration
CORS_ORIGINS=$($config.CORSOrigins)
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
        
        $backendContent | Out-File -FilePath $backendEnvPath -Encoding UTF8
        Write-ColorOutput "✓ Backend environment file created: $backendEnvPath" $Green
    }
    else {
        Write-ColorOutput "✗ Backend environment file creation skipped" $Yellow
    }
    
    # Create frontend environment file
    Write-Header "Creating Frontend Environment File"
    $frontendEnvPath = "frontend\.env.local"
    
    if (Test-EnvironmentFile $frontendEnvPath) {
        $frontendContent = @"
# Frontend Environment Variables - $Environment
# Generated on $(Get-Date)

# API Configuration
NEXT_PUBLIC_API_URL=$($config.BackendUrl)
NEXT_PUBLIC_APP_NAME=Gold Star Evolution Enhancer
NEXT_PUBLIC_APP_VERSION=1.0.0

# Frontend Build Configuration
NEXT_PUBLIC_ENVIRONMENT=$Environment
NEXT_PUBLIC_DEBUG=$($config.Debug)

# Development Server (for development only)
DEV_SERVER_PORT=3000
DEV_SERVER_HOST=localhost
HOT_RELOAD=true
WATCH_DIRS=backend,frontend
"@
        
        $frontendContent | Out-File -FilePath $frontendEnvPath -Encoding UTF8
        Write-ColorOutput "✓ Frontend environment file created: $frontendEnvPath" $Green
    }
    else {
        Write-ColorOutput "✗ Frontend environment file creation skipped" $Yellow
    }
    
    # Create root environment file
    Write-Header "Creating Root Environment File"
    $rootEnvPath = ".env"
    
    if (Test-EnvironmentFile $rootEnvPath) {
        $nodeEnv = if ($Environment -eq "production") { "production" } else { "development" }
        $rootContent = @"
# Root Environment Variables - $Environment
# Generated on $(Get-Date)

# Environment Configuration
ENVIRONMENT=$Environment
NODE_ENV=$nodeEnv

# Backend Configuration
BACKEND_URL=$($config.BackendUrl)
BACKEND_PORT=8000

# Frontend Configuration
FRONTEND_URL=$($config.FrontendUrl)
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
        
        $rootContent | Out-File -FilePath $rootEnvPath -Encoding UTF8
        Write-ColorOutput "✓ Root environment file created: $rootEnvPath" $Green
    }
    else {
        Write-ColorOutput "✗ Root environment file creation skipped" $Yellow
    }
    
    # Update .gitignore
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
        Write-ColorOutput "✓ .gitignore updated with environment file patterns" $Green
    }
    else {
        $envPatterns | Out-File -FilePath $gitignorePath -Encoding UTF8
        Write-ColorOutput "✓ .gitignore created with environment file patterns" $Green
    }
    
    # Summary
    Write-Header "Environment Setup Summary"
    Write-ColorOutput "Environment: $Environment" $Blue
    Write-ColorOutput "Backend URL: $($config.BackendUrl)" $Blue
    Write-ColorOutput "Frontend URL: $($config.FrontendUrl)" $Blue
    Write-ColorOutput "Debug Mode: $($config.Debug)" $Blue
    Write-ColorOutput "Log Level: $($config.LogLevel)" $Blue
    
    Write-ColorOutput "`nFiles Created:" $Blue
    Write-ColorOutput "  • backend\.env" $Green
    Write-ColorOutput "  • frontend\.env.local" $Green
    Write-ColorOutput "  • .env" $Green
    
    Write-ColorOutput "`nNext Steps:" $Blue
    Write-ColorOutput "  1. Review the generated environment files" $Blue
    Write-ColorOutput "  2. Update any specific values as needed" $Blue
    Write-ColorOutput "  3. Start your development servers" $Blue
    Write-ColorOutput "  4. For production, update URLs in the environment files" $Blue
    
    Write-ColorOutput "`n🎉 Environment setup completed successfully!" $Green
    exit 0
}
catch {
    Write-ColorOutput "`n❌ Environment setup failed: $($_.Exception.Message)" $Red
    exit 1
} 