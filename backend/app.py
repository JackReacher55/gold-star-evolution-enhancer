from fastapi import FastAPI, UploadFile, File, Form, HTTPException, Request
import subprocess
import os
import uuid
from fastapi.middleware.cors import CORSMiddleware
import ffmpeg
from fastapi.staticfiles import StaticFiles
from typing import Optional
import logging
from video_processing import upscale_with_realesrgan

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Gold Star Evolution Enhancer API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or ["http://localhost:3000"] for more security
    allow_credentials=False,  # Must be False when allow_origins is ["*"]
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
    resolution: str = Form("1920:1080")  # Frontend sends resolution like "1920:1080"
):
    """Upload and upscale video to specified resolution using Real-ESRGAN"""
    # Validate file type
    if not file.content_type.startswith('video/'):
        raise HTTPException(status_code=400, detail="File must be a video")

    # Convert resolution to scale factor
    try:
        if ":" in resolution:
            width, height = map(int, resolution.split(":"))
            # Determine scale based on target resolution
            if width >= 3840 or height >= 2160:  # 4K
                scale = "4"
            elif width >= 2560 or height >= 1440:  # 2K
                scale = "3"
            elif width >= 1920 or height >= 1080:  # 1080p
                scale = "2"
            else:  # 720p or lower
                scale = "2"
        else:
            # Fallback to direct scale value
            scale = resolution
            if scale not in ["2", "3", "4"]:
                scale = "2"
    except:
        scale = "2"  # Default to 2x upscaling

    uid = str(uuid.uuid4())
    temp_dir = get_temp_dir()
    input_path = os.path.join(temp_dir, f"{uid}_{file.filename}")
    output_path = os.path.join(temp_dir, f"{uid}_upscaled.mp4")

    try:
        # Save uploaded file and check size (optimized for memory)
        total_size = 0
        with open(input_path, "wb") as f:
            while True:
                chunk = await file.read(1024 * 1024)  # 1MB chunks
                if not chunk:
                    break
                total_size += len(chunk)
                if total_size > 100 * 1024 * 1024:
                    f.close()
                    os.remove(input_path)
                    raise HTTPException(status_code=400, detail="File size must be less than 100MB")
                f.write(chunk)

        logger.info(f"Saved uploaded file to {input_path}")
        # Analyze video
        analysis = analyze_video(input_path)
        logger.info(f"Video analysis: {analysis}")
        
        # Upscale video using Real-ESRGAN
        success = upscale_with_realesrgan(input_path, output_path, scale)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to process video with Real-ESRGAN")
        
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
            "scale": scale,
            "file_id": uid
        }
    except HTTPException as he:
        logger.error(f"HTTPException: {he.detail}")
        for path in [input_path, output_path]:
            if os.path.exists(path):
                os.remove(path)
        raise
    except Exception as e:
        logger.error(f"Error in /upload: {e}")
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
        # Save uploaded file and check size (optimized for memory)
        total_size = 0
        with open(input_path, "wb") as f:
            while True:
                chunk = await file.read(1024 * 1024)  # 1MB chunks
                if not chunk:
                    break
                total_size += len(chunk)
                if total_size > 100 * 1024 * 1024:
                    f.close()
                    os.remove(input_path)
                    raise HTTPException(status_code=400, detail="File size must be less than 100MB")
                f.write(chunk)
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
def root():
    return {"message": "Gold Star Evolution Enhancer backend is running."}

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 10000))
    uvicorn.run("app:app", host="0.0.0.0", port=port) 