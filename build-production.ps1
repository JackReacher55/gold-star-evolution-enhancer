# Production Build Script
Write-Host "🏗️ Building Gold Star Evolution Enhancer for Production" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

# Build frontend
Write-Host "Building frontend..." -ForegroundColor Yellow
Set-Location frontend

# Create production environment file
$prodEnvContent = @"
# Production Environment Configuration
# Update this URL to your production backend
NEXT_PUBLIC_API_URL=https://your-backend-domain.com
"@

$prodEnvPath = ".env.production"
$prodEnvContent | Out-File -FilePath $prodEnvPath -Encoding UTF8
Write-Host "✓ Created production environment file" -ForegroundColor Green

# Install dependencies and build
npm install
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend built successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend build failed!" -ForegroundColor Red
    exit 1
}

Set-Location ..

# Create production package
Write-Host "Creating production package..." -ForegroundColor Yellow

$buildDir = "production-build"
if (Test-Path $buildDir) {
    Remove-Item $buildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $buildDir

# Copy backend files
Write-Host "Copying backend files..." -ForegroundColor Yellow
Copy-Item "backend" -Destination "$buildDir\backend" -Recurse
Copy-Item "videos" -Destination "$buildDir\videos" -Recurse -ErrorAction SilentlyContinue
Copy-Item "realesrgan-ncnn-vulkan.exe" -Destination "$buildDir\" -ErrorAction SilentlyContinue

# Copy frontend build
Write-Host "Copying frontend build..." -ForegroundColor Yellow
Copy-Item "frontend\.next" -Destination "$buildDir\frontend\.next" -Recurse
Copy-Item "frontend\public" -Destination "$buildDir\frontend\public" -Recurse -ErrorAction SilentlyContinue
Copy-Item "frontend\package.json" -Destination "$buildDir\frontend\"
Copy-Item "frontend\next.config.js" -Destination "$buildDir\frontend\"

# Copy configuration files
Copy-Item "render.yaml" -Destination "$buildDir\" -ErrorAction SilentlyContinue
Copy-Item "vercel.json" -Destination "$buildDir\frontend\" -ErrorAction SilentlyContinue

# Create production startup script
$prodStartScript = @"
# Production Startup Script
Write-Host "Starting Gold Star Evolution Enhancer in Production Mode" -ForegroundColor Green

# Start backend
Write-Host "Starting backend server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; python backend/app.py" -WindowStyle Normal

# Start frontend
Write-Host "Starting frontend server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\frontend'; npm start" -WindowStyle Normal

Write-Host "Production servers started!" -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:8000" -ForegroundColor Cyan
"@

$prodStartScript | Out-File -FilePath "$buildDir\start-production.ps1" -Encoding UTF8

# Create README for production
$prodReadme = @"
# Gold Star Evolution Enhancer - Production Build

## Quick Start

1. Install Python dependencies:
   ```
   pip install -r backend/requirements.txt
   ```

2. Install Node.js dependencies:
   ```
   cd frontend
   npm install
   ```

3. Start the application:
   ```
   .\start-production.ps1
   ```

## Configuration

- Update `frontend\.env.production` with your backend URL
- Configure environment variables in `backend\config.py`

## Deployment

- **Vercel**: Deploy the `frontend` folder
- **Render**: Use the `render.yaml` configuration
- **AWS**: Use the AWS deployment guide

## Features

- AI-powered video upscaling
- Audio analysis and fixing
- Multiple resolution support
- Real-time processing
"@

$prodReadme | Out-File -FilePath "$buildDir\README.md" -Encoding UTF8

Write-Host "✓ Production build created in '$buildDir' folder!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update the backend URL in frontend\.env.production" -ForegroundColor White
Write-Host "2. Deploy backend to your hosting service" -ForegroundColor White
Write-Host "3. Deploy frontend to Vercel or your preferred hosting" -ForegroundColor White
Write-Host "4. Update environment variables for production" -ForegroundColor White 