#!/usr/bin/env python3
"""
Startup script for Online Video Enhancer
Launches both backend and frontend servers
"""

import subprocess
import sys
import os
import time
import threading
import signal
import platform

def run_backend():
    """Run the FastAPI backend server"""
    print("🚀 Starting backend server...")
    try:
        # Change to backend directory
        os.chdir('backend')
        
        # Check if virtual environment exists
        venv_path = 'venv'
        if not os.path.exists(venv_path):
            print("❌ Virtual environment not found. Please run setup first.")
            return False
        
        # Activate virtual environment and run server
        if platform.system() == "Windows":
            python_path = os.path.join(venv_path, 'Scripts', 'python.exe')
        else:
            python_path = os.path.join(venv_path, 'bin', 'python')
        
        cmd = [python_path, '-m', 'uvicorn', 'main:app', '--reload', '--host', '0.0.0.0', '--port', '8000']
        
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        # Wait a bit for server to start
        time.sleep(3)
        
        if process.poll() is None:
            print("✅ Backend server started at http://localhost:8000")
            return process
        else:
            stdout, stderr = process.communicate()
            print(f"❌ Backend failed to start: {stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error starting backend: {e}")
        return False

def run_frontend():
    """Run the Next.js frontend server"""
    print("🚀 Starting frontend server...")
    try:
        # Change to frontend directory
        os.chdir('frontend')
        
        # Check if node_modules exists
        if not os.path.exists('node_modules'):
            print("❌ Node modules not found. Please run 'npm install' first.")
            return False
        
        # Run the development server
        cmd = ['npm', 'run', 'dev']
        
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        # Wait a bit for server to start
        time.sleep(5)
        
        if process.poll() is None:
            print("✅ Frontend server started at http://localhost:3000")
            return process
        else:
            stdout, stderr = process.communicate()
            print(f"❌ Frontend failed to start: {stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error starting frontend: {e}")
        return False

def setup_instructions():
    """Print setup instructions"""
    print("📋 Setup Instructions:")
    print("1. Install FFmpeg: https://ffmpeg.org/download.html")
    print("2. Setup backend:")
    print("   cd backend")
    print("   python -m venv venv")
    print("   # Windows: venv\\Scripts\\activate")
    print("   # macOS/Linux: source venv/bin/activate")
    print("   pip install -r requirements.txt")
    print("3. Setup frontend:")
    print("   cd frontend")
    print("   npm install")
    print("4. Run this script again")

def main():
    print("🎬 Online Video Enhancer - Startup Script\n")
    
    # Check if we're in the right directory
    if not os.path.exists('backend') or not os.path.exists('frontend'):
        print("❌ Please run this script from the project root directory")
        print("   (where backend/ and frontend/ folders are located)")
        return
    
    # Check if setup is complete
    if not os.path.exists('backend/venv') or not os.path.exists('frontend/node_modules'):
        print("❌ Setup incomplete. Please complete the setup first.")
        setup_instructions()
        return
    
    # Store original directory
    original_dir = os.getcwd()
    
    # Start backend in a separate thread
    backend_process = None
    frontend_process = None
    
    try:
        # Start backend
        backend_thread = threading.Thread(target=lambda: run_backend())
        backend_thread.daemon = True
        backend_thread.start()
        
        # Wait a moment for backend to start
        time.sleep(2)
        
        # Start frontend
        frontend_thread = threading.Thread(target=lambda: run_frontend())
        frontend_thread.daemon = True
        frontend_thread.start()
        
        print("\n🎉 Both servers are starting...")
        print("📱 Frontend: http://localhost:3000")
        print("🔧 Backend API: http://localhost:8000")
        print("📚 API Docs: http://localhost:8000/docs")
        print("\nPress Ctrl+C to stop both servers")
        
        # Keep the main thread alive
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\n🛑 Shutting down servers...")
        
        # Cleanup processes
        if backend_process:
            backend_process.terminate()
        if frontend_process:
            frontend_process.terminate()
        
        print("✅ Servers stopped")

if __name__ == "__main__":
    main() 