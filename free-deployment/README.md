# 🌐 Free Deployment Guide - Online Video Enhancer

This guide will help you deploy your Online Video Enhancer completely free with a free domain name!

## 🎯 **Free Deployment Options**

### **Option 1: Vercel + Render (Recommended)**
- **Frontend**: Vercel (free tier)
- **Backend**: Render (free tier)
- **Domain**: Free subdomain or free domain

### **Option 2: Netlify + Railway**
- **Frontend**: Netlify (free tier)
- **Backend**: Railway (free tier)
- **Domain**: Free subdomain

### **Option 3: GitHub Pages + Heroku**
- **Frontend**: GitHub Pages (free)
- **Backend**: Heroku (free tier)
- **Domain**: Free subdomain

## 🚀 **Quick Free Deployment (Option 1)**

### **Step 1: Prepare Your Repository**
```bash
# Initialize Git repository
git init
git add .
git commit -m "Initial commit"

# Push to GitHub
git remote add origin https://github.com/yourusername/online-video-enhancer.git
git push -u origin main
```

### **Step 2: Deploy Frontend to Vercel**

1. **Go to [vercel.com](https://vercel.com)**
2. **Sign up with GitHub**
3. **Click "New Project"**
4. **Import your repository**
5. **Configure settings:**
   - Framework Preset: Next.js
   - Root Directory: `frontend`
   - Build Command: `npm run build`
   - Output Directory: `.next`
6. **Click "Deploy"**

### **Step 3: Deploy Backend to Render**

1. **Go to [render.com](https://render.com)**
2. **Sign up with GitHub**
3. **Click "New Web Service"**
4. **Connect your repository**
5. **Configure settings:**
   - Name: `video-enhancer-backend`
   - Root Directory: `backend`
   - Runtime: Python 3
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
6. **Add Environment Variable:**
   - Key: `CORS_ORIGINS`
   - Value: `https://your-vercel-url.vercel.app`
7. **Click "Create Web Service"**

### **Step 4: Update Frontend API URL**

1. **Go to Vercel dashboard**
2. **Select your project**
3. **Go to Settings → Environment Variables**
4. **Add:**
   - Name: `NEXT_PUBLIC_API_URL`
   - Value: `https://your-render-url.onrender.com`
5. **Redeploy the project**

## 🌍 **Free Domain Options**

### **Option A: Freenom (Free Domains)**
1. **Go to [freenom.com](https://freenom.com)**
2. **Search for available domains:**
   - `.tk` (Tokelau)
   - `.ml` (Mali)
   - `.ga` (Gabon)
   - `.cf` (Central African Republic)
   - `.gq` (Equatorial Guinea)
3. **Register your free domain**
4. **Configure DNS to point to your Vercel/Render URLs**

### **Option B: Eu.org (Free Subdomains)**
1. **Go to [nic.eu.org](https://nic.eu.org)**
2. **Apply for a free subdomain**
3. **Wait for approval (can take weeks)**
4. **Configure DNS settings**

### **Option C: Vercel/Render Subdomains**
- **Vercel**: `your-app.vercel.app`
- **Render**: `your-app.onrender.com`
- **Netlify**: `your-app.netlify.app`

### **Option D: Custom Subdomain with Vercel**
1. **In Vercel dashboard → Settings → Domains**
2. **Add your custom subdomain**
3. **Configure DNS at your domain provider**

## 🔧 **Automated Deployment Script**

I've created an automated script to help with deployment:

```bash
# Make script executable
chmod +x free-deployment/deploy-free.sh

# Run the deployment script
./free-deployment/deploy-free.sh
```

## 💰 **Cost Breakdown: FREE!**

### **What's Free:**
- ✅ **Vercel**: Free tier (100GB bandwidth/month)
- ✅ **Render**: Free tier (750 hours/month)
- ✅ **Domain**: Free subdomain or free domain
- ✅ **SSL**: Automatic HTTPS
- ✅ **CDN**: Global distribution
- ✅ **Total Cost**: $0/month

### **Limitations:**
- **Vercel**: 100GB bandwidth/month
- **Render**: 750 hours/month (sleeps after inactivity)
- **Free Domains**: Limited availability, renewal required

## 🚀 **Alternative Free Platforms**

### **Frontend Hosting:**
1. **Vercel** - Best for Next.js
2. **Netlify** - Great for static sites
3. **GitHub Pages** - Free for public repos
4. **Firebase Hosting** - Google's free hosting

### **Backend Hosting:**
1. **Render** - Easy deployment
2. **Railway** - Good free tier
3. **Heroku** - Classic choice
4. **Fly.io** - Generous free tier

## 📋 **Step-by-Step Free Domain Setup**

### **Using Freenom (Free .tk Domain):**

1. **Register Free Domain:**
   ```
   Go to freenom.com
   Search for: videoupscaler.tk
   Register for free (12 months)
   ```

2. **Configure DNS:**
   ```
   Type: CNAME
   Name: @
   Value: cname.vercel-dns.com
   
   Type: CNAME
   Name: api
   Value: your-app.onrender.com
   ```

3. **Update Vercel:**
   ```
   Vercel Dashboard → Settings → Domains
   Add: videoupscaler.tk
   ```

### **Using Vercel Subdomain:**
- Your app will be available at: `your-app.vercel.app`
- No additional setup required

## 🔒 **Security Features (Free Tier)**

### **Included:**
- ✅ **HTTPS/SSL** - Automatic certificates
- ✅ **CORS Protection** - Configured properly
- ✅ **Environment Variables** - Secure storage
- ✅ **Git Integration** - Automatic deployments

## 📊 **Performance (Free Tier)**

### **Vercel:**
- **Global CDN** - Fast loading worldwide
- **Automatic scaling** - Handles traffic spikes
- **Edge functions** - Serverless functions

### **Render:**
- **Auto-sleep** - Saves resources
- **Auto-wake** - Responds to requests
- **SSL certificates** - Automatic HTTPS

## 🛠️ **Management**

### **Updating Your App:**
```bash
# Make changes to your code
git add .
git commit -m "Update app"
git push origin main

# Vercel and Render will automatically redeploy
```

### **Environment Variables:**
- **Vercel**: Dashboard → Settings → Environment Variables
- **Render**: Dashboard → Environment → Environment Variables

## 🆘 **Troubleshooting**

### **Common Issues:**

#### 1. CORS Errors
- Check CORS_ORIGINS environment variable in Render
- Ensure frontend URL is included

#### 2. Build Failures
- Check build logs in Vercel/Render dashboard
- Verify all dependencies are in package.json/requirements.txt

#### 3. Domain Not Working
- Wait for DNS propagation (up to 48 hours)
- Check DNS records are correct

### **Support Resources:**
- **Vercel Docs**: https://vercel.com/docs
- **Render Docs**: https://render.com/docs
- **Freenom Help**: https://freenom.com/help.html

## 🎯 **Quick Start Commands**

```bash
# 1. Setup repository
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/online-video-enhancer.git
git push -u origin main

# 2. Deploy to Vercel
# Go to vercel.com and follow the prompts

# 3. Deploy to Render
# Go to render.com and follow the prompts

# 4. Get free domain
# Go to freenom.com and register a free .tk domain
```

## 🎉 **You're Ready!**

Your Online Video Enhancer will be available at:
- **Frontend**: `https://your-app.vercel.app` or `https://yourdomain.tk`
- **Backend**: `https://your-app.onrender.com` or `https://api.yourdomain.tk`

**Total Cost: $0/month!**

---

**Need help?** Check the troubleshooting section or create an issue in the GitHub repository. 