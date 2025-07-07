#!/usr/bin/env python3
"""
Test script to verify the website is working
"""
import requests
import time

def test_backend():
    try:
        # Test health endpoint
        response = requests.get('http://127.0.0.1:8000/health', timeout=5)
        if response.status_code == 200:
            print("✅ Backend is running!")
            print(f"   Health check: {response.json()}")
            return True
        else:
            print(f"❌ Backend health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Backend test failed: {e}")
        return False

def test_frontend():
    try:
        # Test frontend
        response = requests.get('http://localhost:3000', timeout=5)
        if response.status_code == 200:
            print("✅ Frontend is running!")
            return True
        else:
            print(f"❌ Frontend test failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Frontend test failed: {e}")
        return False

def main():
    print("🌐 Testing Gold Star Evolution Enhancer Website")
    print("=" * 50)
    
    backend_ok = test_backend()
    frontend_ok = test_frontend()
    
    print("\n" + "=" * 50)
    if backend_ok and frontend_ok:
        print("🎉 Website is fully functional!")
        print("\n📱 Access your website:")
        print("   Frontend: http://localhost:3000")
        print("   Backend API: http://localhost:8000")
        print("   Health Check: http://localhost:8000/health")
        print("\n🚀 Your AI-powered video enhancement website is ready!")
    else:
        print("❌ Some components are not working properly.")
        if not backend_ok:
            print("   - Backend server needs to be started")
        if not frontend_ok:
            print("   - Frontend server needs to be started")

if __name__ == "__main__":
    main() 