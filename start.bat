@echo off
echo 🎬 Online Video Enhancer - Windows Startup Script
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org
    pause
    exit /b 1
)

REM Check if FFmpeg is installed
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo ❌ FFmpeg is not installed or not in PATH
    echo Please install FFmpeg from https://ffmpeg.org/download.html
    pause
    exit /b 1
)

echo ✅ All prerequisites are installed
echo.

REM Check if setup is complete
if not exist "backend\venv" (
    echo ❌ Backend setup incomplete
    echo Please run the setup instructions in README.md
    pause
    exit /b 1
)

if not exist "frontend\node_modules" (
    echo ❌ Frontend setup incomplete
    echo Please run: cd frontend ^&^& npm install
    pause
    exit /b 1
)

echo 🚀 Starting Online Video Enhancer...
echo.

REM Start backend in a new window
echo Starting backend server...
start "Backend Server" cmd /k "cd backend && venv\Scripts\activate && uvicorn main:app --reload --host 0.0.0.0 --port 8000"

REM Wait a moment for backend to start
timeout /t 3 /nobreak >nul

REM Start frontend in a new window
echo Starting frontend server...
start "Frontend Server" cmd /k "cd frontend && npm run dev"

echo.
echo 🎉 Both servers are starting...
echo 📱 Frontend: http://localhost:3000
echo 🔧 Backend API: http://localhost:8000
echo 📚 API Docs: http://localhost:8000/docs
echo.
echo Close the command windows to stop the servers
pause 