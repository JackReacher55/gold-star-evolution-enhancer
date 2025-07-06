from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Request
import subprocess
import os
import uuid
from fastapi.middleware.cors import CORSMiddleware
import ffmpeg
from fastapi.staticfiles import StaticFiles
from typing import Optional
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Gold Star Evolution Enhancer API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or ["http://localhost:3000"] for more security
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if not os.path.exists("videos"):
    os.makedirs("videos")

# Serve static files from the videos directory
app.mount("/videos", StaticFiles(directory="videos"), name="videos")

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
            "-vf", f"scale={width}:{height}:flags=lanczos",  # Use Lanczos scaling for better quality
            "-c:v", "libx264",
            "-preset", "medium",  # Better quality than 'fast'
            "-crf", "18",  # High quality (lower = better quality)
            "-c:a", "aac",
            "-b:a", "128k",  # Audio bitrate
            "-movflags", "+faststart",  # Optimize for web streaming
            "-y",  # Overwrite output file
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

# Helper to get base URL for download links
def get_base_url(request: Request) -> str:
    return str(request.base_url).rstrip('/')

# Helper to get temp directory (use /tmp if available, else videos)
def get_temp_dir() -> str:
    tmp = "/tmp"
    if os.path.isdir(tmp) and os.access(tmp, os.W_OK):
        return tmp
    return "videos"

@app.post("/upload")
async def upscale_video_endpoint(
    request: Request,
    file: UploadFile = File(...),
    resolution: str = Form("1920:1080")
):
    """Upload and upscale video to specified resolution"""
    # Validate file type
    if not file.content_type.startswith('video/'):
        raise HTTPException(status_code=400, detail="File must be a video")

    # Validate resolution format
    try:
        width, height = map(int, resolution.split(':'))
        if width <= 0 or height <= 0:
            raise ValueError("Invalid resolution")
    except:
        raise HTTPException(status_code=400, detail="Invalid resolution format. Use WIDTH:HEIGHT")

    uid = str(uuid.uuid4())
    temp_dir = get_temp_dir()
    input_path = os.path.join(temp_dir, f"{uid}_{file.filename}")
    output_path = os.path.join(temp_dir, f"{uid}_upscaled.mp4")

    try:
        # Save uploaded file and check size
        content = await file.read()
        if len(content) > 100 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File size must be less than 100MB")
        with open(input_path, "wb") as f:
            f.write(content)

        logger.info(f"Saved uploaded file to {input_path}")
        # Analyze video
        analysis = analyze_video(input_path)
        logger.info(f"Video analysis: {analysis}")
        # Upscale video
        success = upscale_video(input_path, output_path, resolution)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to process video")
        # Clean up input file
        if os.path.exists(input_path):
            os.remove(input_path)
        # Build full download URL
        base_url = get_base_url(request)
        download_url = f"{base_url}/videos/{uid}_upscaled.mp4"
        return {
            "download_url": download_url,
            "analysis": analysis,
            "resolution": resolution,
            "file_id": uid
        }
    except HTTPException as he:
        logger.error(f"HTTPException: {he.detail}")
        for path in [input_path, output_path]:
            if os.path.exists(path):
                os.remove(path)
        raise
    except Exception as e:
        for path in [input_path, output_path]:
            if os.path.exists(path):
                os.remove(path)
        logger.error(f"Error processing video: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")

@app.post("/fix-audio")
async def fix_audio_endpoint(request: Request, file: UploadFile = File(...)):
    """Fix video by adding silent audio track if missing"""
    if not file.content_type.startswith('video/'):
        raise HTTPException(status_code=400, detail="File must be a video")
    uid = str(uuid.uuid4())
    temp_dir = get_temp_dir()
    input_path = os.path.join(temp_dir, f"{uid}_{file.filename}")
    output_path = os.path.join(temp_dir, f"{uid}_audiofixed.mp4")
    try:
        content = await file.read()
        if len(content) > 100 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File size must be less than 100MB")
        with open(input_path, "wb") as f:
            f.write(content)
        logger.info(f"Saved uploaded file to {input_path}")
        analysis = analyze_video(input_path)
        logger.info(f"Video analysis: {analysis}")
        if analysis.get('has_audio'):
            cmd = [
                "ffmpeg", "-i", input_path, "-c", "copy", "-y", output_path
            ]
        else:
            cmd = [
                "ffmpeg", "-i", input_path, "-f", "lavfi", "-i", "anullsrc=channel_layout=stereo:sample_rate=44100",
                "-shortest", "-c:v", "copy", "-c:a", "aac", "-b:a", "128k", "-y", output_path
            ]
        logger.info(f"Running audio fix command: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            logger.error(f"FFmpeg error: {result.stderr}")
            raise HTTPException(status_code=500, detail="Failed to fix audio")
        if os.path.exists(input_path):
            os.remove(input_path)
        base_url = get_base_url(request)
        download_url = f"{base_url}/videos/{uid}_audiofixed.mp4"
        return {
            "download_url": download_url,
            "analysis": analysis,
            "file_id": uid
        }
    except HTTPException as he:
        logger.error(f"HTTPException: {he.detail}")
        for path in [input_path, output_path]:
            if os.path.exists(path):
                os.remove(path)
        raise
    except Exception as e:
        for path in [input_path, output_path]:
            if os.path.exists(path):
                os.remove(path)
        logger.error(f"Error fixing audio: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "gold-star-evolution-enhancer"}

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "Gold Star Evolution Enhancer API",
        "version": "1.0.0",
        "description": "Professional AI-powered video enhancement service",
        "endpoints": {
            "upload": "POST /upload - Upload and upscale video",
            "fix_audio": "POST /fix-audio - Fix video audio",
            "health": "GET /health - Health check"
        },
        "features": [
            "AI-powered video upscaling",
            "Multiple resolution support (720p, 1080p, 2K, 4K)",
            "Audio analysis and fixing",
            "Professional quality output",
            "Fast processing with advanced algorithms"
        ]
    } 