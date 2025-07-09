# Gold Star Evolution Enhancer

A modern, privacy-focused AI video upscaling web app.

## Features
- Simple drag-and-drop video upload
- Choose output resolution (720p, 1080p, 2K, 4K)
- Fast, secure, and privacy-focused
- Download enhanced video after processing

## Quick Start

### 1. Clone and Set Up
```bash
git clone <your-new-repo-url>
cd gold-star-evolution-enhancer
cd frontend && npm install && cd ..
cd backend && pip install -r requirements.txt && cd ..
```

### 2. Local Development
- **Backend:**
  ```bash
  cd backend
  uvicorn app:app --reload --host 0.0.0.0 --port 8000
  ```
- **Frontend:**
  ```bash
  cd frontend
  npm run dev
  ```

### 3. Deploy
- **GitHub:** Push your code to a new GitHub repository.
- **Vercel:** Import the repo, set root to `frontend`, and set `NEXT_PUBLIC_API_URL` to your backend URL.
- **Render:** Import the repo, set root to `backend`, and use `uvicorn app:app --host 0.0.0.0 --port $PORT` as the start command.

## Notes
- No audio analysis features are present.
- All code is free-tier friendly and deployable on Vercel/Render.
