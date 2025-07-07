# Frontend Setup Script
Write-Host "Setting up frontend environment..." -ForegroundColor Green

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
Write-Host "✓ Created $envPath" -ForegroundColor Green

# Install frontend dependencies
Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
Set-Location frontend
npm install

# Start frontend development server
Write-Host "Starting frontend development server..." -ForegroundColor Green
Write-Host "Frontend will be available at: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend is running at: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow

npm run dev 