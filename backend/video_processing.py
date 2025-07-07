import os
import subprocess
import uuid
import shutil
import logging
import tempfile

logger = logging.getLogger(__name__)

# Path to the Real-ESRGAN executable (update if needed)
REALESRGAN_BIN = "realesrgan-ncnn-vulkan"  # or 'realesrgan' if using the Python package

# Supported image extension for Real-ESRGAN
FRAME_EXT = "png"

def get_temp_dir():
    """Get temporary directory that works on both local and cloud environments"""
    temp_dir = tempfile.gettempdir()
    if not os.access(temp_dir, os.W_OK):
        # Fallback to current directory if temp is not writable
        temp_dir = "videos"
        os.makedirs(temp_dir, exist_ok=True)
    return temp_dir

def upscale_with_realesrgan(input_path, output_path, scale="2"):
    """
    Upscale a video using Real-ESRGAN with optimized processing:
    1. Extract frames with optimized settings
    2. Upscale frames with Real-ESRGAN
    3. Reassemble video with high quality
    """
    temp_dir = get_temp_dir()
    work_dir = os.path.join(temp_dir, f"realesrgan_{uuid.uuid4()}")
    frames_dir = os.path.join(work_dir, "frames")
    upscaled_dir = os.path.join(work_dir, "upscaled")
    
    os.makedirs(frames_dir, exist_ok=True)
    os.makedirs(upscaled_dir, exist_ok=True)
    
    try:
        # 1. Extract frames with optimized settings
        extract_cmd = [
            "ffmpeg", "-i", input_path,
            "-vf", "fps=30",  # Limit to 30fps for processing efficiency
            "-q:v", "2",  # High quality frames
            os.path.join(frames_dir, f"frame_%06d.{FRAME_EXT}")
        ]
        logger.info(f"Extracting frames: {' '.join(extract_cmd)}")
        result = subprocess.run(extract_cmd, capture_output=True, text=True, timeout=300)
        if result.returncode != 0:
            logger.error(f"FFmpeg extract error: {result.stderr}")
            return False

        # 2. Upscale frames with Real-ESRGAN (process in batches for memory efficiency)
        frame_files = sorted([f for f in os.listdir(frames_dir) if f.endswith(f".{FRAME_EXT}")])
        batch_size = 10  # Process 10 frames at a time
        
        for i in range(0, len(frame_files), batch_size):
            batch = frame_files[i:i + batch_size]
            for frame in batch:
                in_frame = os.path.join(frames_dir, frame)
                out_frame = os.path.join(upscaled_dir, frame)
                
                realsr_cmd = [
                    REALESRGAN_BIN,
                    "-i", in_frame,
                    "-o", out_frame,
                    "-s", scale,
                    "-n", "realesrgan-x4plus"  # Use the best model
                ]
                
                logger.info(f"Upscaling frame {frame} with scale {scale}")
                result = subprocess.run(realsr_cmd, capture_output=True, text=True, timeout=60)
                if result.returncode != 0:
                    logger.error(f"Real-ESRGAN error for {frame}: {result.stderr}")
                    return False

        # 3. Reassemble video with high quality settings
        # Get original framerate and audio info
        probe_cmd = [
            "ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries",
            "stream=r_frame_rate", "-of", "default=noprint_wrappers=1:nokey=1", input_path
        ]
        
        try:
            framerate = subprocess.check_output(probe_cmd, timeout=30).decode().strip()
            if "/" in framerate:
                num, denom = map(int, framerate.split("/"))
                fps = num / denom if denom != 0 else 30
            else:
                fps = float(framerate)
        except:
            fps = 30  # Default framerate
        
        # Check if input has audio
        audio_check_cmd = [
            "ffprobe", "-v", "error", "-select_streams", "a", "-show_entries",
            "stream=codec_type", "-of", "default=noprint_wrappers=1:nokey=1", input_path
        ]
        
        has_audio = False
        try:
            audio_result = subprocess.run(audio_check_cmd, capture_output=True, text=True, timeout=30)
            has_audio = "audio" in audio_result.stdout
        except:
            pass
        
        # Build reassemble command
        reassemble_cmd = [
            "ffmpeg", "-framerate", str(fps), "-i",
            os.path.join(upscaled_dir, f"frame_%06d.{FRAME_EXT}")
        ]
        
        if has_audio:
            reassemble_cmd.extend(["-i", input_path, "-map", "0:v:0", "-map", "1:a:0?"])
        else:
            reassemble_cmd.extend(["-i", input_path, "-map", "0:v:0"])
        
        reassemble_cmd.extend([
            "-c:v", "libx264", "-preset", "medium", "-crf", "18",
            "-c:a", "aac", "-b:a", "128k", "-movflags", "+faststart", "-y", output_path
        ])
        
        logger.info(f"Reassembling video: {' '.join(reassemble_cmd)}")
        result = subprocess.run(reassemble_cmd, capture_output=True, text=True, timeout=600)
        if result.returncode != 0:
            logger.error(f"FFmpeg reassemble error: {result.stderr}")
            return False
            
        logger.info(f"Successfully upscaled video to {output_path}")
        return True
        
    except subprocess.TimeoutExpired:
        logger.error("Process timed out")
        return False
    except Exception as e:
        logger.error(f"Error in Real-ESRGAN upscaling: {e}", exc_info=True)
        return False
    finally:
        # Clean up temp dirs
        try:
            shutil.rmtree(work_dir, ignore_errors=True)
        except:
            pass 