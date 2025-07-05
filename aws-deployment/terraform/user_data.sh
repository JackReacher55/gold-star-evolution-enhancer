#!/bin/bash

# User data script for EC2 instance setup
# This script will install all necessary software and configure the backend

set -e

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    ffmpeg \
    git \
    curl \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Docker (optional, for containerized deployment)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Create application directory
echo "Setting up application directory..."
mkdir -p /opt/video-enhancer
cd /opt/video-enhancer

# Clone the repository (you'll need to update this with your actual repo URL)
# git clone https://github.com/yourusername/online-video-enhancer.git .

# For now, we'll create the backend structure manually
mkdir -p backend
cd backend

# Create virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Create requirements.txt
cat > requirements.txt << 'EOF'
fastapi==0.115.14
uvicorn[standard]==0.35.0
python-multipart==0.0.20
ffmpeg-python==0.2.0
pydantic==2.11.7
python-dotenv==1.0.0
boto3==1.34.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
EOF

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Create the main application file
cat > main.py << 'EOF'
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
import subprocess
import os
import uuid
from fastapi.middleware.cors import CORSMiddleware
import ffmpeg
from fastapi.staticfiles import StaticFiles
from typing import Optional
import logging
import boto3
from botocore.exceptions import ClientError

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Online Video Enhancer API", version="1.0.0")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update this with your domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# S3 configuration
s3_client = boto3.client('s3')
S3_VIDEOS_BUCKET = os.getenv('S3_VIDEOS_BUCKET', 'video-enhancer-videos')

# Create videos directory
if not os.path.exists("videos"):
    os.makedirs("videos")

def analyze_video(input_path: str) -> dict:
    """Analyze video file and return metadata"""
    try:
        probe = ffmpeg.probe(input_path)
        video_streams = [stream for stream in probe['streams'] if stream['codec_type'] == 'video']
        audio_streams = [stream for stream in probe['streams'] if stream['codec_type'] == 'audio']
        
        video_info = video_streams[0] if video_streams else None
        audio_info = audio_streams[0] if audio_streams else None
        
        return {
            "has_video": bool(video_streams),
            "has_audio": bool(audio_streams),
            "video_codec": video_info.get('codec_name') if video_info else None,
            "audio_codec": audio_info.get('codec_name') if audio_info else None,
            "duration": float(probe.get('format', {}).get('duration', 0)),
            "size": int(probe.get('format', {}).get('size', 0)),
            "bitrate": int(probe.get('format', {}).get('bit_rate', 0)),
            "width": int(video_info.get('width', 0)) if video_info else 0,
            "height": int(video_info.get('height', 0)) if video_info else 0,
            "fps": eval(video_info.get('r_frame_rate', '0/1')) if video_info else 0
        }
    except Exception as e:
        logger.error(f"Error analyzing video: {e}")
        return {"error": str(e)}

def upscale_video(input_path: str, output_path: str, resolution: str = "1920:1080") -> bool:
    """Upscale video to specified resolution"""
    try:
        # Parse resolution
        width, height = map(int, resolution.split(':'))
        
        # Enhanced FFmpeg command with better quality settings
        cmd = [
            "ffmpeg",
            "-i", input_path,
            "-vf", f"scale={width}:{height}:flags=lanczos",
            "-c:v", "libx264",
            "-preset", "medium",
            "-crf", "18",
            "-c:a", "aac",
            "-b:a", "128k",
            "-movflags", "+faststart",
            "-y",
            output_path
        ]
        
        logger.info(f"Running FFmpeg command: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            logger.error(f"FFmpeg error: {result.stderr}")
            return False
            
        return True
    except Exception as e:
        logger.error(f"Error upscaling video: {e}")
        return False

def upload_to_s3(file_path: str, s3_key: str) -> str:
    """Upload file to S3 and return public URL"""
    try:
        s3_client.upload_file(file_path, S3_VIDEOS_BUCKET, s3_key)
        return f"https://{S3_VIDEOS_BUCKET}.s3.amazonaws.com/{s3_key}"
    except ClientError as e:
        logger.error(f"Error uploading to S3: {e}")
        return None

@app.post("/upload")
async def upscale_video_endpoint(
    file: UploadFile = File(...),
    resolution: str = Form("1920:1080")
):
    """Upload and upscale video to specified resolution"""
    
    # Validate file type
    if not file.content_type.startswith('video/'):
        raise HTTPException(status_code=400, detail="File must be a video")
    
    # Validate file size (100MB limit)
    if file.size > 100 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="File size must be less than 100MB")
    
    # Validate resolution format
    try:
        width, height = map(int, resolution.split(':'))
        if width <= 0 or height <= 0:
            raise ValueError("Invalid resolution")
    except:
        raise HTTPException(status_code=400, detail="Invalid resolution format. Use WIDTH:HEIGHT")
    
    uid = str(uuid.uuid4())
    input_path = f"videos/{uid}_{file.filename}"
    output_path = f"videos/{uid}_upscaled.mp4"

    try:
        # Save uploaded file
        with open(input_path, "wb") as f:
            content = await file.read()
            f.write(content)
        
        # Analyze video
        analysis = analyze_video(input_path)
        
        # Upscale video
        success = upscale_video(input_path, output_path, resolution)
        
        if not success:
            raise HTTPException(status_code=500, detail="Failed to process video")
        
        # Upload to S3
        s3_key = f"{uid}_upscaled.mp4"
        download_url = upload_to_s3(output_path, s3_key)
        
        if not download_url:
            # Fallback to local file
            download_url = f"/videos/{uid}_upscaled.mp4"
        
        # Clean up local files
        for path in [input_path, output_path]:
            if os.path.exists(path):
                os.remove(path)
        
        return {
            "download_url": download_url,
            "analysis": analysis,
            "resolution": resolution,
            "file_id": uid
        }
        
    except Exception as e:
        # Clean up files on error
        for path in [input_path, output_path]:
            if os.path.exists(path):
                os.remove(path)
        logger.error(f"Error processing video: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "video-enhancer"}

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Online Video Enhancer API",
        "version": "1.0.0",
        "endpoints": {
            "upload": "POST /upload - Upload and upscale video",
            "health": "GET /health - Health check"
        }
    }
EOF

# Create systemd service for the backend
echo "Creating systemd service..."
cat > /etc/systemd/system/video-enhancer.service << EOF
[Unit]
Description=Video Enhancer Backend
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/video-enhancer/backend
Environment=PATH=/opt/video-enhancer/backend/venv/bin
ExecStart=/opt/video-enhancer/backend/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Configure nginx
echo "Configuring nginx..."
cat > /etc/nginx/sites-available/video-enhancer << EOF
server {
    listen 80;
    server_name api.${domain_name};

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable nginx site
ln -sf /etc/nginx/sites-available/video-enhancer /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Start services
echo "Starting services..."
systemctl daemon-reload
systemctl enable video-enhancer
systemctl start video-enhancer
systemctl restart nginx

# Install certbot for SSL
echo "Installing certbot..."
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

# Create SSL certificate
echo "Setting up SSL certificate..."
certbot --nginx -d api.${domain_name} --non-interactive --agree-tos --email admin@${domain_name}

# Setup automatic renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -

echo "Setup complete! Backend is running on port 8000"
echo "API URL: https://api.${domain_name}" 