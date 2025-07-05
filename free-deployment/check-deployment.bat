@echo off
setlocal enabledelayedexpansion

echo 🌟 Gold Star Evolution Enhancer - Deployment Status Check
echo ========================================================
echo.
echo 🎯 Domain: goldstarevolutionenhancer.com
echo 💰 Cost: $0/month
echo.

echo 🔍 Checking deployment status...
echo.

echo 📋 Current Status:
echo - Domain: goldstarevolutionenhancer.com
echo - Status: Domain purchased and configured with Vercel
echo - Application: Not yet deployed
echo.

echo ⚠️ IMPORTANT: The domain is set up, but the application isn't deployed yet!
echo.
echo 🚀 Let's complete the deployment now:
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

echo 🎯 STEP 1: DEPLOY FRONTEND TO VERCEL
echo =====================================
echo.
echo Since you already have the domain configured:
echo.
echo 1. Go to: https://vercel.com
echo 2. Click "New Project"
echo 3. Click "Upload"
echo 4. Select the "frontend" folder from your project
echo 5. Configure:
echo    - Project Name: goldstar-evolution-enhancer
echo    - Framework Preset: Next.js
echo    - Root Directory: ./
echo 6. Click "Deploy"
echo.
echo ⏳ After deployment, your app will be available at:
echo https://goldstarevolutionenhancer.com
echo.
set /p frontend_done="Press Enter when frontend is deployed..."

echo.
echo 🔧 STEP 2: DEPLOY BACKEND TO RENDER
echo ====================================
echo.
echo 1. Go to: https://render.com
echo 2. Click "New Web Service"
echo 3. Click "Upload" or connect your GitLab repository
echo 4. If uploading: Select the "backend" folder
echo 5. Configure settings:
echo    - Name: goldstar-evolution-enhancer-backend
echo    - Root Directory: backend
echo    - Runtime: Python 3
echo    - Build Command: pip install -r requirements.txt
echo    - Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
echo 6. Add Environment Variable:
echo    - Key: CORS_ORIGINS
echo    - Value: https://goldstarevolutionenhancer.com
echo 7. Click "Create Web Service"
echo.
echo ⏳ Deployment will take 5-10 minutes...
echo.
set /p backend_url="Enter your Render backend URL: "

echo.
echo 🔗 STEP 3: CONNECT FRONTEND TO BACKEND
echo =======================================
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
echo ⏳ Waiting for redeployment...
echo.
set /p connect_done="Press Enter when redeployment is complete..."

echo.
echo 🎉 DEPLOYMENT COMPLETE!
echo =======================
echo.
echo 🌟 Your Gold Star Evolution Enhancer is now live!
echo.
echo 📱 Your Live URLs:
echo Frontend: https://goldstarevolutionenhancer.com
echo Backend: %backend_url%
echo.
echo 🧪 Test your application:
echo 1. Open: https://goldstarevolutionenhancer.com
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
pause 