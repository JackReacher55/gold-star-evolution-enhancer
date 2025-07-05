# 🚀 AWS Professional Deployment Guide

This guide will help you deploy your Online Video Enhancer to AWS with a professional setup including custom domain, SSL certificates, CDN, and scalable infrastructure.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudFront    │    │   Route 53      │    │   ACM (SSL)     │
│   (CDN)         │    │   (DNS)         │    │   (Certificates)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   S3 Bucket     │    │   EC2 Instance  │    │   S3 Bucket     │
│   (Frontend)    │    │   (Backend)     │    │   (Videos)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Components:
- **Frontend**: S3 + CloudFront (CDN)
- **Backend**: EC2 with Nginx + SSL
- **Storage**: S3 for video files
- **DNS**: Route 53
- **SSL**: ACM certificates
- **Infrastructure**: Terraform

## 📋 Prerequisites

### Required Tools:
1. **AWS CLI** - [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. **Terraform** - [Install Guide](https://developer.hashicorp.com/terraform/downloads)
3. **Domain Name** - Purchase from any registrar (Namecheap, GoDaddy, etc.)

### AWS Account Setup:
1. **Create AWS Account** - [Sign up here](https://aws.amazon.com/)
2. **Create IAM User** with programmatic access
3. **Configure AWS CLI**:
   ```bash
   aws configure
   # Enter your Access Key ID, Secret Access Key, and region
   ```

## 🚀 Quick Deployment

### Step 1: Prepare Your Domain
1. **Purchase a domain** (e.g., `videoupscaler.com`)
2. **Note the domain name** - you'll need it for deployment

### Step 2: Run the Deployment Script
```bash
# Make the script executable
chmod +x aws-deployment/deploy.sh

# Run deployment with your domain
DOMAIN_NAME=yourdomain.com ./aws-deployment/deploy.sh
```

### Step 3: Configure DNS
After deployment, the script will show you the nameservers to configure at your domain registrar.

## 🔧 Manual Deployment Steps

If you prefer to deploy manually or need to customize the setup:

### Step 1: Generate SSH Key
```bash
cd aws-deployment/terraform
ssh-keygen -t rsa -b 4096 -f ssh_key -N ""
```

### Step 2: Configure Terraform Variables
Create `terraform.tfvars`:
```hcl
domain_name = "yourdomain.com"
aws_region  = "us-east-1"
instance_type = "t3.medium"
```

### Step 3: Deploy Infrastructure
```bash
cd aws-deployment/terraform
terraform init
terraform plan
terraform apply
```

### Step 4: Build and Deploy Frontend
```bash
cd frontend
npm install
npm run build

# Upload to S3
aws s3 sync out/ s3://your-frontend-bucket --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
```

## 💰 Cost Estimation

### Monthly Costs (us-east-1):
- **EC2 t3.medium**: ~$30/month
- **S3 Storage**: ~$0.023/GB/month
- **CloudFront**: ~$0.085/GB (first 10TB)
- **Route 53**: ~$0.50/month per hosted zone
- **Data Transfer**: ~$0.09/GB (outbound)

### Estimated Total:
- **Low traffic** (< 100GB/month): ~$35-40/month
- **Medium traffic** (1TB/month): ~$50-60/month
- **High traffic** (10TB/month): ~$150-200/month

## 🔒 Security Features

### Built-in Security:
- ✅ **HTTPS/SSL** - Automatic SSL certificates
- ✅ **Security Groups** - Firewall rules
- ✅ **IAM Roles** - Least privilege access
- ✅ **VPC** - Network isolation
- ✅ **S3 Bucket Policies** - Access control

### Additional Security (Recommended):
- **WAF** - Web Application Firewall
- **CloudTrail** - API logging
- **GuardDuty** - Threat detection
- **Backup Strategy** - Automated backups

## 📊 Monitoring & Scaling

### Monitoring Setup:
1. **CloudWatch** - Metrics and logs
2. **CloudWatch Alarms** - Automated alerts
3. **S3 Analytics** - Storage optimization

### Scaling Options:
- **Auto Scaling Group** - Automatic EC2 scaling
- **Load Balancer** - Distribute traffic
- **RDS** - Database for user management
- **ElastiCache** - Redis for caching

## 🛠️ Maintenance

### Regular Tasks:
1. **Security Updates** - Keep EC2 instance updated
2. **Backup Verification** - Test restore procedures
3. **Cost Optimization** - Review and optimize resources
4. **Performance Monitoring** - Monitor application performance

### Useful Commands:
```bash
# SSH to backend
ssh -i aws-deployment/terraform/ssh_key ubuntu@YOUR_EC2_IP

# Check backend logs
sudo journalctl -u video-enhancer -f

# Update backend
cd /opt/video-enhancer/backend
git pull
sudo systemctl restart video-enhancer

# Check nginx status
sudo systemctl status nginx
```

## 🆘 Troubleshooting

### Common Issues:

#### 1. Backend Not Responding
```bash
# SSH to EC2 and check logs
ssh -i aws-deployment/terraform/ssh_key ubuntu@YOUR_EC2_IP
sudo journalctl -u video-enhancer -f
```

#### 2. SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew manually if needed
sudo certbot renew
```

#### 3. S3 Upload Failures
- Check IAM permissions
- Verify bucket policies
- Check CORS configuration

#### 4. CloudFront Not Updating
```bash
# Invalidate cache
aws cloudfront create-invalidation --distribution-id YOUR_ID --paths "/*"
```

### Support Resources:
- **AWS Documentation**: https://docs.aws.amazon.com/
- **Terraform Docs**: https://www.terraform.io/docs
- **FFmpeg Documentation**: https://ffmpeg.org/documentation.html

## 🔄 Updates and Upgrades

### Updating the Application:
1. **Pull latest code**
2. **Rebuild frontend**
3. **Upload to S3**
4. **Invalidate CloudFront cache**
5. **Update backend** (if needed)

### Infrastructure Updates:
```bash
cd aws-deployment/terraform
terraform plan
terraform apply
```

## 🗑️ Cleanup

To remove all AWS resources:
```bash
cd aws-deployment/terraform
terraform destroy
```

**⚠️ Warning**: This will delete all resources and data!

## 📈 Performance Optimization

### Frontend Optimization:
- **CloudFront Caching** - Configure cache behaviors
- **Image Optimization** - Use Next.js Image component
- **Code Splitting** - Implement lazy loading

### Backend Optimization:
- **Database Caching** - Add Redis
- **CDN for Videos** - Use CloudFront for video delivery
- **Load Balancing** - Add Application Load Balancer

## 🎯 Next Steps

After successful deployment:

1. **Set up monitoring** with CloudWatch
2. **Configure backups** for S3 and EC2
3. **Implement CI/CD** with GitHub Actions
4. **Add user authentication** if needed
5. **Set up analytics** (Google Analytics, etc.)
6. **Create disaster recovery plan**

---

**Need help?** Check the troubleshooting section or create an issue in the GitHub repository. 