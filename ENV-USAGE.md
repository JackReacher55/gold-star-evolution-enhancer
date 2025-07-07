# Environment Variable Automation - Quick Usage Guide

## 🚀 Quick Start

### 1. Initial Setup
```powershell
# Set up environment for development
.\setup-env.ps1 -Environment development

# Set up for production
.\setup-env.ps1 -Environment production
```

### 2. Validate Configuration
```powershell
# Check all environment files
.\env-validator.ps1 -Environment all

# Auto-fix issues
.\env-validator.ps1 -Environment all -Fix
```

### 3. Deploy to Platforms
```powershell
# Deploy to both Render and Vercel
.\deploy-env.ps1 -Target both -Environment production

# Preview deployment (dry run)
.\deploy-env.ps1 -Target both -Environment production -DryRun
```

## 🔧 Integrated Deployment

### Full Deployment with Environment Setup
```powershell
# Complete deployment with environment setup
.\deploy.ps1 -SetupEnv -Environment production

# Deploy with custom commit message
.\deploy.ps1 -SetupEnv -Environment production -CommitMessage "Add new features"
```

### Environment-Only Operations
```powershell
# Setup environment only
.\deploy.ps1 -SetupEnv -Environment development -SkipGitHub -SkipVercel -SkipRender

# Deploy environment variables only
.\deploy.ps1 -Environment production -SkipGitHub -SkipVercel -SkipRender
```

## 📋 Common Commands

### Development Workflow
```powershell
# 1. Setup development environment
.\setup-env.ps1 -Environment development

# 2. Validate configuration
.\env-validator.ps1 -Environment all -Fix

# 3. Start development servers
cd backend && python -m uvicorn app:app --reload
cd frontend && npm run dev
```

### Production Deployment
```powershell
# 1. Setup production environment
.\setup-env.ps1 -Environment production

# 2. Validate and fix
.\env-validator.ps1 -Environment all -Fix

# 3. Deploy environment variables
.\deploy-env.ps1 -Target both -Environment production

# 4. Full deployment
.\deploy.ps1 -Environment production
```

## 🔍 Troubleshooting

### Missing Environment Files
```powershell
# Regenerate all environment files
.\setup-env.ps1 -Environment development -Force
```

### Validation Errors
```powershell
# Auto-fix validation issues
.\env-validator.ps1 -Environment all -Fix -Verbose
```

### Platform Authentication
```powershell
# Login to platforms
render login
vercel login
```

## 📁 Generated Files

After running setup, you'll have:
- `backend\.env` - Backend configuration
- `frontend\.env.local` - Frontend configuration  
- `.env` - Root project configuration

## ⚙️ Configuration

### Environment Types
- **development**: Local development settings
- **staging**: Pre-production testing
- **production**: Live production environment

### Custom URLs
```powershell
# Set custom backend and frontend URLs
.\setup-env.ps1 -Environment production -BackendUrl "https://api.example.com" -FrontendUrl "https://app.example.com"
```

## 🎯 Next Steps

1. **Review**: Check generated environment files
2. **Customize**: Update specific values as needed
3. **Test**: Validate configuration locally
4. **Deploy**: Push to production platforms

For detailed documentation, see `README-ENV.md` 