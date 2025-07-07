# Complete Application Startup Script
Write-Host "🚀 Starting Gold Star Evolution Enhancer" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Check if backend is already running
$backendRunning = $false
try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -TimeoutSec 2 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        $backendRunning = $true
        Write-Host "✓ Backend is already running on port 8000" -ForegroundColor Green
    }
} catch {
    Write-Host "Backend not running, starting it..." -ForegroundColor Yellow
}

# Start backend if not running
if (-not $backendRunning) {
    Write-Host "Starting backend server..." -ForegroundColor Yellow
    
    # Activate virtual environment and start backend
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; venv\Scripts\activate; python run_backend.py" -WindowStyle Normal
    
    # Wait for backend to start
    Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Test backend connection
    $retries = 0
    while ($retries -lt 10) {
        try {
            $response = Invoke-WebRequest -Uri "http://127.0.0.1:8000/health" -TimeoutSec 2 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Host "✓ Backend started successfully!" -ForegroundColor Green
                break
            }
        } catch {
            $retries++
            Write-Host "Waiting for backend... (attempt $retries/10)" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
    
    if ($retries -eq 10) {
        Write-Host "❌ Failed to start backend. Please check the backend window for errors." -ForegroundColor Red
        exit 1
    }
}

# Setup frontend environment
Write-Host "Setting up frontend..." -ForegroundColor Yellow

# Create .env.local file
$envContent = @"
# Frontend Environment Configuration
# Backend API URL
NEXT_PUBLIC_API_URL=http://localhost:8000

# For production deployment, change to your backend URL:
# NEXT_PUBLIC_API_URL=https://your-backend-domain.com
"@

$envPath = "frontend\.env.local"
$envContent | Out-File -FilePath $envPath -Encoding UTF8
Write-Host "✓ Created frontend environment file" -ForegroundColor Green

# Install frontend dependencies if needed
if (-not (Test-Path "frontend\node_modules")) {
    Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
    Set-Location frontend
    npm install
    Set-Location ..
    Write-Host "✓ Frontend dependencies installed" -ForegroundColor Green
}

# Start frontend
Write-Host "Starting frontend development server..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\frontend'; npm run dev" -WindowStyle Normal

# Wait a moment for frontend to start
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "🎉 Application is starting up!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend API: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Backend Health: http://localhost:8000/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "Both servers are running in separate windows." -ForegroundColor Yellow
Write-Host "Close those windows to stop the servers." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to open the frontend in your browser..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open frontend in browser
Start-Process "http://localhost:3000" 