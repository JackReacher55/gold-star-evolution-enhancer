# 🚀 Deployment Guide - Online Video Enhancer

This guide will help you deploy your Online Video Enhancer to the internet with a custom domain name.

## 📋 Prerequisites

- GitHub account
- Domain name (optional but recommended)
- Credit card (for some services, though free tiers are available)

## 🌐 Quick Deployment (Free)

### Step 1: Prepare Your Repository

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/online-video-enhancer.git
   git push -u origin main
   ```

### Step 2: Deploy Frontend (Vercel)

1. **Go to [vercel.com](https://vercel.com)**
2. **Sign up with GitHub**
3. **Click "New Project"**
4. **Import your repository**
5. **Configure settings:**
   - Framework Preset: Next.js
   - Root Directory: `frontend`
   - Build Command: `npm run build`
   - Output Directory: `.next`
6. **Add Environment Variable:**
   - Name: `NEXT_PUBLIC_API_URL`
   - Value: `https://your-backend-url.onrender.com` (we'll get this in step 3)
7. **Click "Deploy"**

### Step 3: Deploy Backend (Render)

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
6. **Add Environment Variables:**
   ```
   CORS_ORIGINS=https://your-frontend-url.vercel.app
   ```
7. **Click "Create Web Service"**

### Step 4: Update Frontend API URL

1. **Go back to Vercel dashboard**
2. **Select your project**
3. **Go to Settings → Environment Variables**
4. **Update `NEXT_PUBLIC_API_URL`** with your Render backend URL
5. **Redeploy the project**

## 🏷️ Custom Domain Setup

### Option 1: Domain with Vercel (Recommended)

1. **Buy a domain** from any provider (Namecheap, GoDaddy, etc.)
2. **In Vercel dashboard:**
   - Go to your project → Settings → Domains
   - Add your domain (e.g., `videoupscaler.com`)
   - Vercel will show DNS records to configure

3. **Configure DNS at your domain provider:**
   ```
   Type: A
   Name: @
   Value: 76.76.19.53
   
   Type: CNAME
   Name: www
   Value: cname.vercel-dns.com
   ```

4. **Wait for DNS propagation** (can take up to 48 hours)

### Option 2: Subdomain Setup

1. **For backend API:**
   - In Render dashboard → your service → Settings → Custom Domains
   - Add subdomain: `api.yourdomain.com`
   - Update DNS records at your domain provider

2. **Update environment variables:**
   - Frontend: `NEXT_PUBLIC_API_URL=https://api.yourdomain.com`
   - Backend: `CORS_ORIGINS=https://yourdomain.com`

## 🔧 Advanced Configuration

### Environment Variables

**Frontend (.env.local):**
```env
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
NEXT_PUBLIC_SITE_URL=https://yourdomain.com
```

**Backend (Render Environment Variables):**
```env
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
MAX_FILE_SIZE=104857600
LOG_LEVEL=INFO
```

### SSL/HTTPS

- **Vercel**: Automatic SSL certificates
- **Render**: Automatic SSL certificates
- **Custom domains**: SSL is handled automatically

## 📊 Monitoring & Analytics

### Add Google Analytics

1. **Create Google Analytics account**
2. **Get tracking ID**
3. **Add to frontend:**

```javascript
// In pages/_document.js
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_TRACKING_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_TRACKING_ID');
</script>
```

### Add Error Monitoring

1. **Sentry** (free tier available)
2. **LogRocket** (free tier available)

## 🚀 Performance Optimization

### Frontend Optimization

1. **Enable Vercel Analytics**
2. **Optimize images** with Next.js Image component
3. **Enable compression** in Vercel settings

### Backend Optimization

1. **Add caching headers**
2. **Implement rate limiting**
3. **Use CDN for video files**

## 🔒 Security Checklist

- [ ] HTTPS enabled
- [ ] CORS properly configured
- [ ] File upload validation
- [ ] Rate limiting implemented
- [ ] Environment variables secured
- [ ] Regular security updates

## 📈 Scaling Considerations

### For High Traffic

1. **Upgrade Render plan** (paid tiers)
2. **Use CDN** for video storage
3. **Implement caching**
4. **Add load balancing**

### Video Storage

For production, consider:
- **AWS S3** for video storage
- **CloudFlare** for CDN
- **Backblaze B2** (cheaper alternative)

## 🆘 Troubleshooting

### Common Issues

1. **CORS Errors**
   - Check CORS_ORIGINS environment variable
   - Ensure frontend URL is included

2. **File Upload Fails**
   - Check file size limits
   - Verify FFmpeg is available on Render

3. **Domain Not Working**
   - Wait for DNS propagation
   - Check DNS records are correct

### Support Resources

- **Vercel Docs**: https://vercel.com/docs
- **Render Docs**: https://render.com/docs
- **FFmpeg**: https://ffmpeg.org/documentation.html

## 💰 Cost Estimation

### Free Tier (Recommended for Starters)
- **Vercel**: Free (100GB bandwidth/month)
- **Render**: Free (750 hours/month)
- **Domain**: ~$10-15/year

### Paid Tier (For Production)
- **Vercel Pro**: $20/month
- **Render**: $7/month
- **Domain**: ~$10-15/year
- **Total**: ~$37-42/month

## 🎯 Next Steps

1. **Deploy using the steps above**
2. **Test all functionality**
3. **Set up monitoring**
4. **Add analytics**
5. **Optimize performance**
6. **Plan for scaling**

---

**Need help?** Check the troubleshooting section or create an issue in the GitHub repository. 