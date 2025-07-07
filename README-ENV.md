# Environment Variable Automation Guide

This guide covers the automated environment variable setup and management system for the Online Video Enhancer project.

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Environment Files](#environment-files)
- [Automation Scripts](#automation-scripts)
- [Configuration Management](#configuration-management)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

The environment variable automation system provides:

- **Automated Setup**: One-command environment configuration
- **Validation**: Ensures all required variables are properly set
- **Deployment**: Automated deployment to Render and Vercel
- **Security**: Secure handling of sensitive configuration
- **Flexibility**: Support for multiple environments

## 🚀 Quick Start

### 1. Initial Setup

```powershell
# Set up environment variables for development
.\setup-env.ps1 -Environment development

# Set up for production with custom URLs
.\setup-env.ps1 -Environment production -BackendUrl "https://your-backend.onrender.com" -FrontendUrl "https://your-frontend.vercel.app"
```

### 2. Validate Configuration

```powershell
# Validate all environment files
.\env-validator.ps1 -Environment all

# Validate and auto-fix issues
.\env-validator.ps1 -Environment all -Fix
```

### 3. Deploy to Platforms

```powershell
# Deploy to both Render and Vercel
.\deploy-env.ps1 -Target both -Environment production

# Deploy only backend to Render
.\deploy-env.ps1 -Target backend -Environment production

# Dry run to see what would be deployed
.\deploy-env.ps1 -Target both -Environment production -DryRun
```

## 📁 Environment Files

### File Structure

```
project/
├── .env                    # Root environment variables
├── backend/
│   └── .env               # Backend-specific variables
├── frontend/
│   └── .env.local         # Frontend-specific variables
└── env.template           # Template with all available variables
```

### Environment File Types

#### Root (.env)
Contains project-wide configuration:
- Environment type (development/production)
- Backend and frontend URLs
- Deployment settings

#### Backend (.env)
Contains FastAPI server configuration:
- Server settings (PORT, HOST, DEBUG)
- CORS configuration
- File upload limits
- Video processing paths
- Security settings

#### Frontend (.env.local)
Contains Next.js configuration:
- API endpoint URLs
- Public app settings
- Development server settings

## 🔧 Automation Scripts

### setup-env.ps1

**Purpose**: Automated environment variable setup

**Parameters**:
- `-Environment`: Target environment (development/staging/production)
- `-BackendUrl`: Custom backend URL
- `-FrontendUrl`: Custom frontend URL
- `-Force`: Overwrite existing files
- `-Interactive`: Interactive mode for user input

**Examples**:
```powershell
# Development setup
.\setup-env.ps1 -Environment development

# Production setup with custom URLs
.\setup-env.ps1 -Environment production -BackendUrl "https://api.example.com" -FrontendUrl "https://app.example.com"

# Interactive setup
.\setup-env.ps1 -Environment development -Interactive
```

### env-validator.ps1

**Purpose**: Validate environment variable configuration

**Parameters**:
- `-Environment`: Environment to validate (development/staging/production/all)
- `-Fix`: Automatically fix validation issues
- `-Verbose`: Detailed output

**Examples**:
```powershell
# Validate all environments
.\env-validator.ps1 -Environment all

# Validate and fix issues
.\env-validator.ps1 -Environment production -Fix

# Verbose validation
.\env-validator.ps1 -Environment all -Verbose
```

### deploy-env.ps1

**Purpose**: Deploy environment variables to cloud platforms

**Parameters**:
- `-Target`: Deployment target (backend/frontend/both)
- `-Environment`: Target environment
- `-DryRun`: Preview changes without applying
- `-Force`: Force deployment
- `-Verbose`: Detailed output

**Examples**:
```powershell
# Deploy to both platforms
.\deploy-env.ps1 -Target both -Environment production

# Preview deployment
.\deploy-env.ps1 -Target backend -Environment production -DryRun

# Deploy only frontend
.\deploy-env.ps1 -Target frontend -Environment production
```

## ⚙️ Configuration Management

### Backend Configuration (config.py)

The backend uses a centralized configuration system:

```python
from backend.config import config

# Access configuration values
port = config.PORT
debug = config.DEBUG
max_file_size = config.MAX_FILE_SIZE

# Get CORS configuration
cors_config = config.get_cors_config()

# Validate file uploads
if config.validate_file_size(file_size):
    # Process file
    pass
```

### Environment-Specific Configurations

#### Development
- Debug mode enabled
- Local URLs (localhost)
- Verbose logging
- Hot reload enabled

#### Staging
- Debug mode disabled
- Staging URLs
- Info-level logging
- Production-like settings

#### Production
- Debug mode disabled
- Production URLs
- Warning-level logging
- Security optimizations

## 🚀 Deployment

### Render (Backend)

1. **Prerequisites**:
   - Render CLI installed
   - Authenticated with Render

2. **Deployment**:
   ```powershell
   .\deploy-env.ps1 -Target backend -Environment production
   ```

3. **Required Variables**:
   - `PORT`: Server port
   - `HOST`: Server host
   - `DEBUG`: Debug mode
   - `CORS_ORIGINS`: Allowed origins
   - `MAX_FILE_SIZE`: Upload limit
   - `FFMPEG_PATH`: FFmpeg binary path
   - `REALESRGAN_PATH`: Real-ESRGAN binary path

### Vercel (Frontend)

1. **Prerequisites**:
   - Vercel CLI installed
   - Authenticated with Vercel

2. **Deployment**:
   ```powershell
   .\deploy-env.ps1 -Target frontend -Environment production
   ```

3. **Required Variables**:
   - `NEXT_PUBLIC_API_URL`: Backend API URL
   - `NEXT_PUBLIC_APP_NAME`: Application name
   - `NEXT_PUBLIC_APP_VERSION`: Application version

## 🔍 Troubleshooting

### Common Issues

#### 1. Missing Environment Files
**Error**: "Environment file not found"
**Solution**: Run setup script
```powershell
.\setup-env.ps1 -Environment development
```

#### 2. Invalid Configuration Values
**Error**: "Configuration validation failed"
**Solution**: Run validator with auto-fix
```powershell
.\env-validator.ps1 -Environment all -Fix
```

#### 3. Platform Authentication Issues
**Error**: "Not logged in to [Platform]"
**Solution**: Authenticate with platform
```powershell
# For Render
render login

# For Vercel
vercel login
```

#### 4. Missing Required Variables
**Error**: "Missing required variables"
**Solution**: Check template and update environment files
```powershell
# View template
Get-Content env.template

# Regenerate environment files
.\setup-env.ps1 -Environment development -Force
```

### Validation Errors

#### Port Configuration
- **Issue**: Invalid port number
- **Solution**: Use port between 1-65535

#### File Size Limits
- **Issue**: Invalid file size format
- **Solution**: Use format like "100MB", "1GB"

#### URL Validation
- **Issue**: Invalid API URL
- **Solution**: Use valid HTTP/HTTPS URLs

#### Path Validation
- **Issue**: Missing binary paths
- **Solution**: Ensure FFmpeg and Real-ESRGAN are installed

### Debug Mode

Enable verbose output for troubleshooting:

```powershell
# Verbose setup
.\setup-env.ps1 -Environment development -Verbose

# Verbose validation
.\env-validator.ps1 -Environment all -Verbose

# Verbose deployment
.\deploy-env.ps1 -Target both -Environment production -Verbose
```

## 🔐 Security Considerations

### Sensitive Data
- Never commit `.env` files to version control
- Use secure random generation for secrets
- Rotate API keys regularly

### Environment Isolation
- Use different configurations per environment
- Validate production settings before deployment
- Test configuration changes in staging first

### Access Control
- Limit access to production environment files
- Use platform-specific secrets management
- Monitor environment variable changes

## 📚 Best Practices

### 1. Environment Management
- Use consistent naming conventions
- Document all configuration options
- Version control templates, not actual files

### 2. Validation
- Always validate before deployment
- Use automated validation in CI/CD
- Test configuration in staging environment

### 3. Deployment
- Use dry runs before production deployment
- Deploy during maintenance windows
- Monitor application after deployment

### 4. Maintenance
- Regularly review and update configurations
- Clean up unused environment variables
- Update documentation when adding new variables

## 🤝 Contributing

When adding new environment variables:

1. **Update Template**: Add to `env.template`
2. **Update Scripts**: Modify validation and deployment scripts
3. **Update Documentation**: Document new variables
4. **Test**: Validate in all environments
5. **Deploy**: Update production configurations

## 📞 Support

For issues with environment variable automation:

1. Check this documentation
2. Run validation scripts
3. Review error messages
4. Check platform-specific documentation
5. Create an issue with detailed error information 