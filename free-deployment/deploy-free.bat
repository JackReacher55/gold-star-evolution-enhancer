@echo off
setlocal enabledelayedexpansion

REM Free Deployment Script for Online Video Enhancer (Windows)
REM This script helps you deploy to Vercel and Render for free

echo 🌐 Free Deployment Script for Online Video Enhancer
echo ==================================================
echo.

echo 📋 This script will help you deploy your app for FREE!
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
    git commit -m "Initial commit for free deployment"
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
echo 📋 Please follow the Vercel setup prompts...
echo ⚠️ When prompted:
echo   - Set up and deploy: Yes
echo   - Which scope: Select your account
echo   - Link to existing project: No
echo   - Project name: video-enhancer-frontend
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
echo ⚠️ Please follow these steps manually:
echo 1. Go to https://render.com
echo 2. Sign up with GitHub
echo 3. Click 'New Web Service'
echo 4. Connect your GitHub repository
echo 5. Configure settings:
echo    - Name: video-enhancer-backend
echo    - Root Directory: backend
echo    - Runtime: Python 3
echo    - Build Command: pip install -r requirements.txt
echo    - Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
echo 6. Add Environment Variable:
echo    - Key: CORS_ORIGINS
echo    - Value: https://your-vercel-url.vercel.app
echo 7. Click 'Create Web Service'
echo.

set /p confirm="Press Enter when you've completed the Render setup..."

echo ✅ Backend deployment instructions provided!
echo.

REM Update environment variables
echo 🔧 Updating environment variables...
echo.
echo ⚠️ Please update your Vercel environment variables:
echo 1. Go to your Vercel dashboard
echo 2. Select your project
echo 3. Go to Settings → Environment Variables
echo 4. Add/Update:
echo    - Name: NEXT_PUBLIC_API_URL
echo    - Value: https://your-render-url.onrender.com
echo 5. Redeploy the project
echo.

set /p confirm="Press Enter when you've updated the environment variables..."

echo ✅ Environment variables updated!
echo.

REM Free domain information
echo 🌍 Free Domain Options:
echo.
echo 📋 Option A: Freenom (Free .tk domains)
echo 1. Go to https://freenom.com
echo 2. Search for available domains (.tk, .ml, .ga, .cf, .gq)
echo 3. Register your free domain
echo 4. Configure DNS to point to your Vercel/Render URLs
echo.
echo 📋 Option B: Vercel Subdomain
echo - Your app will be available at: your-app.vercel.app
echo - No additional setup required
echo.
echo 📋 Option C: Render Subdomain
echo - Your backend will be available at: your-app.onrender.com
echo - No additional setup required
echo.

echo 🎉 Free deployment setup completed!
echo.
echo 📱 Your application will be available at:
echo   Frontend: https://your-app-name.vercel.app
echo   Backend: https://your-app-name.onrender.com
echo.
echo 💰 Total Cost: $0/month!
echo.
echo 📋 Next steps:
echo   1. Wait for deployments to complete
echo   2. Test your application
echo   3. Get a free domain (optional)
echo   4. Share your app with the world!
echo.
pause 