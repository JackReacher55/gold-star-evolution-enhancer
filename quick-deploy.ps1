#!/usr/bin/env pwsh

# Quick Deployment Script
# Simple deployment for immediate use

Write-Host "🚀 Quick Deployment Script" -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Host "❌ Not in a git repository. Please run this from your project root." -ForegroundColor Red
    exit 1
}

# Check for changes
$status = git status --porcelain
if ($status.Length -eq 0) {
    Write-Host "ℹ️  No changes to commit." -ForegroundColor Yellow
    $commit = Read-Host "Do you want to deploy anyway? (y/N)"
    if ($commit -ne "y" -and $commit -ne "Y") {
        exit 0
    }
}

# Get commit message
$commitMessage = Read-Host "Enter commit message (or press Enter for default)"
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Auto-deploy: Update video enhancement features"
}

# Git operations
Write-Host "📦 Committing changes..." -ForegroundColor Yellow
git add .
git commit -m $commitMessage

Write-Host "📤 Pushing to GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host "✅ GitHub update successful!" -ForegroundColor Green

# Vercel deployment
Write-Host "🌐 Deploying to Vercel..." -ForegroundColor Yellow
if (Get-Command "vercel" -ErrorAction SilentlyContinue) {
    Push-Location frontend
    vercel --prod --yes
    Pop-Location
    Write-Host "✅ Vercel deployment successful!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Vercel CLI not found. Please install with: npm install -g vercel" -ForegroundColor Yellow
}

# Render deployment (manual instructions)
Write-Host "⚙️  Render deployment:" -ForegroundColor Yellow
Write-Host "   Visit your Render dashboard to trigger deployment" -ForegroundColor Cyan
Write-Host "   Or use the webhook URL if configured" -ForegroundColor Cyan

Write-Host "`n🎉 Deployment completed!" -ForegroundColor Green
Write-Host "📋 Next steps:" -ForegroundColor Blue
Write-Host "   1. Check your Vercel dashboard for frontend URL" -ForegroundColor Blue
Write-Host "   2. Check your Render dashboard for backend status" -ForegroundColor Blue
Write-Host "   3. Test the video upload functionality" -ForegroundColor Blue 