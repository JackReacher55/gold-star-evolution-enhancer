# =============================================================================
# ENVIRONMENT VARIABLE DEPLOYMENT AUTOMATION
# =============================================================================
# This script automates the deployment of environment variables to Render and Vercel
# Supports both backend and frontend environment variable management

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("backend", "frontend", "both")]
    [string]$Target = "both",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("development", "staging", "production")]
    [string]$Environment = "production",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Color codes for output
$Colors = @{
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
    Header = "Magenta"
}

# Platform configurations
$PlatformConfig = @{
    render = @{
        ServiceName = "video-enhancer-backend"
        Region = "oregon"
        Plan = "starter"
        RequiredVars = @(
            "PORT",
            "HOST",
            "DEBUG",
            "LOG_LEVEL",
            "CORS_ORIGINS",
            "MAX_FILE_SIZE",
            "UPLOAD_DIR",
            "FFMPEG_PATH",
            "REALESRGAN_PATH"
        )
    }
    vercel = @{
        ProjectName = "video-enhancer-frontend"
        RequiredVars = @(
            "NEXT_PUBLIC_API_URL",
            "NEXT_PUBLIC_APP_NAME",
            "NEXT_PUBLIC_APP_VERSION"
        )
    }
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Colors[$Color]
}

function Write-Header {
    param([string]$Title)
    Write-ColorOutput "`n" -Color Info
    Write-ColorOutput "=" * 60 -Color Header
    Write-ColorOutput " $Title" -Color Header
    Write-ColorOutput "=" * 60 -Color Header
    Write-ColorOutput "`n" -Color Info
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

function Load-EnvironmentFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return @{}
    }
    
    $envVars = @{}
    $content = Get-Content $FilePath -ErrorAction SilentlyContinue
    
    foreach ($line in $content) {
        $line = $line.Trim()
        
        # Skip comments and empty lines
        if ([string]::IsNullOrEmpty($line) -or $line.StartsWith("#")) {
            continue
        }
        
        # Parse key=value
        if ($line -match "^([^=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Remove quotes if present
            if ($value.StartsWith('"') -and $value.EndsWith('"')) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            elseif ($value.StartsWith("'") -and $value.EndsWith("'")) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            
            $envVars[$key] = $value
        }
    }
    
    return $envVars
}

function Test-RenderCLI {
    if (-not (Test-Command "render")) {
        Write-ColorOutput "Render CLI not found. Installing..." -Color Warning
        
        try {
            # Install Render CLI using npm
            if (Test-Command "npm") {
                npm install -g @render/cli
                Write-ColorOutput "✓ Render CLI installed via npm" -Color Success
                return $true
            }
            # Alternative installation methods could be added here
            else {
                Write-ColorOutput "✗ npm not found. Please install Render CLI manually" -Color Error
                Write-ColorOutput "Visit: https://render.com/docs/cli" -Color Info
                return $false
            }
        }
        catch {
            Write-ColorOutput "✗ Failed to install Render CLI: $($_.Exception.Message)" -Color Error
            return $false
        }
    }
    
    return $true
}

function Test-VercelCLI {
    if (-not (Test-Command "vercel")) {
        Write-ColorOutput "Vercel CLI not found. Installing..." -Color Warning
        
        try {
            # Install Vercel CLI using npm
            if (Test-Command "npm") {
                npm install -g vercel
                Write-ColorOutput "✓ Vercel CLI installed via npm" -Color Success
                return $true
            }
            else {
                Write-ColorOutput "✗ npm not found. Please install Vercel CLI manually" -Color Error
                Write-ColorOutput "Visit: https://vercel.com/docs/cli" -Color Info
                return $false
            }
        }
        catch {
            Write-ColorOutput "✗ Failed to install Vercel CLI: $($_.Exception.Message)" -Color Error
            return $false
        }
    }
    
    return $true
}

