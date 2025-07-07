#!/usr/bin/env python3
"""
Test script to check if the backend server is working
"""
import requests
import json

def test_server():
    try:
        # Test health endpoint
        response = requests.get('http://127.0.0.1:8000/health')
        print(f"Health check status: {response.status_code}")
        print(f"Health check response: {response.json()}")
        
        # Test root endpoint
        response = requests.get('http://127.0.0.1:8000/')
        print(f"Root endpoint status: {response.status_code}")
        print(f"Root endpoint response: {json.dumps(response.json(), indent=2)}")
        
        print("\n✅ Server is running successfully!")
        
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to server. Is it running?")
    except Exception as e:
        print(f"❌ Error testing server: {e}")

if __name__ == "__main__":
    test_server() 