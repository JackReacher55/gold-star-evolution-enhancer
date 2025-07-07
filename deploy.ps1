#!/usr/bin/env pwsh

# Comprehensive Deployment Script for Video Enhancer Project
# Handles GitHub, Vercel, and Render deployments with environment automation

param(
    [string]$CommitMessage = "Auto-deploy: Update video enhancement features",
    [switch]$SkipGitHub,
    [switch]$SkipVercel,
    [switch]$SkipRender,
    [switch]$Force,
    [switch]$SetupEnv,
    [ValidateSet("development", "staging", "production")]
    [string]$Environment = "production"
)

# Colors for output
$Green = "`e[32m"
$Red = "`e[31m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = $Reset)
    Write-Host "$Color$Message$Reset"
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

function Test-GitStatus {
    try {
        $status = git status --porcelain
        return $status.Length -gt 0
    }
    catch {
        return $false
    }
}

function Test-GitRemote {
    try {
        $remotes = git remote -v
        return $remotes -match "origin"
    }
    catch {
        return $false
    }
}

function Setup-Environment {
    Write-ColorOutput "`n🔧 Setting up environment variables..." $Blue
    
    if (Test-Path "setup-env.ps1") {
        try {
            $envArgs = @("-Environment", $Environment)
            if ($Force) { $envArgs += "-Force" }
            
            & ".\setup-env.ps1" @envArgs
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Environment setup completed" $Green
                return $true
            }
            else {
                Write-ColorOutput "❌ Environment setup failed" $Red
                return $false
            }
        }
        catch {
            Write-ColorOutput "❌ Environment setup error: $($_.Exception.Message)" $Red
            return $false
        }
    }
    else {
        Write-ColorOutput "❌ setup-env.ps1 not found" $Red
        return $false
    }
}

function Validate-Environment {
    Write-ColorOutput "`n🔍 Validating environment configuration..." $Blue
    
    if (Test-Path "env-validator.ps1") {
        try {
            $validationArgs = @("-Environment", "all")
            if ($Force) { $validationArgs += "-Fix" }
            
            & ".\env-validator.ps1" @validationArgs
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Environment validation passed" $Green
                return $true
            }
            else {
                Write-ColorOutput "❌ Environment validation failed" $Red
                return $false
            }
        }
        catch {
            Write-ColorOutput "❌ Environment validation error: $($_.Exception.Message)" $Red
            return $false
        }
    }
    else {
        Write-ColorOutput "⚠️  env-validator.ps1 not found, skipping validation" $Yellow
        return $true
    }
}

function Deploy-Environment {
    Write-ColorOutput "`n🚀 Deploying environment variables..." $Blue
    
    if (Test-Path "deploy-env.ps1") {
        try {
            $deployArgs = @("-Target", "both", "-Environment", $Environment)
            if ($Force) { $deployArgs += "-Force" }
            
            & ".\deploy-env.ps1" @deployArgs
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Environment deployment completed" $Green
                return $true
            }
            else {
                Write-ColorOutput "❌ Environment deployment failed" $Red
                return $false
            }
        }
        catch {
            Write-ColorOutput "❌ Environment deployment error: $($_.Exception.Message)" $Red
            return $false
        }
    }
    else {
        Write-ColorOutput "⚠️  deploy-env.ps1 not found, skipping environment deployment" $Yellow
        return $true
    }
}

