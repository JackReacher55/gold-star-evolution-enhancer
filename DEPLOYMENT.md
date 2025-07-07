# 🚀 Deployment Guide

This guide covers automated deployment to GitHub, Vercel (frontend), and Render (backend).

## 📋 Prerequisites

- Git installed and configured
- GitHub repository set up
- Vercel account (for frontend)
- Render account (for backend)
- Node.js and npm (for Vercel CLI)

## 🔧 Setup Instructions

### 1. GitHub Repository Setup

```bash
# Initialize git repository (if not already done)
git init
git remote add origin https://github.com/yourusername/online-video-enhancer.git
git branch -M main
```

### 2. Vercel Setup

1. **Install Vercel CLI:**
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel:**
   ```bash
   vercel login
   ```

3. **Configure Vercel:**
   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Create new project
   - Connect your GitHub repository
   - Set root directory to `frontend`
   - Add environment variable: `NEXT_PUBLIC_API_URL` pointing to your Render backend URL

### 3. Render Setup

1. **Create Render Account:**
   - Visit [Render.com](https://render.com)
   - Sign up and create account

2. **Create Web Service:**
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Set root directory to `backend`
   - Build command: `pip install -r requirements.txt`
   - Start command: `uvicorn app:app --host 0.0.0.0 --port $PORT`

3. **Environment Variables:**
   ```
   PYTHON_VERSION=3.11.0
   CORS_ORIGINS=*
   MAX_FILE_SIZE=100MB
   ```

## 🚀 Deployment Methods

### Method 1: Quick Deployment Script

```powershell
# Run the quick deployment script
.\quick-deploy.ps1
```

This script will:
- Commit and push changes to GitHub
- Deploy frontend to Vercel (if CLI is installed)
- Provide instructions for Render deployment

### Method 2: Comprehensive Deployment Script

```powershell
# Full deployment with options
.\deploy.ps1 -CommitMessage "Your commit message" -Force

# Skip specific deployments
.\deploy.ps1 -SkipVercel -SkipRender
```

### Method 3: GitHub Actions (Automatic)

The `.github/workflows/deploy.yml` file will automatically deploy when you push to the main branch.

**Required Secrets:**
- `VERCEL_TOKEN`: Your Vercel API token
- `VERCEL_ORG_ID`: Your Vercel organization ID
- `VERCEL_PROJECT_ID`: Your Vercel project ID
- `RENDER_WEBHOOK_URL`: Your Render webhook URL
- `FRONTEND_URL`: Your Vercel frontend URL
- `BACKEND_URL`: Your Render backend URL

## 🔑 Getting API Keys and Tokens

### Vercel Token
1. Go to [Vercel Account Settings](https://vercel.com/account/tokens)
2. Click "Create Token"
3. Give it a name and select "Full Account" scope
4. Copy the token

### Vercel Project Info
```bash
# Get project info
vercel ls
# Or check vercel.json in your project
```

### Render Webhook
1. Go to your Render service dashboard
2. Navigate to "Settings" → "Build & Deploy"
3. Copy the webhook URL

## 📊 Monitoring Deployments

### Vercel
- Dashboard: https://vercel.com/dashboard
- Deployment logs available in real-time
- Automatic preview deployments for PRs

### Render
- Dashboard: https://dashboard.render.com
- Build logs and deployment status
- Health check monitoring

### GitHub Actions
- Go to your repository → "Actions" tab
- View workflow runs and logs
- Set up notifications for deployment status

## 🛠️ Troubleshooting

### Common Issues

1. **Vercel Build Fails:**
   - Check Node.js version compatibility
   - Verify `package.json` and dependencies
   - Check build logs in Vercel dashboard

2. **Render Deployment Fails:**
   - Verify Python version (3.11+)
   - Check `requirements.txt` for missing dependencies
   - Ensure `app.py` is in the correct location

3. **GitHub Actions Fail:**
   - Verify all secrets are set correctly
   - Check workflow file syntax
   - Ensure repository permissions

### Manual Deployment Commands

```bash
# Manual Vercel deployment
cd frontend
vercel --prod

# Manual Render deployment
# Use Render dashboard or webhook

# Check deployment status
curl https://your-frontend.vercel.app/health
curl https://your-backend.onrender.com/health
```

## 🔄 Continuous Deployment

Once set up, deployments will happen automatically:

1. **Push to main branch** → Triggers GitHub Actions
2. **GitHub Actions** → Deploys to Vercel and Render
3. **Health checks** → Verifies deployments are successful

## 📞 Support

- **Vercel Docs:** https://vercel.com/docs
- **Render Docs:** https://render.com/docs
- **GitHub Actions Docs:** https://docs.github.com/en/actions

## 🎯 Next Steps

After successful deployment:

1. Test video upload functionality
2. Verify Real-ESRGAN integration
3. Monitor performance and logs
4. Set up monitoring and alerts
5. Configure custom domains (optional) 