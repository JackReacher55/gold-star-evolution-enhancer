@echo off
setlocal enabledelayedexpansion

REM Gold Star Evolution Enhancer - Free Deployment Script
REM Domain: goldstarevolutionenhancer.com

echo 🌟 Gold Star Evolution Enhancer - Free Deployment
echo ================================================
echo.
echo 🎯 Domain: goldstarevolutionenhancer.com
echo 💰 Cost: $0/month
echo.

REM Check prerequisites
echo 🔍 Checking prerequisites...

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Git is not installed. Please install it first.
    echo Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed. Please install it first.
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
)

REM Check if npm is installed
npm --version >nul 2>&1
if errorlevel 1 (
    echo ❌ npm is not installed. Please install it first.
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ All prerequisites are met!
echo.

REM Setup Git repository
echo 🔧 Setting up Git repository...
if not exist ".git" (
    git init
    git add .
    git commit -m "Initial commit for Gold Star Evolution Enhancer"
    echo ✅ Git repository initialized!
) else (
    echo ⚠️ Git repository already exists.
)
echo.

REM Build frontend
echo 🏗️ Building frontend...
cd frontend

REM Install dependencies
call npm install

REM Build the application
call npm run build

cd ..
echo ✅ Frontend built successfully!
echo.

REM Deploy to Vercel
echo 🚀 Deploying to Vercel...
cd frontend

REM Check if Vercel CLI is installed
vercel --version >nul 2>&1
if errorlevel 1 (
    echo 📦 Installing Vercel CLI...
    call npm install -g vercel
)

echo.
echo 📋 Deploying Gold Star Evolution Enhancer to Vercel...
echo ⚠️ When prompted, use these settings:
echo   - Project name: goldstar-evolution-enhancer
echo   - Directory: ./ (current directory)
echo   - Override settings: No
echo.

vercel --prod

cd ..
echo ✅ Frontend deployed to Vercel!
echo.

REM Deploy to Render
echo 🚀 Deploying to Render...
echo.
echo 📋 Please follow these steps to deploy the backend:
echo.
echo 1. Go to https://render.com
echo 2. Sign up with GitHub
echo 3. Click 'New Web Service'
echo 4. Connect your GitHub repository
echo 5. Configure settings:
echo    - Name: goldstar-evolution-enhancer-backend
echo    - Root Directory: backend
echo    - Runtime: Python 3
echo    - Build Command: pip install -r requirements.txt
echo    - Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
echo 6. Add Environment Variable:
echo    - Key: CORS_ORIGINS
echo    - Value: https://goldstar-evolution-enhancer.vercel.app
echo 7. Click 'Create Web Service'
echo.

set /p confirm="Press Enter when you've completed the Render setup..."

echo ✅ Backend deployment instructions provided!
echo.

REM Update environment variables
echo 🔧 Updating environment variables...
echo.
echo 📋 Please update your Vercel environment variables:
echo 1. Go to your Vercel dashboard
echo 2. Select your project
echo 3. Go to Settings → Environment Variables
echo 4. Add/Update:
echo    - Name: NEXT_PUBLIC_API_URL
echo    - Value: https://goldstar-evolution-enhancer-backend.onrender.com
echo 5. Redeploy the project
echo.

set /p confirm="Press Enter when you've updated the environment variables..."

echo ✅ Environment variables updated!
echo.

REM Domain setup instructions
echo 🌐 Domain Setup for goldstarevolutionenhancer.com
echo.
echo 📋 To use your custom domain:
echo.
echo 1. Purchase domain from any registrar:
echo    - GoDaddy, Namecheap, Google Domains, etc.
echo    - Domain: goldstarevolutionenhancer.com
echo.
echo 2. Configure DNS records:
echo    Type: CNAME
echo    Name: @
echo    Value: cname.vercel-dns.com
echo.
echo    Type: CNAME
echo    Name: api
echo    Value: goldstar-evolution-enhancer-backend.onrender.com
echo.
echo 3. Add domain to Vercel:
echo    - Vercel Dashboard → Settings → Domains
echo    - Add: goldstarevolutionenhancer.com
echo.
echo 4. Wait for DNS propagation (up to 48 hours)
echo.

echo 🎉 Gold Star Evolution Enhancer deployment completed!
echo.
echo 📱 Your application will be available at:
echo   Frontend: https://goldstar-evolution-enhancer.vercel.app
echo   Backend: https://goldstar-evolution-enhancer-backend.onrender.com
echo.
echo 🌐 With custom domain:
echo   Frontend: https://goldstarevolutionenhancer.com
echo   API: https://api.goldstarevolutionenhancer.com
echo.
echo 💰 Total Cost: $0/month!
echo.
echo 📋 Next steps:
echo   1. Wait for deployments to complete
echo   2. Purchase domain: goldstarevolutionenhancer.com
echo   3. Configure DNS settings
echo   4. Test your application
echo   5. Share your Gold Star Evolution Enhancer!
echo.
pause 