# Main deployment function
function Start-Deployment {
    Write-ColorOutput "🚀 Starting comprehensive deployment..." $Blue
    Write-ColorOutput "================================================" $Blue
    Write-ColorOutput "Environment: $Environment" $Blue
    
    $startTime = Get-Date
    $errors = @()
    $successes = @()
    
    # 0. Environment Setup (if requested)
    if ($SetupEnv) {
        Write-ColorOutput "`n🔧 Step 0: Environment Setup" $Yellow
        
        $envSetupSuccess = Setup-Environment
        if (-not $envSetupSuccess) {
            $errors += "Environment setup failed"
        }
        else {
            $successes += "Environment Setup"
        }
        
        # Validate environment after setup
        $envValidationSuccess = Validate-Environment
        if (-not $envValidationSuccess) {
            $errors += "Environment validation failed"
        }
    }
    
    # 1. GitHub Deployment
    if (-not $SkipGitHub) {
        Write-ColorOutput "`n📦 Step 1: GitHub Repository Update" $Yellow
        
        if (-not (Test-Command "git")) {
            Write-ColorOutput "❌ Git not found. Please install Git." $Red
            $errors += "Git not installed"
        }
        elseif (-not (Test-GitRemote)) {
            Write-ColorOutput "❌ No Git remote found. Please add origin remote." $Red
            $errors += "No Git remote configured"
        }
        elseif (-not (Test-GitStatus) -and -not $Force) {
            Write-ColorOutput "ℹ️  No changes to commit. Use -Force to deploy anyway." $Yellow
        }
        else {
            try {
                # Add all changes
                git add .
                Write-ColorOutput "✅ Added all changes to staging" $Green
                
                # Commit changes
                git commit -m $CommitMessage
                Write-ColorOutput "✅ Committed changes: $CommitMessage" $Green
                
                # Push to GitHub
                git push origin main
                Write-ColorOutput "✅ Pushed to GitHub successfully" $Green
                $successes += "GitHub"
            }
            catch {
                Write-ColorOutput "❌ GitHub deployment failed: $($_.Exception.Message)" $Red
                $errors += "GitHub: $($_.Exception.Message)"
            }
        }
    }
    else {
        Write-ColorOutput "⏭️  Skipping GitHub deployment" $Yellow
    }
    
    # 2. Environment Deployment (if not in setup mode)
    if (-not $SetupEnv) {
        Write-ColorOutput "`n🔧 Step 2: Environment Variable Deployment" $Yellow
        
        $envDeploySuccess = Deploy-Environment
        if (-not $envDeploySuccess) {
            $errors += "Environment deployment failed"
        }
        else {
            $successes += "Environment Deployment"
        }
    }
    
    # 3. Vercel Frontend Deployment
    if (-not $SkipVercel) {
        Write-ColorOutput "`n🌐 Step 3: Vercel Frontend Deployment" $Yellow
        
        if (-not (Test-Command "vercel")) {
            Write-ColorOutput "❌ Vercel CLI not found. Installing..." $Yellow
            try {
                npm install -g vercel
                Write-ColorOutput "✅ Vercel CLI installed" $Green
            }
            catch {
                Write-ColorOutput "❌ Failed to install Vercel CLI: $($_.Exception.Message)" $Red
                $errors += "Vercel CLI installation failed"
            }
        }
        
        if (Test-Command "vercel") {
            try {
                # Navigate to frontend directory
                Push-Location frontend
                
                # Deploy to Vercel
                Write-ColorOutput "🚀 Deploying frontend to Vercel..." $Blue
                $vercelOutput = vercel --prod --yes 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-ColorOutput "✅ Vercel deployment successful" $Green
                    $successes += "Vercel"
                    
                    # Extract deployment URL
                    $deploymentUrl = $vercelOutput | Select-String "https://.*\.vercel\.app" | ForEach-Object { $_.Matches[0].Value }
                    if ($deploymentUrl) {
                        Write-ColorOutput "🌐 Frontend URL: $deploymentUrl" $Green
                    }
                }
                else {
                    Write-ColorOutput "❌ Vercel deployment failed" $Red
                    Write-ColorOutput "Output: $vercelOutput" $Red
                    $errors += "Vercel deployment failed"
                }
                
                Pop-Location
            }
            catch {
                Write-ColorOutput "❌ Vercel deployment error: $($_.Exception.Message)" $Red
                $errors += "Vercel: $($_.Exception.Message)"
                Pop-Location
            }
        }
    }
    else {
        Write-ColorOutput "⏭️  Skipping Vercel deployment" $Yellow
    }
    
    # 4. Render Backend Deployment
    if (-not $SkipRender) {
        Write-ColorOutput "`n⚙️  Step 4: Render Backend Deployment" $Yellow
        
        if (-not (Test-Command "render")) {
            Write-ColorOutput "❌ Render CLI not found. Installing..." $Yellow
            try {
                # Install Render CLI (if available)
                Write-ColorOutput "ℹ️  Render CLI installation not available. Please install manually:" $Yellow
                Write-ColorOutput "   Visit: https://render.com/docs/cli" $Yellow
                $errors += "Render CLI not installed"
            }
            catch {
                Write-ColorOutput "❌ Failed to install Render CLI" $Red
                $errors += "Render CLI installation failed"
            }
        }
        
        if (Test-Command "render") {
            try {
                # Deploy to Render
                Write-ColorOutput "🚀 Deploying backend to Render..." $Blue
                $renderOutput = render deploy --service your-backend-service-name 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-ColorOutput "✅ Render deployment successful" $Green
                    $successes += "Render"
                }
                else {
                    Write-ColorOutput "❌ Render deployment failed" $Red
                    Write-ColorOutput "Output: $renderOutput" $Red
                    $errors += "Render deployment failed"
                }
            }
            catch {
                Write-ColorOutput "❌ Render deployment error: $($_.Exception.Message)" $Red
                $errors += "Render: $($_.Exception.Message)"
            }
        }
    }
    else {
        Write-ColorOutput "⏭️  Skipping Render deployment" $Yellow
    }
    
    # Summary
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-ColorOutput "`n================================================" $Blue
    Write-ColorOutput "🎯 Deployment Summary" $Blue
    Write-ColorOutput "================================================" $Blue
    Write-ColorOutput "Duration: $($duration.TotalSeconds.ToString('F1')) seconds" $Blue
    Write-ColorOutput "Environment: $Environment" $Blue
    
    if ($successes.Count -gt 0) {
        Write-ColorOutput "✅ Successful: $($successes -join ', ')" $Green
    }
    
    if ($errors.Count -gt 0) {
        Write-ColorOutput "❌ Errors: $($errors.Count)" $Red
        foreach ($err in $errors) {
            Write-ColorOutput "   • $err" $Red
        }
    }
    
    if ($errors.Count -eq 0) {
        Write-ColorOutput "🎉 All deployments completed successfully!" $Green
        exit 0
    }
    else {
        Write-ColorOutput "⚠️  Deployment completed with errors" $Yellow
        exit 1
    }
}

# Script execution
try {
    Start-Deployment
}
catch {
    Write-ColorOutput "❌ Deployment script failed: $($_.Exception.Message)" $Red
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" $Red
    exit 1
} 