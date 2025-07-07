#!/usr/bin/env python3

import sys
import os
import subprocess

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

print(f"Python executable: {sys.executable}")
print(f"Python version: {sys.version}")

try:
    import ffmpeg
    print("✓ ffmpeg import successful")
except ImportError as e:
    print(f"✗ ffmpeg import failed: {e}")
    sys.exit(1)

try:
    from backend.app import app
    print("✓ backend.app import successful")
except ImportError as e:
    print(f"✗ backend.app import failed: {e}")
    sys.exit(1)

if __name__ == "__main__":
    print("Starting FastAPI server...")
    import uvicorn
    uvicorn.run("backend.app:app", host="127.0.0.1", port=8000, reload=True) 