# Basic Environment Variable Setup
param(
    [string]$Environment = "development",
    [string]$BackendUrl = "",
    [string]$FrontendUrl = "",
    [switch]$Force
)

Write-Host "Setting up environment variables for: $Environment" -ForegroundColor Cyan

# Environment configurations
$configs = @{
    development = @{
        BackendUrl = "http://localhost:8000"
        FrontendUrl = "http://localhost:3000"
        Debug = "true"
        LogLevel = "DEBUG"
        CORSOrigins = "*"
    }
    production = @{
        BackendUrl = "https://your-production-backend.onrender.com"
        FrontendUrl = "https://your-production-frontend.vercel.app"
        Debug = "false"
        LogLevel = "WARNING"
        CORSOrigins = "https://your-production-frontend.vercel.app"
    }
}

$config = $configs[$Environment]

# Override URLs if provided
if ($BackendUrl) { $config.BackendUrl = $BackendUrl }
if ($FrontendUrl) { $config.FrontendUrl = $FrontendUrl }

# Create backend .env
Write-Host "Creating backend environment file..." -ForegroundColor Yellow
$backendContent = @"
# Backend Environment Variables - $Environment
PORT=8000
HOST=0.0.0.0
DEBUG=$($config.Debug)
LOG_LEVEL=$($config.LogLevel)
CORS_ORIGINS=$($config.CORSOrigins)
MAX_FILE_SIZE=100MB
UPLOAD_DIR=videos
FFMPEG_PATH=/usr/bin/ffmpeg
REALESRGAN_PATH=/usr/local/bin/realesrgan
API_KEY=your-api-key-here
JWT_SECRET=your-jwt-secret-here
"@

if (-not (Test-Path "backend\.env") -or $Force) {
    $backendContent | Out-File -FilePath "backend\.env" -Encoding UTF8
    Write-Host "Backend environment file created" -ForegroundColor Green
}

# Create frontend .env.local
Write-Host "Creating frontend environment file..." -ForegroundColor Yellow
$frontendContent = @"
# Frontend Environment Variables - $Environment
NEXT_PUBLIC_API_URL=$($config.BackendUrl)
NEXT_PUBLIC_APP_NAME=Gold Star Evolution Enhancer
NEXT_PUBLIC_APP_VERSION=1.0.0
NEXT_PUBLIC_ENVIRONMENT=$Environment
NEXT_PUBLIC_DEBUG=$($config.Debug)
"@

if (-not (Test-Path "frontend\.env.local") -or $Force) {
    $frontendContent | Out-File -FilePath "frontend\.env.local" -Encoding UTF8
    Write-Host "Frontend environment file created" -ForegroundColor Green
}

# Create root .env
Write-Host "Creating root environment file..." -ForegroundColor Yellow
$rootContent = @"
# Root Environment Variables - $Environment
ENVIRONMENT=$Environment
NODE_ENV=$(if ($Environment -eq "production") { "production" } else { "development" })
BACKEND_URL=$($config.BackendUrl)
FRONTEND_URL=$($config.FrontendUrl)
"@

if (-not (Test-Path ".env") -or $Force) {
    $rootContent | Out-File -FilePath ".env" -Encoding UTF8
    Write-Host "Root environment file created" -ForegroundColor Green
}

# Update .gitignore
Write-Host "Updating .gitignore..." -ForegroundColor Yellow
$envPatterns = @(".env", ".env.local", "backend/.env", "frontend/.env.local")
foreach ($pattern in $envPatterns) {
    if (Test-Path ".gitignore") {
        $content = Get-Content ".gitignore" -Raw
        if ($content -notmatch [regex]::Escape($pattern)) {
            Add-Content ".gitignore" "`n$pattern"
        }
    }
    else {
        $envPatterns | Out-File -FilePath ".gitignore" -Encoding UTF8
        break
    }
}

Write-Host "Environment setup completed!" -ForegroundColor Green
Write-Host "Files created:" -ForegroundColor Cyan
Write-Host "  - backend\.env" -ForegroundColor White
Write-Host "  - frontend\.env.local" -ForegroundColor White
Write-Host "  - .env" -ForegroundColor White 