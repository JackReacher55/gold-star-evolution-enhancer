# =============================================================================
# CONFIGURATION MODULE
# =============================================================================
# Centralized configuration management for the video enhancer backend
# Loads environment variables and provides validation

import os
import logging
from typing import List, Optional
from pathlib import Path

# Configure logging
logger = logging.getLogger(__name__)

class Config:
    """Configuration class for the video enhancer backend"""
    
    def __init__(self):
        self._load_environment_variables()
        self._validate_configuration()
    
    def _load_environment_variables(self):
        """Load environment variables with defaults"""
        
        # Server Configuration
        self.PORT = int(os.getenv('PORT', 8000))
        self.HOST = os.getenv('HOST', '127.0.0.1')
        self.DEBUG = os.getenv('DEBUG', 'false').lower() == 'true'
        self.LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO').upper()
        
        # CORS Configuration
        self.CORS_ORIGINS = os.getenv('CORS_ORIGINS', 'https://gold-star-evolution-enhancer.vercel.app').split(',')
        self.CORS_ALLOW_CREDENTIALS = os.getenv('CORS_ALLOW_CREDENTIALS', 'true').lower() == 'true'
        self.CORS_ALLOW_METHODS = os.getenv('CORS_ALLOW_METHODS', 'GET,POST,PUT,DELETE,OPTIONS').split(',')
        self.CORS_ALLOW_HEADERS = os.getenv('CORS_ALLOW_HEADERS', 'Content-Type,Authorization').split(',')
        
        # File Upload Configuration
        self.MAX_FILE_SIZE = self._parse_size(os.getenv('MAX_FILE_SIZE', '100MB'))
        self.UPLOAD_DIR = os.getenv('UPLOAD_DIR', 'videos')
        self.TEMP_DIR = os.getenv('TEMP_DIR', '/tmp')
        
        # Video Processing Configuration
        self.FFMPEG_PATH = os.getenv('FFMPEG_PATH', '/usr/bin/ffmpeg')
        self.REALESRGAN_PATH = os.getenv('REALESRGAN_PATH', '/usr/local/bin/realesrgan')
        self.REALESRGAN_MODEL = os.getenv('REALESRGAN_MODEL', 'realesrgan-x4plus-anime_6B')
        self.VIDEO_SCALE_FACTORS = [int(x) for x in os.getenv('VIDEO_SCALE_FACTORS', '2,4').split(',')]
        self.SUPPORTED_FORMATS = os.getenv('SUPPORTED_FORMATS', 'mp4,avi,mov,mkv,webm').split(',')
        
        # Security Configuration
        self.API_KEY = os.getenv('API_KEY', '')
        self.JWT_SECRET = os.getenv('JWT_SECRET', '')
        self.SESSION_SECRET = os.getenv('SESSION_SECRET', '')
        
        # Rate Limiting
        self.RATE_LIMIT_REQUESTS = int(os.getenv('RATE_LIMIT_REQUESTS', 100))
        self.RATE_LIMIT_WINDOW = int(os.getenv('RATE_LIMIT_WINDOW', 900))
        
        # Monitoring & Logging
        self.LOG_FILE = os.getenv('LOG_FILE', 'logs/app.log')
        self.LOG_MAX_SIZE = self._parse_size(os.getenv('LOG_MAX_SIZE', '10MB'))
        self.LOG_BACKUP_COUNT = int(os.getenv('LOG_BACKUP_COUNT', 5))
        self.HEALTH_CHECK_INTERVAL = int(os.getenv('HEALTH_CHECK_INTERVAL', 30))
        self.HEALTH_CHECK_TIMEOUT = int(os.getenv('HEALTH_CHECK_TIMEOUT', 10))
        
        # Feature Flags
        self.ENABLE_AUDIO_ANALYSIS = os.getenv('ENABLE_AUDIO_ANALYSIS', 'true').lower() == 'true'
        self.ENABLE_VIDEO_PREVIEW = os.getenv('ENABLE_VIDEO_PREVIEW', 'true').lower() == 'true'
        self.ENABLE_BATCH_PROCESSING = os.getenv('ENABLE_BATCH_PROCESSING', 'false').lower() == 'true'
        
        # Custom Configuration
        self.CUSTOM_FFMPEG_ARGS = os.getenv('CUSTOM_FFMPEG_ARGS', '').split() if os.getenv('CUSTOM_FFMPEG_ARGS') else []
        self.CUSTOM_REALESRGAN_ARGS = os.getenv('CUSTOM_REALESRGAN_ARGS', '').split() if os.getenv('CUSTOM_REALESRGAN_ARGS') else []
    
    def _parse_size(self, size_str: str) -> int:
        """Parse size string (e.g., '100MB', '1GB') to bytes"""
        size_str = size_str.upper().strip()
        
        if size_str.endswith('KB'):
            return int(size_str[:-2]) * 1024
        elif size_str.endswith('MB'):
            return int(size_str[:-2]) * 1024 * 1024
        elif size_str.endswith('GB'):
            return int(size_str[:-2]) * 1024 * 1024 * 1024
        elif size_str.endswith('B'):
            return int(size_str[:-1])
        else:
            return int(size_str)
    
    def _validate_configuration(self):
        """Validate configuration values"""
        errors = []
        
        # Validate PORT
        if not (1 <= self.PORT <= 65535):
            errors.append(f"PORT must be between 1 and 65535, got {self.PORT}")
        
        # Validate LOG_LEVEL
        valid_log_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']
        if self.LOG_LEVEL not in valid_log_levels:
            errors.append(f"LOG_LEVEL must be one of {valid_log_levels}, got {self.LOG_LEVEL}")
        
        # Validate MAX_FILE_SIZE
        if self.MAX_FILE_SIZE <= 0:
            errors.append(f"MAX_FILE_SIZE must be positive, got {self.MAX_FILE_SIZE}")
        
        # Validate VIDEO_SCALE_FACTORS
        for factor in self.VIDEO_SCALE_FACTORS:
            if factor not in [2, 4]:
                errors.append(f"VIDEO_SCALE_FACTORS must be 2 or 4, got {factor}")
        
        # Validate paths
        if not os.path.exists(self.FFMPEG_PATH):
            errors.append(f"FFMPEG_PATH does not exist: {self.FFMPEG_PATH}")
        
        if not os.path.exists(self.REALESRGAN_PATH):
            errors.append(f"REALESRGAN_PATH does not exist: {self.REALESRGAN_PATH}")
        
        # Validate directories
        for dir_path in [self.UPLOAD_DIR, self.TEMP_DIR]:
            if not os.path.exists(dir_path):
                try:
                    os.makedirs(dir_path, exist_ok=True)
                    logger.info(f"Created directory: {dir_path}")
                except Exception as e:
                    errors.append(f"Failed to create directory {dir_path}: {e}")
        
        # Validate rate limiting
        if self.RATE_LIMIT_REQUESTS <= 0:
            errors.append(f"RATE_LIMIT_REQUESTS must be positive, got {self.RATE_LIMIT_REQUESTS}")
        
        if self.RATE_LIMIT_WINDOW <= 0:
            errors.append(f"RATE_LIMIT_WINDOW must be positive, got {self.RATE_LIMIT_WINDOW}")
        
        # Report errors
        if errors:
            error_msg = "Configuration validation failed:\n" + "\n".join(f"  • {error}" for error in errors)
            logger.error(error_msg)
            raise ValueError(error_msg)
        
        logger.info("Configuration validation passed")
    
    def get_cors_config(self) -> dict:
        """Get CORS configuration for FastAPI"""
        return {
            "allow_origins": self.CORS_ORIGINS,
            "allow_credentials": self.CORS_ALLOW_CREDENTIALS,
            "allow_methods": self.CORS_ALLOW_METHODS,
            "allow_headers": self.CORS_ALLOW_HEADERS,
        }
    
    def get_logging_config(self) -> dict:
        """Get logging configuration"""
        return {
            "version": 1,
            "disable_existing_loggers": False,
            "formatters": {
                "default": {
                    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
                }
            },
            "handlers": {
                "default": {
                    "class": "logging.StreamHandler",
                    "formatter": "default",
                    "level": self.LOG_LEVEL
                },
                "file": {
                    "class": "logging.handlers.RotatingFileHandler",
                    "filename": self.LOG_FILE,
                    "maxBytes": self.LOG_MAX_SIZE,
                    "backupCount": self.LOG_BACKUP_COUNT,
                    "formatter": "default",
                    "level": self.LOG_LEVEL
                }
            },
            "root": {
                "handlers": ["default", "file"],
                "level": self.LOG_LEVEL
            }
        }
    
    def is_development(self) -> bool:
        """Check if running in development mode"""
        return self.DEBUG
    
    def is_production(self) -> bool:
        """Check if running in production mode"""
        return not self.DEBUG
    
    def get_upload_path(self, filename: str) -> str:
        """Get full path for uploaded file"""
        return os.path.join(self.UPLOAD_DIR, filename)
    
    def get_temp_path(self, filename: str) -> str:
        """Get full path for temporary file"""
        return os.path.join(self.TEMP_DIR, filename)
    
    def validate_file_size(self, size: int) -> bool:
        """Validate if file size is within limits"""
        return size <= self.MAX_FILE_SIZE
    
    def validate_file_format(self, filename: str) -> bool:
        """Validate if file format is supported"""
        ext = Path(filename).suffix.lower().lstrip('.')
        return ext in self.SUPPORTED_FORMATS
    
    def get_ffmpeg_command(self, input_path: str, output_path: str, **kwargs) -> List[str]:
        """Build FFmpeg command with custom arguments"""
        cmd = [self.FFMPEG_PATH, "-i", input_path]
        cmd.extend(self.CUSTOM_FFMPEG_ARGS)
        
        for key, value in kwargs.items():
            if value is not None:
                cmd.extend([f"-{key}", str(value)])
        
        cmd.extend(["-y", output_path])
        return cmd
    
    def get_realesrgan_command(self, input_path: str, output_path: str, scale: int = 2) -> List[str]:
        """Build Real-ESRGAN command with custom arguments"""
        cmd = [self.REALESRGAN_PATH, "-i", input_path, "-o", output_path, "-n", self.REALESRGAN_MODEL, "-s", str(scale)]
        cmd.extend(self.CUSTOM_REALESRGAN_ARGS)
        return cmd
    
    def to_dict(self) -> dict:
        """Convert configuration to dictionary (excluding sensitive data)"""
        return {
            "PORT": self.PORT,
            "HOST": self.HOST,
            "DEBUG": self.DEBUG,
            "LOG_LEVEL": self.LOG_LEVEL,
            "CORS_ORIGINS": self.CORS_ORIGINS,
            "MAX_FILE_SIZE": self.MAX_FILE_SIZE,
            "UPLOAD_DIR": self.UPLOAD_DIR,
            "TEMP_DIR": self.TEMP_DIR,
            "FFMPEG_PATH": self.FFMPEG_PATH,
            "REALESRGAN_PATH": self.REALESRGAN_PATH,
            "REALESRGAN_MODEL": self.REALESRGAN_MODEL,
            "VIDEO_SCALE_FACTORS": self.VIDEO_SCALE_FACTORS,
            "SUPPORTED_FORMATS": self.SUPPORTED_FORMATS,
            "RATE_LIMIT_REQUESTS": self.RATE_LIMIT_REQUESTS,
            "RATE_LIMIT_WINDOW": self.RATE_LIMIT_WINDOW,
            "LOG_FILE": self.LOG_FILE,
            "LOG_MAX_SIZE": self.LOG_MAX_SIZE,
            "LOG_BACKUP_COUNT": self.LOG_BACKUP_COUNT,
            "HEALTH_CHECK_INTERVAL": self.HEALTH_CHECK_INTERVAL,
            "HEALTH_CHECK_TIMEOUT": self.HEALTH_CHECK_TIMEOUT,
            "ENABLE_AUDIO_ANALYSIS": self.ENABLE_AUDIO_ANALYSIS,
            "ENABLE_VIDEO_PREVIEW": self.ENABLE_VIDEO_PREVIEW,
            "ENABLE_BATCH_PROCESSING": self.ENABLE_BATCH_PROCESSING,
            "CUSTOM_FFMPEG_ARGS": self.CUSTOM_FFMPEG_ARGS,
            "CUSTOM_REALESRGAN_ARGS": self.CUSTOM_REALESRGAN_ARGS,
        }

# Global configuration instance
config = Config()

# Export commonly used configuration values
__all__ = ['config', 'Config'] 