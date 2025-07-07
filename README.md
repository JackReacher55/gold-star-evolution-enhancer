<<<<<<< HEAD
# Online Video Enhancer

A modern, full-stack web application for AI-powered video upscaling and enhancement. Transform your videos to HD, 2K, or 4K quality with an intuitive drag-and-drop interface.

## ✨ Features

- **Multiple Resolution Options**: Upscale to 720p, 1080p, 2K, or 4K
- **Drag & Drop Interface**: Modern, responsive UI with drag-and-drop file upload
- **Video Preview**: Preview your video before processing
- **Audio Analysis**: Automatic audio detection and optional silent track addition
- **Progress Tracking**: Real-time progress indication during processing
- **High-Quality Processing**: Uses FFmpeg with Lanczos scaling for optimal quality
- **File Size Validation**: 100MB file size limit with proper error handling
- **Cross-Platform**: Works on Windows, macOS, and Linux

## 🚀 Quick Start

### Prerequisites

- **FFmpeg**: Must be installed and available in your system PATH
- **Node.js**: Version 16 or higher
- **Python**: Version 3.8 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Online-Video-Enhancer
   ```

2. **Install FFmpeg**
   
   **Windows:**
   - Download from [FFmpeg official website](https://ffmpeg.org/download.html)
   - Add to system PATH
   
   **macOS:**
   ```bash
   brew install ffmpeg
   ```
   
   **Ubuntu/Debian:**
   ```bash
   sudo apt update
   sudo apt install ffmpeg
   ```

3. **Setup Backend**
   ```bash
   cd backend
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   
   pip install -r requirements.txt
   ```

4. **Setup Frontend**
   ```bash
   cd frontend
   npm install
   ```

### Running the Application

1. **Start the Backend**
   ```bash
   cd backend
   # Activate virtual environment if not already active
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **Start the Frontend**
   ```bash
   cd frontend
   npm run dev
   ```

3. **Access the Application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

## 🏗️ Architecture

### Backend (FastAPI)
- **FastAPI**: Modern, fast web framework for building APIs
- **FFmpeg**: Video processing and upscaling
- **CORS**: Cross-origin resource sharing enabled
- **File Upload**: Secure file handling with validation
- **Error Handling**: Comprehensive error handling and logging

### Frontend (Next.js)
- **Next.js**: React framework for production
- **Tailwind CSS**: Utility-first CSS framework
- **Drag & Drop**: Modern file upload interface
- **Responsive Design**: Mobile-friendly interface
- **Progress Tracking**: Real-time upload and processing status

## 📁 Project Structure

```
Online-Video-Enhancer/
├── backend/
│   ├── main.py              # FastAPI application
│   ├── requirements.txt     # Python dependencies
│   └── venv/               # Virtual environment
├── frontend/
│   ├── pages/
│   │   ├── index.js        # Main application page
│   │   ├── _app.js         # App wrapper
│   │   └── _document.js    # Document wrapper
│   ├── styles/
│   │   └── globals.css     # Global styles with Tailwind
│   ├── package.json        # Node.js dependencies
│   ├── tailwind.config.js  # Tailwind configuration
│   └── postcss.config.js   # PostCSS configuration
├── videos/                 # Processed video storage
└── README.md              # This file
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
# Backend Configuration
MAX_FILE_SIZE=104857600  # 100MB in bytes
UPLOAD_DIR=videos
ALLOWED_ORIGINS=http://localhost:3000

# Optional: Production settings
# CORS_ORIGINS=https://yourdomain.com
# LOG_LEVEL=INFO
```

### FFmpeg Settings

The application uses optimized FFmpeg settings for high-quality output:

- **Video Codec**: H.264 (libx264)
- **Audio Codec**: AAC
- **Scaling**: Lanczos algorithm for best quality
- **Quality**: CRF 18 (high quality)
- **Preset**: Medium (good balance of speed/quality)

## 🚀 Deployment

### Frontend Deployment (Vercel)

1. **Connect to Vercel**
   ```bash
   npm install -g vercel
   vercel login
   ```

2. **Deploy**
   ```bash
   cd frontend
   vercel --prod
   ```

### Backend Deployment (Render)

1. **Create Render Account**
   - Sign up at [render.com](https://render.com)

2. **Deploy Backend**
   - Create new Web Service
   - Connect your GitHub repository
   - Set build command: `pip install -r requirements.txt`
   - Set start command: `uvicorn main:app --host 0.0.0.0 --port $PORT`

3. **Environment Variables**
   - Add environment variables in Render dashboard
   - Update CORS origins to your frontend domain

### Alternative Deployment Options

- **Frontend**: Netlify, AWS S3 + CloudFront
- **Backend**: Heroku, AWS EC2, Google Cloud Run
- **Storage**: AWS S3, Google Cloud Storage (for production)

## 🔒 Security Considerations

### Production Checklist

- [ ] Set up proper CORS origins
- [ ] Implement rate limiting
- [ ] Add authentication if needed
- [ ] Use cloud storage for videos
- [ ] Set up HTTPS
- [ ] Configure proper logging
- [ ] Add input validation
- [ ] Implement file cleanup

### Security Features

- File type validation
- File size limits
- Input sanitization
- Error handling without information leakage
- Temporary file cleanup

## 🧪 Testing

### Backend Testing

```bash
cd backend
python -m pytest tests/
```

### Frontend Testing

```bash
cd frontend
npm test
```

## 📊 Performance

### Optimization Tips

1. **Video Processing**
   - Use hardware acceleration when available
   - Implement video compression before upload
   - Add video format validation

2. **Frontend**
   - Implement lazy loading for large files
   - Add file compression before upload
   - Use CDN for static assets

3. **Backend**
   - Implement caching for processed videos
   - Add background job processing
   - Use async processing for large files

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter any issues:

1. Check the [Issues](https://github.com/yourusername/Online-Video-Enhancer/issues) page
2. Ensure FFmpeg is properly installed
3. Verify all dependencies are installed
4. Check the console for error messages

## 🔮 Future Enhancements

- [ ] AI-powered upscaling with Real-ESRGAN
- [ ] Batch processing
- [ ] Video format conversion
- [ ] Custom quality settings
- [ ] User accounts and history
- [ ] Cloud storage integration
- [ ] Mobile app
- [ ] API rate limiting
- [ ] WebSocket progress updates

---

**Built with ❤️ using FastAPI, Next.js, and FFmpeg** 
=======
# gold-star-evolution-enhancer
>>>>>>> bc6d7467c1845aba7586eb7e124d6a06097c0d2c

## Automated Deployment Instructions

### Frontend (Vercel)
1. Copy `frontend/env.example` to `frontend/.env` and set:
   ```
   NEXT_PUBLIC_API_URL=https://gold-star-evolution-enhancer-backend.onrender.com
   ```
2. Push changes to GitHub. Vercel will auto-deploy.

### Backend (Render)
1. In the Render dashboard, set the environment variable:
   ```
   CORS_ORIGINS=https://gold-star-evolution-enhancer.vercel.app
   ```
2. Push changes to GitHub. Render will auto-deploy.

### Testing
- Visit https://gold-star-evolution-enhancer.vercel.app and verify video upload and processing works end-to-end.
