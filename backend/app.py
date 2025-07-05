from fastapi import FastAPI, UploadFile, File, BackgroundTasks
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import os
import uuid
import shutil

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