# Deployment Script with Environment Integration
param(
    [string]$CommitMessage = "Auto-deploy: Update video enhancement features",
    [ValidateSet("development", "production", "staging")]
    [string]$Environment = "production",
    [switch]$SetupEnv,
    [switch]$SkipGitHub,
    [switch]$SkipVercel,
    [switch]$SkipRender,
    [switch]$Force
)

Write-Host "🚀 Starting deployment with environment: $Environment" -ForegroundColor Cyan

# Step 1: Environment Setup (if requested)
if ($SetupEnv) {
    Write-Host "`n🔧 Step 1: Setting up environment variables..." -ForegroundColor Yellow
    & ".\setup-env-basic.ps1" -Environment $Environment -Force:$Force
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Environment setup failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Environment setup completed" -ForegroundColor Green
}

# Step 2: GitHub Deployment
if (-not $SkipGitHub) {
    Write-Host "`n📦 Step 2: GitHub Repository Update" -ForegroundColor Yellow
    
    if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Git not found. Please install Git." -ForegroundColor Red
    }
    else {
        try {
            git add .
            git commit -m $CommitMessage
            git push origin main
            Write-Host "✅ GitHub deployment successful" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ GitHub deployment failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Step 3: Vercel Frontend Deployment
if (-not $SkipVercel) {
    Write-Host "`n🌐 Step 3: Vercel Frontend Deployment" -ForegroundColor Yellow
    
    if (-not (Get-Command "vercel" -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Vercel CLI not found. Installing..." -ForegroundColor Yellow
        try {
            npm install -g vercel
            Write-Host "✅ Vercel CLI installed" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to install Vercel CLI" -ForegroundColor Red
        }
    }
    
    if (Get-Command "vercel" -ErrorAction SilentlyContinue) {
        try {
            Push-Location frontend
            $vercelOutput = vercel --prod --yes 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Vercel deployment successful" -ForegroundColor Green
                $deploymentUrl = $vercelOutput | Select-String "https://.*\.vercel\.app" | ForEach-Object { $_.Matches[0].Value }
                if ($deploymentUrl) {
                    Write-Host "🌐 Frontend URL: $deploymentUrl" -ForegroundColor Green
                }
            }
            else {
                Write-Host "❌ Vercel deployment failed" -ForegroundColor Red
            }
            Pop-Location
        }
        catch {
            Write-Host "❌ Vercel deployment error: $($_.Exception.Message)" -ForegroundColor Red
            Pop-Location
        }
    }
}

# Step 4: Render Backend Deployment
if (-not $SkipRender) {
    Write-Host "`n⚙️  Step 4: Render Backend Deployment" -ForegroundColor Yellow
    
    if (-not (Get-Command "render" -ErrorAction SilentlyContinue)) {
        Write-Host "⚠️  Render CLI not found. Please install manually:" -ForegroundColor Yellow
        Write-Host "   Visit: https://render.com/docs/cli" -ForegroundColor Yellow
    }
    else {
        try {
            $renderOutput = render deploy --service video-enhancer-backend 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Render deployment successful" -ForegroundColor Green
            }
            else {
                Write-Host "❌ Render deployment failed" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ Render deployment error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n🎯 Deployment Summary" -ForegroundColor Cyan
Write-Host "Environment: $Environment" -ForegroundColor White
Write-Host "✅ Deployment completed!" -ForegroundColor Green 