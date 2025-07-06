from fastapi import FastAPI, UploadFile, File, BackgroundTasks, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import uuid
import shutil
import subprocess
import logging

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_DIR = "static/uploads"
RESULT_DIR = "static/results"
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(RESULT_DIR, exist_ok=True)

jobs = {}

def upscale_video(input_path, output_path, scale):
    # Placeholder: Replace with Real-ESRGAN or FFmpeg upscaling logic
    import ffmpeg
    (
        ffmpeg
        .input(input_path)
        .filter('scale', scale)
        .output(output_path)
        .run(overwrite_output=True)
    )

@app.post("/upload/")
async def upload_video(background_tasks: BackgroundTasks, file: UploadFile = File(...), scale: str = "1280:720"):
    job_id = str(uuid.uuid4())
    input_path = os.path.join(UPLOAD_DIR, f"{job_id}_{file.filename}")
    output_path = os.path.join(RESULT_DIR, f"{job_id}_upscaled.mp4")
    with open(input_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    jobs[job_id] = {"status": "processing", "output": output_path}
    background_tasks.add_task(upscale_video, input_path, output_path, scale)
    return {"job_id": job_id}

@app.get("/status/{job_id}")
def job_status(job_id: str):
    job = jobs.get(job_id)
    if not job:
        return JSONResponse(status_code=404, content={"error": "Job not found"})
    if os.path.exists(job["output"]):
        job["status"] = "done"
    return {"status": job["status"]}

@app.get("/download/{job_id}")
def download(job_id: str):
    job = jobs.get(job_id)
    if not job or not os.path.exists(job["output"]):
        return JSONResponse(status_code=404, content={"error": "Result not ready"})
    return FileResponse(job["output"], media_type="video/mp4", filename=f"{job_id}_upscaled.mp4")

@app.post("/fix-audio")
async def fix_audio_endpoint(file: UploadFile = File(...)):
    """Fix video by adding silent audio track if missing"""

    if not file.content_type.startswith('video/'):
        raise HTTPException(status_code=400, detail="File must be a video")

    uid = str(uuid.uuid4())
    input_path = f"videos/{uid}_{file.filename}"
    output_path = f"videos/{uid}_audiofixed.mp4"

    try:
        # Save uploaded file
        with open(input_path, "wb") as f:
            content = await file.read()
            f.write(content)

        # Analyze video
        # Placeholder for analyze_video function
        def analyze_video(path):
            # In a real application, this would use a library like moviepy
            # For now, it just returns a dummy analysis
            return {"has_audio": False, "duration": 0, "fps": 0}

        analysis = analyze_video(input_path)

        # If video already has audio, just copy it
        if analysis.get('has_audio'):
            cmd = [
                "ffmpeg",
                "-i", input_path,
                "-c", "copy",  # Copy streams without re-encoding
                "-y",
                output_path
            ]
        else:
            # Add silent audio track
            cmd = [
                "ffmpeg",
                "-i", input_path,
                "-f", "lavfi",
                "-i", "anullsrc=channel_layout=stereo:sample_rate=44100",
                "-shortest",
                "-c:v", "copy",  # Copy video stream
                "-c:a", "aac",
                "-b:a", "128k",
                "-y",
                output_path
            ]

        # Placeholder for logger
        logger = logging.getLogger(__name__)
        logger.info(f"Running audio fix command: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            logger.error(f"FFmpeg error: {result.stderr}")
            raise HTTPException(status_code=500, detail="Failed to fix audio")

        # Clean up input file
        if os.path.exists(input_path):
            os.remove(input_path)

        return {
            "download_url": f"/videos/{uid}_audiofixed.mp4",
            "analysis": analysis,
            "file_id": uid
        }

    except Exception as e:
        # Clean up files on error
        for path in [input_path, output_path]:
            if os.path.exists(path):
                os.remove(path)
        logger.error(f"Error fixing audio: {e}")
        raise HTTPException(status_code=500, detail="Internal server error") 