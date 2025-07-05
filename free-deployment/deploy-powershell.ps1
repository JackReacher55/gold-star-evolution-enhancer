# Gold Star Evolution Enhancer - PowerShell Deployment Script
# Domain: goldstarevolutionenhancer.com

Write-Host "🌟 Gold Star Evolution Enhancer - PowerShell Deployment" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "🎯 Domain: goldstarevolutionenhancer.com" -ForegroundColor Cyan
Write-Host "💰 Cost: `$0/month" -ForegroundColor Green
Write-Host ""

# Check if frontend is built
if (-not (Test-Path "frontend\.next")) {
    Write-Host "🔨 Building frontend..." -ForegroundColor Yellow
    Set-Location frontend
    npm install
    npm run build
    Set-Location ..
    Write-Host "✅ Frontend built successfully!" -ForegroundColor Green
} else {
    Write-Host "✅ Frontend already built!" -ForegroundColor Green
}
Write-Host ""

# Create deployment packages
Write-Host "📦 Creating deployment packages..." -ForegroundColor Yellow

# Frontend package
if (Test-Path "deploy-frontend") {
    Remove-Item "deploy-frontend" -Recurse -Force
}
New-Item -ItemType Directory -Name "deploy-frontend" | Out-Null
Copy-Item "frontend\*" "deploy-frontend\" -Recurse -Force
Write-Host "✅ Frontend package created!" -ForegroundColor Green

# Backend package
if (Test-Path "deploy-backend") {
    Remove-Item "deploy-backend" -Recurse -Force
}
New-Item -ItemType Directory -Name "deploy-backend" | Out-Null
Copy-Item "backend\*" "deploy-backend\" -Recurse -Force
Write-Host "✅ Backend package created!" -ForegroundColor Green
Write-Host ""

Write-Host "🎯 AUTOMATED DEPLOYMENT READY!" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow
Write-Host ""

Write-Host "📱 FRONTEND DEPLOYMENT (Vercel):" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open: https://vercel.com" -ForegroundColor White
Write-Host "2. Click 'New Project'" -ForegroundColor White
Write-Host "3. Click 'Upload'" -ForegroundColor White
Write-Host "4. Select the 'deploy-frontend' folder from your project" -ForegroundColor White
Write-Host "5. Configure:" -ForegroundColor White
Write-Host "   - Project Name: goldstar-evolution-enhancer" -ForegroundColor White
Write-Host "   - Framework Preset: Next.js" -ForegroundColor White
Write-Host "   - Root Directory: ./" -ForegroundColor White
Write-Host "6. Click 'Deploy'" -ForegroundColor White
Write-Host "7. Wait 2-5 minutes for deployment" -ForegroundColor White
Write-Host "8. Copy your Vercel URL" -ForegroundColor White
Write-Host ""

$frontendUrl = Read-Host "Enter your Vercel URL"

Write-Host ""
Write-Host "🔧 BACKEND DEPLOYMENT (Render):" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open: https://render.com" -ForegroundColor White
Write-Host "2. Click 'New Web Service'" -ForegroundColor White
Write-Host "3. Click 'Upload'" -ForegroundColor White
Write-Host "4. Select the 'deploy-backend' folder from your project" -ForegroundColor White
Write-Host "5. Configure settings:" -ForegroundColor White
Write-Host "   - Name: goldstar-evolution-enhancer-backend" -ForegroundColor White
Write-Host "   - Root Directory: ./" -ForegroundColor White
Write-Host "   - Runtime: Python 3" -ForegroundColor White
Write-Host "   - Build Command: pip install -r requirements.txt" -ForegroundColor White
Write-Host "   - Start Command: uvicorn main:app --host 0.0.0.0 --port `$PORT" -ForegroundColor White
Write-Host "6. Add Environment Variable:" -ForegroundColor White
Write-Host "   - Key: CORS_ORIGINS" -ForegroundColor White
Write-Host "   - Value: $frontendUrl" -ForegroundColor White
Write-Host "7. Click 'Create Web Service'" -ForegroundColor White
Write-Host "8. Wait 5-10 minutes for deployment" -ForegroundColor White
Write-Host "9. Copy your Render URL" -ForegroundColor White
Write-Host ""

$backendUrl = Read-Host "Enter your Render URL"

Write-Host ""
Write-Host "🔗 CONNECTING FRONTEND TO BACKEND:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Go back to Vercel dashboard" -ForegroundColor White
Write-Host "2. Select your goldstar-evolution-enhancer project" -ForegroundColor White
Write-Host "3. Go to Settings → Environment Variables" -ForegroundColor White
Write-Host "4. Add new environment variable:" -ForegroundColor White
Write-Host "   - Name: NEXT_PUBLIC_API_URL" -ForegroundColor White
Write-Host "   - Value: $backendUrl" -ForegroundColor White
Write-Host "5. Click 'Save'" -ForegroundColor White
Write-Host "6. Go to Deployments tab" -ForegroundColor White
Write-Host "7. Click 'Redeploy' on the latest deployment" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter when connection is complete"

Write-Host ""
Write-Host "🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green
Write-Host ""
Write-Host "🌟 Your Gold Star Evolution Enhancer is now live!" -ForegroundColor Yellow
Write-Host ""
Write-Host "📱 Your Live URLs:" -ForegroundColor Cyan
Write-Host "Frontend: $frontendUrl" -ForegroundColor White
Write-Host "Backend: $backendUrl" -ForegroundColor White
Write-Host ""
Write-Host "🌐 Custom Domain (if configured):" -ForegroundColor Cyan
Write-Host "https://goldstarevolutionenhancer.com" -ForegroundColor White
Write-Host ""
Write-Host "🧪 Test your application:" -ForegroundColor Cyan
Write-Host "1. Open: $frontendUrl" -ForegroundColor White
Write-Host "2. Upload a video file" -ForegroundColor White
Write-Host "3. Select resolution (720p, 1080p, 2K, 4K)" -ForegroundColor White
Write-Host "4. Click '🌟 Enhance Video'" -ForegroundColor White
Write-Host "5. Download your enhanced video!" -ForegroundColor White
Write-Host ""
Write-Host "💰 Total Cost: `$0/month!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Your Gold Star Evolution Enhancer is ready to use!" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 Features Available:" -ForegroundColor Cyan
Write-Host "✅ AI-powered video upscaling" -ForegroundColor Green
Write-Host "✅ Multiple resolution support (720p, 1080p, 2K, 4K)" -ForegroundColor Green
Write-Host "✅ Audio analysis and fixing" -ForegroundColor Green
Write-Host "✅ Professional quality output" -ForegroundColor Green
Write-Host "✅ Beautiful modern UI" -ForegroundColor Green
Write-Host "✅ Drag-and-drop upload" -ForegroundColor Green
Write-Host "✅ Real-time progress tracking" -ForegroundColor Green
Write-Host ""

# Cleanup
Write-Host "🧹 Cleaning up deployment packages..." -ForegroundColor Yellow
if (Test-Path "deploy-frontend") {
    Remove-Item "deploy-frontend" -Recurse -Force
}
if (Test-Path "deploy-backend") {
    Remove-Item "deploy-backend" -Recurse -Force
}
Write-Host "✅ Cleanup complete!" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to exit" 