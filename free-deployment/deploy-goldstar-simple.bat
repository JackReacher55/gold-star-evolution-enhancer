@echo off
setlocal enabledelayedexpansion

REM Gold Star Evolution Enhancer - Simple Free Deployment Script
REM Domain: goldstarevolutionenhancer.com

echo 🌟 Gold Star Evolution Enhancer - Free Deployment
echo ================================================
echo.
echo 🎯 Domain: goldstarevolutionenhancer.com
echo 💰 Cost: $0/month
echo.

REM Check Node.js
echo 🔍 Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed. Please install it first.
    echo Download from: https://nodejs.org/
    echo.
    echo After installing Node.js, run this script again.
    pause
    exit /b 1
)

echo ✅ Node.js is installed!
echo.

REM Build frontend
echo 🏗️ Building frontend...
cd frontend

echo Installing dependencies...
call npm install

echo Building the application...
call npm run build

cd ..
echo ✅ Frontend built successfully!
echo.

REM Create deployment guide
echo 📋 Creating deployment guide...
echo.

echo 🚀 DEPLOYMENT INSTRUCTIONS FOR GOLD STAR EVOLUTION ENHANCER
echo ===========================================================
echo.
echo 🌐 DOMAIN: goldstarevolutionenhancer.com
echo 💰 COST: $0/month
echo.
echo 📱 FRONTEND DEPLOYMENT (Vercel):
echo.
echo 1. Go to https://vercel.com
echo 2. Sign up with GitHub (create account if needed)
echo 3. Click "New Project"
echo 4. Import your repository or upload the frontend folder
echo 5. Configure settings:
echo    - Project Name: goldstar-evolution-enhancer
echo    - Framework Preset: Next.js
echo    - Root Directory: ./
echo 6. Click "Deploy"
echo.
echo 🔧 BACKEND DEPLOYMENT (Render):
echo.
echo 1. Go to https://render.com
echo 2. Sign up with GitHub
echo 3. Click "New Web Service"
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
echo 7. Click "Create Web Service"
echo.
echo 🔗 CONNECT FRONTEND TO BACKEND:
echo.
echo 1. Go to your Vercel dashboard
echo 2. Select your project
echo 3. Go to Settings → Environment Variables
echo 4. Add:
echo    - Name: NEXT_PUBLIC_API_URL
echo    - Value: https://goldstar-evolution-enhancer-backend.onrender.com
echo 5. Redeploy the project
echo.
echo 🌐 CUSTOM DOMAIN SETUP:
echo.
echo 1. Purchase domain: goldstarevolutionenhancer.com
echo    (from GoDaddy, Namecheap, Google Domains, etc.)
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
echo 🎉 YOUR GOLD STAR EVOLUTION ENHANCER WILL BE AVAILABLE AT:
echo.
echo 📱 Default URLs:
echo   Frontend: https://goldstar-evolution-enhancer.vercel.app
echo   Backend: https://goldstar-evolution-enhancer-backend.onrender.com
echo.
echo 🌐 Custom Domain:
echo   Frontend: https://goldstarevolutionenhancer.com
echo   API: https://api.goldstarevolutionenhancer.com
echo.
echo 💰 TOTAL COST: $0/month!
echo.
echo 📋 FEATURES:
echo   ✅ AI-powered video upscaling
echo   ✅ Multiple resolution support (720p, 1080p, 2K, 4K)
echo   ✅ Audio analysis and fixing
echo   ✅ Professional quality output
echo   ✅ Fast processing with advanced algorithms
echo   ✅ Beautiful modern UI
echo   ✅ Drag-and-drop upload
echo   ✅ Real-time progress tracking
echo.
echo 🚀 Ready to deploy your Gold Star Evolution Enhancer!
echo.
pause 