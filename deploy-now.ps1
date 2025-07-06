Write-Host "========================================" -ForegroundColor Green
Write-Host "GOLD STAR EVOLUTION ENHANCER DEPLOYMENT" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your code is now on GitHub: https://github.com/JackReacher55/gold-star-evolution-enhancer" -ForegroundColor Yellow
Write-Host ""
Write-Host "Starting automated deployment process..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Opening Vercel for Frontend Deployment..." -ForegroundColor Green
Start-Process "https://vercel.com/new"
Write-Host ""
Write-Host "Please follow these steps in Vercel:" -ForegroundColor White
Write-Host "1. Sign in with GitHub if not already signed in" -ForegroundColor Gray
Write-Host "2. Click 'Import Git Repository'" -ForegroundColor Gray
Write-Host "3. Select 'gold-star-evolution-enhancer'" -ForegroundColor Gray
Write-Host "4. Set Root Directory to: frontend" -ForegroundColor Gray
Write-Host "5. Click 'Deploy'" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when Vercel deployment is complete"

Write-Host "Step 2: Opening Render for Backend Deployment..." -ForegroundColor Green
Start-Process "https://dashboard.render.com/new/web-service"
Write-Host ""
Write-Host "Please follow these steps in Render:" -ForegroundColor White
Write-Host "1. Sign in with GitHub if not already signed in" -ForegroundColor Gray
Write-Host "2. Click 'Connect' next to 'gold-star-evolution-enhancer'" -ForegroundColor Gray
Write-Host "3. Configure the service:" -ForegroundColor Gray
Write-Host "   - Name: gold-star-evolution-enhancer-backend" -ForegroundColor Gray
Write-Host "   - Root Directory: backend" -ForegroundColor Gray
Write-Host "   - Runtime: Python 3" -ForegroundColor Gray
Write-Host "   - Build Command: pip install -r requirements.txt" -ForegroundColor Gray
Write-Host "   - Start Command: uvicorn app:app --host 0.0.0.0 --port `$PORT" -ForegroundColor Gray
Write-Host "4. Click 'Create Web Service'" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter when Render deployment is complete"

Write-Host "Step 3: Deployment Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Your deployment URLs will be:" -ForegroundColor Yellow
Write-Host "Frontend: https://your-project-name.vercel.app" -ForegroundColor Cyan
Write-Host "Backend: https://your-backend-name.onrender.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "Once both are deployed, you'll need to update the frontend" -ForegroundColor White
Write-Host "to connect to your backend URL." -ForegroundColor White
Write-Host ""
Write-Host "Deployment process initiated! Check the browser windows that opened." -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit" 