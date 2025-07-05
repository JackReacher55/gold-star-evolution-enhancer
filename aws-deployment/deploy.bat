@echo off
setlocal enabledelayedexpansion

REM AWS Deployment Script for Online Video Enhancer (Windows)
REM This script automates the entire deployment process

echo 🚀 AWS Deployment Script for Online Video Enhancer
echo ==================================================
echo.

REM Check if domain name is provided
if "%DOMAIN_NAME%"=="" (
    echo ❌ Please provide a domain name.
    echo Usage: set DOMAIN_NAME=yourdomain.com ^&^& deploy.bat
    pause
    exit /b 1
)

echo 📋 Deploying to domain: %DOMAIN_NAME%
echo.

REM Check prerequisites
echo 🔍 Checking prerequisites...

REM Check AWS CLI
aws --version >nul 2>&1
if errorlevel 1 (
    echo ❌ AWS CLI is not installed. Please install it first.
    echo Installation guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    pause
    exit /b 1
)

REM Check Terraform
terraform --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Terraform is not installed. Please install it first.
    echo Installation guide: https://developer.hashicorp.com/terraform/downloads
    pause
    exit /b 1
)

REM Check if AWS credentials are configured
aws sts get-caller-identity >nul 2>&1
if errorlevel 1 (
    echo ❌ AWS credentials are not configured. Please run 'aws configure' first.
    pause
    exit /b 1
)

echo ✅ All prerequisites are met!
echo.

REM Generate SSH key pair
echo 🔑 Generating SSH key pair...
if not exist "terraform\ssh_key" (
    ssh-keygen -t rsa -b 4096 -f terraform\ssh_key -N ""
    echo ✅ SSH key pair generated!
) else (
    echo ⚠️ SSH key already exists, skipping generation.
)
echo.

REM Build frontend
echo 🏗️ Building frontend...
cd frontend

REM Install dependencies
call npm install

REM Build the application
call npm run build

REM Create .env.local with production API URL
echo NEXT_PUBLIC_API_URL=https://api.%DOMAIN_NAME% > .env.local

cd ..
echo ✅ Frontend built successfully!
echo.

REM Deploy infrastructure with Terraform
echo 🚀 Deploying infrastructure with Terraform...
cd aws-deployment\terraform

REM Initialize Terraform
terraform init

REM Plan the deployment
echo 📋 Planning Terraform deployment...
terraform plan -var="domain_name=%DOMAIN_NAME%" -out=tfplan

REM Ask for confirmation
echo.
echo ⚠️ This will create AWS resources that may incur costs.
set /p confirm="Do you want to proceed with the deployment? (y/N): "
if /i not "%confirm%"=="y" (
    echo ⚠️ Deployment cancelled.
    pause
    exit /b 0
)

REM Apply the plan
echo 🚀 Applying Terraform plan...
terraform apply tfplan

REM Get outputs
for /f "tokens=*" %%i in ('terraform output -raw frontend_url') do set FRONTEND_URL=%%i
for /f "tokens=*" %%i in ('terraform output -raw api_url') do set API_URL=%%i
for /f "tokens=*" %%i in ('terraform output -raw s3_frontend_bucket') do set S3_FRONTEND_BUCKET=%%i
for /f "tokens=*" %%i in ('terraform output -raw s3_videos_bucket') do set S3_VIDEOS_BUCKET=%%i
for /f "tokens=*" %%i in ('terraform output -raw cloudfront_distribution_id') do set CLOUDFRONT_DISTRIBUTION_ID=%%i
for /f "tokens=*" %%i in ('terraform output -raw ec2_public_ip') do set EC2_PUBLIC_IP=%%i
for /f "tokens=*" %%i in ('terraform output -raw nameservers') do set NAMESERVERS=%%i

echo ✅ Infrastructure deployed successfully!
echo.
echo 📊 Deployment Summary:
echo   Frontend URL: %FRONTEND_URL%
echo   API URL: %API_URL%
echo   S3 Frontend Bucket: %S3_FRONTEND_BUCKET%
echo   S3 Videos Bucket: %S3_VIDEOS_BUCKET%
echo   CloudFront Distribution ID: %CLOUDFRONT_DISTRIBUTION_ID%
echo   EC2 Public IP: %EC2_PUBLIC_IP%
echo   Nameservers: %NAMESERVERS%
echo.

REM Save outputs to file
cd ..\..
echo Frontend URL: %FRONTEND_URL% > deployment-outputs.txt
echo API URL: %API_URL% >> deployment-outputs.txt
echo S3 Frontend Bucket: %S3_FRONTEND_BUCKET% >> deployment-outputs.txt
echo S3 Videos Bucket: %S3_VIDEOS_BUCKET% >> deployment-outputs.txt
echo CloudFront Distribution ID: %CLOUDFRONT_DISTRIBUTION_ID% >> deployment-outputs.txt
echo EC2 Public IP: %EC2_PUBLIC_IP% >> deployment-outputs.txt
echo Nameservers: %NAMESERVERS% >> deployment-outputs.txt

echo 📝 Deployment outputs saved to deployment-outputs.txt
echo.

REM Upload frontend to S3
echo 📤 Uploading frontend to S3...
aws s3 sync frontend\out\ s3://%S3_FRONTEND_BUCKET%/ --delete

REM Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id %CLOUDFRONT_DISTRIBUTION_ID% --paths "/*"

echo ✅ Frontend uploaded to S3 and CloudFront cache invalidated!
echo.

REM Configure domain DNS
echo 🌐 Configuring domain DNS...
echo.
echo ⚠️ Please configure your domain's nameservers at your domain registrar:
echo Domain: %DOMAIN_NAME%
echo Nameservers:
for %%n in (%NAMESERVERS%) do echo   - %%n
echo.
echo 📋 DNS propagation can take up to 48 hours.
echo.

REM Wait for backend to be ready
echo ⏳ Waiting for backend to be ready...
set /a attempts=0
:wait_loop
set /a attempts+=1
if %attempts% gtr 60 (
    echo ❌ Backend did not become ready within 10 minutes.
    echo 📋 You can check the EC2 instance logs manually.
    goto :end
)

curl -s -f "%API_URL%/health" >nul 2>&1
if errorlevel 1 (
    echo ⏳ Waiting for backend... (attempt %attempts%/60)
    timeout /t 10 /nobreak >nul
    goto :wait_loop
)

echo ✅ Backend is ready!

:end
echo.
echo 🎉 Deployment completed successfully!
echo.
echo 📱 Your application is now available at:
echo   Frontend: https://%DOMAIN_NAME%
echo   API: https://api.%DOMAIN_NAME%
echo.
echo 📋 Next steps:
echo   1. Wait for DNS propagation (up to 48 hours)
echo   2. Test your application
echo   3. Set up monitoring and alerts
echo   4. Configure backups
echo.
pause 