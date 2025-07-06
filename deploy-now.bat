@echo off
echo ========================================
echo GOLD STAR EVOLUTION ENHANCER DEPLOYMENT
echo ========================================
echo.
echo Your code is now on GitHub: https://github.com/JackReacher55/gold-star-evolution-enhancer
echo.
echo Starting automated deployment process...
echo.

echo Step 1: Opening Vercel for Frontend Deployment...
start https://vercel.com/new
echo.
echo Please follow these steps in Vercel:
echo 1. Sign in with GitHub if not already signed in
echo 2. Click "Import Git Repository"
echo 3. Select "gold-star-evolution-enhancer"
echo 4. Set Root Directory to: frontend
echo 5. Click "Deploy"
echo.
pause

echo Step 2: Opening Render for Backend Deployment...
start https://dashboard.render.com/new/web-service
echo.
echo Please follow these steps in Render:
echo 1. Sign in with GitHub if not already signed in
echo 2. Click "Connect" next to "gold-star-evolution-enhancer"
echo 3. Configure the service:
echo    - Name: gold-star-evolution-enhancer-backend
echo    - Root Directory: backend
echo    - Runtime: Python 3
echo    - Build Command: pip install -r requirements.txt
echo    - Start Command: uvicorn app:app --host 0.0.0.0 --port $PORT
echo 4. Click "Create Web Service"
echo.
pause

echo Step 3: Checking deployment status...
echo.
echo Your deployment URLs will be:
echo Frontend: https://your-project-name.vercel.app
echo Backend: https://your-backend-name.onrender.com
echo.
echo Once both are deployed, you'll need to update the frontend
echo to connect to your backend URL.
echo.
echo Deployment process initiated! Check the browser windows that opened.
echo.
pause 