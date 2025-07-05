# 🚀 Quick Deployment Guide - Gold Star Evolution Enhancer

## ✅ Prerequisites Met
- ✅ Signed in to Render
- ✅ Signed in to GitLab
- ✅ Frontend built and ready

---

## 🎯 Step 1: Deploy Frontend to Vercel

### 1. Go to Vercel
- Open: https://vercel.com
- Sign in with your account

### 2. Create New Project
- Click **"New Project"**
- Click **"Upload"** (since you don't have Git connected)

### 3. Upload Frontend
- Select the **`frontend`** folder from your project
- Click **"Upload"**

### 4. Configure Project
- **Project Name**: `goldstar-evolution-enhancer`
- **Framework Preset**: `Next.js`
- **Root Directory**: `./` (leave as default)
- Click **"Deploy"**

### 5. Wait for Deployment
- Deployment takes 2-5 minutes
- Copy your Vercel URL (e.g., `https://your-project.vercel.app`)

---

## 🔧 Step 2: Deploy Backend to Render

### 1. Go to Render
- Open: https://render.com
- Sign in with your account

### 2. Create Web Service
- Click **"New Web Service"**
- Click **"Upload"** or connect your GitLab repository

### 3. Upload Backend
- If uploading: Select the **`backend`** folder
- If using GitLab: Select your repository

### 4. Configure Settings
- **Name**: `goldstar-evolution-enhancer-backend`
- **Root Directory**: `backend`
- **Runtime**: `Python 3`
- **Build Command**: `pip install -r requirements.txt`
- **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### 5. Add Environment Variable
- Click **"Environment"**
- Add new variable:
  - **Key**: `CORS_ORIGINS`
  - **Value**: `[Your Vercel URL from Step 1]`

### 6. Deploy
- Click **"Create Web Service"**
- Wait 5-10 minutes for deployment
- Copy your Render URL (e.g., `https://your-backend.onrender.com`)

---

## 🔗 Step 3: Connect Frontend to Backend

### 1. Go Back to Vercel
- Open your Vercel dashboard
- Select your `goldstar-evolution-enhancer` project

### 2. Add Environment Variable
- Go to **Settings** → **Environment Variables**
- Add new variable:
  - **Name**: `NEXT_PUBLIC_API_URL`
  - **Value**: `[Your Render URL from Step 2]`
- Click **"Save"**

### 3. Redeploy
- Go to **Deployments** tab
- Click **"Redeploy"** on the latest deployment
- Wait for redeployment to complete

---

## 🎉 Your Gold Star Evolution Enhancer is Live!

### Test Your Application
1. Open your Vercel URL
2. Upload a video file
3. Select resolution (720p, 1080p, 2K, 4K)
4. Click "🌟 Enhance Video"
5. Download your enhanced video!

### Features Available
✅ AI-powered video upscaling  
✅ Multiple resolution support  
✅ Audio analysis and fixing  
✅ Professional quality output  
✅ Beautiful modern UI  
✅ Drag-and-drop upload  
✅ Real-time progress tracking  

### Cost: $0/month!

---

## 🌐 Custom Domain (Optional)

To use `goldstarevolutionenhancer.com`:

1. **Purchase Domain**: Buy from GoDaddy, Namecheap, etc.
2. **Configure DNS**:
   ```
   CNAME @ → cname.vercel-dns.com
   CNAME api → [Your Render URL]
   ```
3. **Add to Vercel**: Dashboard → Settings → Domains
4. **Wait**: DNS propagation (up to 48 hours)

---

## 🚀 Ready to Deploy?

Run the automated script:
```bash
.\free-deployment\auto-deploy.bat
```

This will guide you through each step and collect your URLs automatically! 