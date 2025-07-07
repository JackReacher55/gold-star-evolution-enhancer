# Quick Deployment Script
# Simple deployment for immediate use

param(
    [string]$CommitMessage = "Auto-deploy: Update video enhancement features"
)

Write-Host "Quick Deployment Script" -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue

# 1. Git initialization if missing
gitDir = ".git"
if (-not (Test-Path $gitDir)) {
    Write-Host "Git repository not found. Initializing..." -ForegroundColor Yellow
    git init
    $remoteUrl = Read-Host "Enter your GitHub remote URL (or leave blank to skip)"
    if ($remoteUrl) {
        git remote add origin $remoteUrl
    }
}

# 2. Python venv setup if missing
if (-not (Test-Path "venv")) {
    Write-Host "Python virtual environment not found. Creating..." -ForegroundColor Yellow
    python -m venv venv
}

# 3. Backend dependency install
Write-Host "Ensuring backend dependencies are installed..." -ForegroundColor Yellow
.\venv\Scripts\activate
pip install --upgrade pip
pip install -r backend/requirements.txt

# 4. Frontend dependency install
if (-not (Test-Path "frontend/node_modules")) {
    Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
    Push-Location frontend
    npm install
    Pop-Location
}

# 5. Vercel CLI install if missing
if (-not (Get-Command "vercel" -ErrorAction SilentlyContinue)) {
    Write-Host "Vercel CLI not found. Installing..." -ForegroundColor Yellow
    npm install -g vercel
}

# 6. Render CLI install if missing (optional)
if (-not (Get-Command "render" -ErrorAction SilentlyContinue)) {
    Write-Host "Render CLI not found. (Optional) See https://render.com/docs/cli for install instructions." -ForegroundColor Yellow
}

# 7. Check for changes
git status --porcelain | Out-String -OutVariable status
if ($status.Length -eq 0) {
    Write-Host "No changes to commit." -ForegroundColor Yellow
    $commit = Read-Host "Do you want to deploy anyway? (y/N)"
    if ($commit -ne "y" -and $commit -ne "Y") {
        exit 0
    }
}

# 8. Git operations
Write-Host "Committing changes..." -ForegroundColor Yellow
git add .
git commit -m $CommitMessage
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push origin main
Write-Host "GitHub update successful!" -ForegroundColor Green

# 9. Vercel deployment
Write-Host "Deploying to Vercel..." -ForegroundColor Yellow
Push-Location frontend
vercel --prod --yes
Pop-Location
Write-Host "Vercel deployment complete!" -ForegroundColor Green

# 10. Render deployment (manual or CLI)
if (Get-Command "render" -ErrorAction SilentlyContinue) {
    Write-Host "Deploying backend to Render via CLI..." -ForegroundColor Yellow
    render deploy --service your-backend-service-name
    Write-Host "Render deployment complete!" -ForegroundColor Green
} else {
    Write-Host "Render deployment:" -ForegroundColor Yellow
    Write-Host "Visit your Render dashboard to trigger deployment" -ForegroundColor Cyan
    Write-Host "Or use the webhook URL if configured" -ForegroundColor Cyan
}

Write-Host "Deployment completed!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Blue
Write-Host "1. Check your Vercel dashboard for frontend URL" -ForegroundColor Blue
Write-Host "2. Check your Render dashboard for backend status" -ForegroundColor Blue
Write-Host "3. Test the video upload functionality" -ForegroundColor Blue 