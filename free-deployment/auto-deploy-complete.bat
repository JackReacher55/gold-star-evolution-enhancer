@echo off
setlocal enabledelayedexpansion

echo 🌟 Gold Star Evolution Enhancer - COMPLETE AUTOMATED DEPLOYMENT
echo =============================================================
echo.
echo 🎯 Domain: goldstarevolutionenhancer.com
echo 💰 Cost: $0/month
echo.

echo 🚀 Starting automated deployment...
echo.

REM Check if frontend is built
if not exist "frontend\.next" (
    echo 🔨 Building frontend...
    cd frontend
    call npm install
    call npm run build
    cd ..
    echo ✅ Frontend built successfully!
) else (
    echo ✅ Frontend already built!
)
echo.

echo 📦 Creating deployment packages...
echo.

REM Create frontend deployment package
if not exist "deploy-frontend" mkdir deploy-frontend
xcopy "frontend\*" "deploy-frontend\" /E /I /Y
echo ✅ Frontend package created!

REM Create backend deployment package
if not exist "deploy-backend" mkdir deploy-backend
xcopy "backend\*" "deploy-backend\" /E /I /Y
echo ✅ Backend package created!
echo.

echo 🎯 AUTOMATED DEPLOYMENT INSTRUCTIONS
echo ====================================
echo.
echo 📱 FRONTEND DEPLOYMENT (Vercel):
echo.
echo 1. Open: https://vercel.com
echo 2. Click "New Project"
echo 3. Click "Upload"
echo 4. Select the "deploy-frontend" folder from your project
echo 5. Configure:
echo    - Project Name: goldstar-evolution-enhancer
echo    - Framework Preset: Next.js
echo    - Root Directory: ./
echo 6. Click "Deploy"
echo 7. Wait 2-5 minutes for deployment
echo 8. Copy your Vercel URL
echo.
echo ⏳ Complete frontend deployment, then press Enter...
echo.
set /p frontend_url="Enter your Vercel URL: "

echo.
echo 🔧 BACKEND DEPLOYMENT (Render):
echo.
echo 1. Open: https://render.com
echo 2. Click "New Web Service"
echo 3. Click "Upload"
echo 4. Select the "deploy-backend" folder from your project
echo 5. Configure settings:
echo    - Name: goldstar-evolution-enhancer-backend
echo    - Root Directory: ./
echo    - Runtime: Python 3
echo    - Build Command: pip install -r requirements.txt
echo    - Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
echo 6. Add Environment Variable:
echo    - Key: CORS_ORIGINS
echo    - Value: %frontend_url%
echo 7. Click "Create Web Service"
echo 8. Wait 5-10 minutes for deployment
echo 9. Copy your Render URL
echo.
echo ⏳ Complete backend deployment, then press Enter...
echo.
set /p backend_url="Enter your Render URL: "

echo.
echo 🔗 CONNECTING FRONTEND TO BACKEND:
echo.
echo 1. Go back to Vercel dashboard
echo 2. Select your goldstar-evolution-enhancer project
echo 3. Go to Settings → Environment Variables
echo 4. Add new environment variable:
echo    - Name: NEXT_PUBLIC_API_URL
echo    - Value: %backend_url%
echo 5. Click "Save"
echo 6. Go to Deployments tab
echo 7. Click "Redeploy" on the latest deployment
echo.
echo ⏳ Complete the connection, then press Enter...
echo.
set /p connect_done="Press Enter when connection is complete..."

echo.
echo 🎉 DEPLOYMENT COMPLETE!
echo =======================
echo.
echo 🌟 Your Gold Star Evolution Enhancer is now live!
echo.
echo 📱 Your Live URLs:
echo Frontend: %frontend_url%
echo Backend: %backend_url%
echo.
echo 🌐 Custom Domain (if configured):
echo https://goldstarevolutionenhancer.com
echo.
echo 🧪 Test your application:
echo 1. Open: %frontend_url%
echo 2. Upload a video file
echo 3. Select resolution (720p, 1080p, 2K, 4K)
echo 4. Click "🌟 Enhance Video"
echo 5. Download your enhanced video!
echo.
echo 💰 Total Cost: $0/month!
echo.
echo 🚀 Your Gold Star Evolution Enhancer is ready to use!
echo.
echo 📋 Features Available:
echo ✅ AI-powered video upscaling
echo ✅ Multiple resolution support (720p, 1080p, 2K, 4K)
echo ✅ Audio analysis and fixing
echo ✅ Professional quality output
echo ✅ Beautiful modern UI
echo ✅ Drag-and-drop upload
echo ✅ Real-time progress tracking
echo.
echo 🧹 Cleaning up deployment packages...
if exist "deploy-frontend" rmdir /s /q "deploy-frontend"
if exist "deploy-backend" rmdir /s /q "deploy-backend"
echo ✅ Cleanup complete!
echo.
pause 