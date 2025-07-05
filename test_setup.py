#!/usr/bin/env python3
"""
Test script to verify the Online Video Enhancer setup
"""

import subprocess
import sys
import os

def test_ffmpeg():
    """Test if FFmpeg is installed and accessible"""
    try:
        result = subprocess.run(['ffmpeg', '-version'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print("✅ FFmpeg is installed and working")
            # Extract version
            version_line = result.stdout.split('\n')[0]
            print(f"   Version: {version_line}")
            return True
        else:
            print("❌ FFmpeg is installed but not working properly")
            return False
    except FileNotFoundError:
        print("❌ FFmpeg is not installed or not in PATH")
        print("   Please install FFmpeg from https://ffmpeg.org/download.html")
        return False
    except subprocess.TimeoutExpired:
        print("❌ FFmpeg test timed out")
        return False

def test_python_dependencies():
    """Test if Python dependencies can be imported"""
    dependencies = [
        'fastapi',
        'uvicorn',
        'ffmpeg',
        'pydantic'
    ]
    
    failed = []
    for dep in dependencies:
        try:
            __import__(dep)
            print(f"✅ {dep} is available")
        except ImportError:
            print(f"❌ {dep} is not available")
            failed.append(dep)
    
    if failed:
        print(f"\nMissing dependencies: {', '.join(failed)}")
        print("Please run: pip install -r backend/requirements.txt")
        return False
    return True

def test_directories():
    """Test if required directories exist"""
    directories = ['videos', 'backend', 'frontend']
    
    for directory in directories:
        if os.path.exists(directory):
            print(f"✅ Directory '{directory}' exists")
        else:
            print(f"❌ Directory '{directory}' is missing")
            if directory == 'videos':
                print("   Creating videos directory...")
                os.makedirs(directory, exist_ok=True)
                print("   ✅ Created videos directory")

def main():
    print("🔍 Testing Online Video Enhancer Setup\n")
    
    all_tests_passed = True
    
    # Test directories
    print("📁 Checking directories...")
    test_directories()
    print()
    
    # Test FFmpeg
    print("🎬 Testing FFmpeg...")
    if not test_ffmpeg():
        all_tests_passed = False
    print()
    
    # Test Python dependencies
    print("🐍 Testing Python dependencies...")
    if not test_python_dependencies():
        all_tests_passed = False
    print()
    
    # Summary
    print("📋 Setup Summary:")
    if all_tests_passed:
        print("✅ All tests passed! Your setup is ready.")
        print("\n🚀 To start the application:")
        print("   1. Backend: cd backend && uvicorn main:app --reload")
        print("   2. Frontend: cd frontend && npm run dev")
    else:
        print("❌ Some tests failed. Please fix the issues above.")
        print("\n💡 Common solutions:")
        print("   - Install FFmpeg: https://ffmpeg.org/download.html")
        print("   - Install Python dependencies: pip install -r backend/requirements.txt")
        print("   - Install Node.js dependencies: cd frontend && npm install")

if __name__ == "__main__":
    main() 