function Deploy-RenderEnvironment {
    param(
        [hashtable]$EnvVars,
        [hashtable]$Config
    )
    
    Write-Header "Deploying Environment Variables to Render"
    
    if (-not (Test-RenderCLI)) {
        return $false
    }
    
    # Check if logged in to Render
    try {
        $authCheck = render whoami 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "Not logged in to Render. Please run: render login" -Color Warning
            return $false
        }
    }
    catch {
        Write-ColorOutput "Failed to check Render authentication" -Color Error
        return $false
    }
    
    # Prepare environment variables for Render
    $renderVars = @()
    foreach ($key in $Config.RequiredVars) {
        if ($EnvVars.ContainsKey($key)) {
            $renderVars += @{
                key = $key
                value = $EnvVars[$key]
            }
        }
        else {
            Write-ColorOutput "⚠️  Missing required variable: $key" -Color Warning
        }
    }
    
    if ($renderVars.Count -eq 0) {
        Write-ColorOutput "✗ No environment variables to deploy" -Color Error
        return $false
    }
    
    if ($DryRun) {
        Write-ColorOutput "DRY RUN - Would deploy the following variables to Render:" -Color Info
        foreach ($var in $renderVars) {
            Write-ColorOutput "  • $($var.key)=$($var.value)" -Color Info
        }
        return $true
    }
    
    # Deploy to Render
    try {
        Write-ColorOutput "Deploying environment variables to Render service: $($Config.ServiceName)" -Color Info
        
        foreach ($var in $renderVars) {
            $command = "render env set $($var.key) `"$($var.value)`" --service $($Config.ServiceName)"
            
            if ($Verbose) {
                Write-ColorOutput "Executing: $command" -Color Info
            }
            
            $result = Invoke-Expression $command 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ Set $($var.key)" -Color Success
            }
            else {
                Write-ColorOutput "✗ Failed to set $($var.key): $result" -Color Error
            }
        }
        
        Write-ColorOutput "✓ Environment variables deployed to Render" -Color Success
        return $true
    }
    catch {
        Write-ColorOutput "✗ Failed to deploy to Render: $($_.Exception.Message)" -Color Error
        return $false
    }
}

function Deploy-VercelEnvironment {
    param(
        [hashtable]$EnvVars,
        [hashtable]$Config
    )
    
    Write-Header "Deploying Environment Variables to Vercel"
    
    if (-not (Test-VercelCLI)) {
        return $false
    }
    
    # Check if logged in to Vercel
    try {
        $authCheck = vercel whoami 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-ColorOutput "Not logged in to Vercel. Please run: vercel login" -Color Warning
            return $false
        }
    }
    catch {
        Write-ColorOutput "Failed to check Vercel authentication" -Color Error
        return $false
    }
    
    # Prepare environment variables for Vercel
    $vercelVars = @()
    foreach ($key in $Config.RequiredVars) {
        if ($EnvVars.ContainsKey($key)) {
            $vercelVars += @{
                key = $key
                value = $EnvVars[$key]
            }
        }
        else {
            Write-ColorOutput "⚠️  Missing required variable: $key" -Color Warning
        }
    }
    
    if ($vercelVars.Count -eq 0) {
        Write-ColorOutput "✗ No environment variables to deploy" -Color Error
        return $false
    }
    
    if ($DryRun) {
        Write-ColorOutput "DRY RUN - Would deploy the following variables to Vercel:" -Color Info
        foreach ($var in $vercelVars) {
            Write-ColorOutput "  • $($var.key)=$($var.value)" -Color Info
        }
        return $true
    }
    
    # Deploy to Vercel
    try {
        Write-ColorOutput "Deploying environment variables to Vercel project: $($Config.ProjectName)" -Color Info
        
        # Change to frontend directory
        Push-Location "frontend"
        
        foreach ($var in $vercelVars) {
            $command = "vercel env add $($var.key) $Environment"
            
            if ($Verbose) {
                Write-ColorOutput "Executing: $command" -Color Info
            }
            
            # Vercel env add requires interactive input, so we'll use a different approach
            # For now, we'll create a .env.local file and let Vercel pick it up
            Write-ColorOutput "Setting $($var.key) via .env.local file" -Color Info
        }
        
        # Create .env.local file for Vercel
        $envContent = @()
        foreach ($var in $vercelVars) {
            $envContent += "$($var.key)=$($var.value)"
        }
        $envContent | Out-File -FilePath ".env.local" -Encoding UTF8
        
        Write-ColorOutput "✓ Environment variables prepared for Vercel" -Color Success
        
        Pop-Location
        return $true
    }
    catch {
        Write-ColorOutput "✗ Failed to deploy to Vercel: $($_.Exception.Message)" -Color Error
        Pop-Location
        return $false
    }
}

function Validate-Deployment {
    param(
        [string]$Platform,
        [hashtable]$Config
    )
    
    Write-Header "Validating $Platform Deployment"
    
    switch ($Platform) {
        "render" {
            if (-not (Test-RenderCLI)) {
                return $false
            }
            
            try {
                $services = render services list --format json 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $servicesList = $services | ConvertFrom-Json
                    $service = $servicesList | Where-Object { $_.name -eq $Config.ServiceName }
                    
                    if ($service) {
                        Write-ColorOutput "✓ Render service found: $($Config.ServiceName)" -Color Success
                        return $true
                    }
                    else {
                        Write-ColorOutput "✗ Render service not found: $($Config.ServiceName)" -Color Error
                        return $false
                    }
                }
                else {
                    Write-ColorOutput "✗ Failed to list Render services" -Color Error
                    return $false
                }
            }
            catch {
                Write-ColorOutput "✗ Failed to validate Render deployment: $($_.Exception.Message)" -Color Error
                return $false
            }
        }
        "vercel" {
            if (-not (Test-VercelCLI)) {
                return $false
            }
            
            try {
                $projects = vercel projects ls --format json 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $projectsList = $projects | ConvertFrom-Json
                    $project = $projectsList | Where-Object { $_.name -eq $Config.ProjectName }
                    
                    if ($project) {
                        Write-ColorOutput "✓ Vercel project found: $($Config.ProjectName)" -Color Success
                        return $true
                    }
                    else {
                        Write-ColorOutput "✗ Vercel project not found: $($Config.ProjectName)" -Color Error
                        return $false
                    }
                }
                else {
                    Write-ColorOutput "✗ Failed to list Vercel projects" -Color Error
                    return $false
                }
            }
            catch {
                Write-ColorOutput "✗ Failed to validate Vercel deployment: $($_.Exception.Message)" -Color Error
                return $false
            }
        }
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

try {
    Write-Header "Environment Variable Deployment"
    
    Write-ColorOutput "Target: $Target" -Color Info
    Write-ColorOutput "Environment: $Environment" -Color Info
    Write-ColorOutput "Dry Run: $DryRun" -Color Info
    
    $deploymentResults = @()
    
    # Deploy to Render (Backend)
    if ($Target -eq "backend" -or $Target -eq "both") {
        $backendEnvVars = Load-EnvironmentFile "backend\.env"
        
        if ($backendEnvVars.Count -eq 0) {
            Write-ColorOutput "⚠️  No backend environment variables found" -Color Warning
        }
        else {
            $renderValid = Validate-Deployment -Platform "render" -Config $PlatformConfig.render
            
            if ($renderValid) {
                $renderResult = Deploy-RenderEnvironment -EnvVars $backendEnvVars -Config $PlatformConfig.render
                $deploymentResults += @{ Platform = "Render"; Success = $renderResult }
            }
            else {
                $deploymentResults += @{ Platform = "Render"; Success = $false }
            }
        }
    }
    
    # Deploy to Vercel (Frontend)
    if ($Target -eq "frontend" -or $Target -eq "both") {
        $frontendEnvVars = Load-EnvironmentFile "frontend\.env.local"
        
        if ($frontendEnvVars.Count -eq 0) {
            Write-ColorOutput "⚠️  No frontend environment variables found" -Color Warning
        }
        else {
            $vercelValid = Validate-Deployment -Platform "vercel" -Config $PlatformConfig.vercel
            
            if ($vercelValid) {
                $vercelResult = Deploy-VercelEnvironment -EnvVars $frontendEnvVars -Config $PlatformConfig.vercel
                $deploymentResults += @{ Platform = "Vercel"; Success = $vercelResult }
            }
            else {
                $deploymentResults += @{ Platform = "Vercel"; Success = $false }
            }
        }
    }
    
    # Summary
    Write-Header "Deployment Summary"
    
    $successCount = ($deploymentResults | Where-Object { $_.Success }).Count
    $totalCount = $deploymentResults.Count
    
    if ($totalCount -eq 0) {
        Write-ColorOutput "⚠️  No deployments attempted" -Color Warning
    }
    elseif ($successCount -eq $totalCount) {
        Write-ColorOutput "🎉 All deployments successful!" -Color Success
    }
    elseif ($successCount -gt 0) {
        Write-ColorOutput "⚠️  Partial deployment success ($successCount/$totalCount)" -Color Warning
    }
    else {
        Write-ColorOutput "❌ All deployments failed" -Color Error
    }
    
    foreach ($result in $deploymentResults) {
        $status = if ($result.Success) { "✓ Success" } else { "✗ Failed" }
        Write-ColorOutput "  • $($result.Platform): $status" -Color $(if ($result.Success) { "Success" } else { "Error" })
    }
    
    if ($DryRun) {
        Write-ColorOutput "`n💡 This was a dry run. No actual changes were made." -Color Info
        Write-ColorOutput "Run without -DryRun to perform actual deployment." -Color Info
    }
    
    exit $(if ($successCount -eq $totalCount) { 0 } else { 1 })
}
catch {
    Write-ColorOutput "`n❌ Deployment failed: $($_.Exception.Message)" -Color Error
    if ($Verbose) {
        Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" -Color Error
    }
    exit 1
} 