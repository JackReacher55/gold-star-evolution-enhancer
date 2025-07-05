@echo off
setlocal enabledelayedexpansion

echo 🌟 Gold Star Evolution Enhancer - LIVE DEPLOYMENT
echo ================================================
echo.
echo 🎯 Domain: goldstarevolutionenhancer.com
echo 💰 Cost: $0/month
echo.

echo ⚠️ IMPORTANT: The URLs you tried don't work because we haven't deployed yet!
echo Let's deploy your application now.
echo.

REM Check if frontend is built
if not exist "frontend\.next" (
    echo 🔨 Building frontend first...
    cd frontend
    call npm install
    call npm run build
    cd ..
    echo ✅ Frontend built!
) else (
    echo ✅ Frontend already built!
)
echo.

echo 🚀 STEP 1: DEPLOY FRONTEND TO VERCEL
echo =====================================
echo.
echo 1. Open your web browser
echo 2. Go to: https://vercel.com
echo 3. Click "Sign Up" (use GitHub account)
echo 4. After signing in, click "New Project"
echo 5. Click "Upload" or "Import Git Repository"
echo.
echo If uploading manually:
echo - Select the "frontend" folder from your project
echo - Project name: goldstar-evolution-enhancer
echo - Framework: Next.js
echo - Click "Deploy"
echo.
echo ⏳ Waiting for you to complete frontend deployment...
echo.
set /p frontend_done="Press Enter when frontend is deployed to Vercel..."

echo.
echo 🔧 STEP 2: DEPLOY BACKEND TO RENDER
echo ====================================
echo.
echo 1. Open a new browser tab
echo 2. Go to: https://render.com
echo 3. Click "Sign Up" (use GitHub account)
echo 4. After signing in, click "New Web Service"
echo 5. Connect your GitHub repository (or upload manually)
echo 6. Configure settings:
echo    - Name: goldstar-evolution-enhancer-backend
echo    - Root Directory: backend
echo    - Runtime: Python 3
echo    - Build Command: pip install -r requirements.txt
echo    - Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
echo 7. Click "Create Web Service"
echo.
echo ⏳ Waiting for you to complete backend deployment...
echo.
set /p backend_done="Press Enter when backend is deployed to Render..."

echo.
echo 🔗 STEP 3: CONNECT FRONTEND TO BACKEND
echo =======================================
echo.
echo 1. Go back to your Vercel dashboard
echo 2. Select your goldstar-evolution-enhancer project
echo 3. Go to Settings → Environment Variables
echo 4. Add new environment variable:
echo    - Name: NEXT_PUBLIC_API_URL
echo    - Value: [Your Render backend URL]
echo 5. Click "Save"
echo 6. Go to Deployments tab
echo 7. Click "Redeploy" on the latest deployment
echo.
echo ⏳ Waiting for you to connect frontend to backend...
echo.
set /p connect_done="Press Enter when frontend is connected to backend..."

echo.
echo 🎉 DEPLOYMENT COMPLETE!
echo =======================
echo.
echo Your Gold Star Evolution Enhancer is now live!
echo.
echo 📱 Your actual URLs will be:
echo Frontend: [Your Vercel URL]
echo Backend: [Your Render URL]
echo.
echo 🌐 To use custom domain goldstarevolutionenhancer.com:
echo 1. Purchase the domain
echo 2. Configure DNS settings
echo 3. Add domain to Vercel
echo.
echo 💰 Total Cost: $0/month!
echo.
echo 🚀 Your Gold Star Evolution Enhancer is ready to use!
echo.
pause 