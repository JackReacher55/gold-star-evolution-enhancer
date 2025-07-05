#!/bin/bash

# AWS Deployment Script for Online Video Enhancer
# This script automates the entire deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        print_status "Installation guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        exit 1
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        print_status "Installation guide: https://developer.hashicorp.com/terraform/downloads"
        exit 1
    fi
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "All prerequisites are met!"
}

# Generate SSH key pair
generate_ssh_key() {
    print_status "Generating SSH key pair..."
    
    if [ ! -f "aws-deployment/terraform/ssh_key" ]; then
        ssh-keygen -t rsa -b 4096 -f aws-deployment/terraform/ssh_key -N ""
        print_success "SSH key pair generated!"
    else
        print_warning "SSH key already exists, skipping generation."
    fi
}

# Build and deploy frontend
deploy_frontend() {
    print_status "Building frontend..."
    
    cd frontend
    
    # Install dependencies
    npm install
    
    # Build the application
    npm run build
    
    # Create .env.local with production API URL
    cat > .env.local << EOF
NEXT_PUBLIC_API_URL=https://api.${DOMAIN_NAME}
EOF
    
    cd ..
    
    print_success "Frontend built successfully!"
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd aws-deployment/terraform
    
    # Initialize Terraform
    terraform init
    
    # Plan the deployment
    print_status "Planning Terraform deployment..."
    terraform plan -var="domain_name=${DOMAIN_NAME}" -out=tfplan
    
    # Ask for confirmation
    echo
    print_warning "This will create AWS resources that may incur costs."
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Apply the plan
        print_status "Applying Terraform plan..."
        terraform apply tfplan
        
        # Get outputs
        FRONTEND_URL=$(terraform output -raw frontend_url)
        API_URL=$(terraform output -raw api_url)
        S3_FRONTEND_BUCKET=$(terraform output -raw s3_frontend_bucket)
        S3_VIDEOS_BUCKET=$(terraform output -raw s3_videos_bucket)
        CLOUDFRONT_DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
        EC2_PUBLIC_IP=$(terraform output -raw ec2_public_ip)
        NAMESERVERS=$(terraform output -raw nameservers)
        
        print_success "Infrastructure deployed successfully!"
        echo
        print_status "Deployment Summary:"
        echo "  Frontend URL: ${FRONTEND_URL}"
        echo "  API URL: ${API_URL}"
        echo "  S3 Frontend Bucket: ${S3_FRONTEND_BUCKET}"
        echo "  S3 Videos Bucket: ${S3_VIDEOS_BUCKET}"
        echo "  CloudFront Distribution ID: ${CLOUDFRONT_DISTRIBUTION_ID}"
        echo "  EC2 Public IP: ${EC2_PUBLIC_IP}"
        echo "  Nameservers: ${NAMESERVERS}"
        echo
        
        # Save outputs to file
        cat > ../../deployment-outputs.txt << EOF
Frontend URL: ${FRONTEND_URL}
API URL: ${API_URL}
S3 Frontend Bucket: ${S3_FRONTEND_BUCKET}
S3 Videos Bucket: ${S3_VIDEOS_BUCKET}
CloudFront Distribution ID: ${CLOUDFRONT_DISTRIBUTION_ID}
EC2 Public IP: ${EC2_PUBLIC_IP}
Nameservers: ${NAMESERVERS}
EOF
        
        print_status "Deployment outputs saved to deployment-outputs.txt"
        
    else
        print_warning "Deployment cancelled."
        exit 0
    fi
    
    cd ../..
}

# Upload frontend to S3
upload_frontend() {
    print_status "Uploading frontend to S3..."
    
    # Get S3 bucket name from Terraform output
    S3_FRONTEND_BUCKET=$(cd aws-deployment/terraform && terraform output -raw s3_frontend_bucket)
    
    # Sync frontend build to S3
    aws s3 sync frontend/out/ s3://${S3_FRONTEND_BUCKET}/ --delete
    
    # Invalidate CloudFront cache
    CLOUDFRONT_DISTRIBUTION_ID=$(cd aws-deployment/terraform && terraform output -raw cloudfront_distribution_id)
    aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} --paths "/*"
    
    print_success "Frontend uploaded to S3 and CloudFront cache invalidated!"
}

# Configure domain DNS
configure_dns() {
    print_status "Configuring domain DNS..."
    
    # Get nameservers from Terraform output
    NAMESERVERS=$(cd aws-deployment/terraform && terraform output -raw nameservers)
    
    echo
    print_warning "Please configure your domain's nameservers at your domain registrar:"
    echo "Domain: ${DOMAIN_NAME}"
    echo "Nameservers:"
    for ns in $NAMESERVERS; do
        echo "  - $ns"
    done
    echo
    print_status "DNS propagation can take up to 48 hours."
    echo
}

# Wait for backend to be ready
wait_for_backend() {
    print_status "Waiting for backend to be ready..."
    
    API_URL=$(cd aws-deployment/terraform && terraform output -raw api_url)
    
    # Wait up to 10 minutes for backend to be ready
    for i in {1..60}; do
        if curl -s -f "${API_URL}/health" > /dev/null; then
            print_success "Backend is ready!"
            return 0
        fi
        
        print_status "Waiting for backend... (attempt $i/60)"
        sleep 10
    done
    
    print_error "Backend did not become ready within 10 minutes."
    print_status "You can check the EC2 instance logs manually."
    return 1
}

# Main deployment function
main() {
    echo "🚀 AWS Deployment Script for Online Video Enhancer"
    echo "=================================================="
    echo
    
    # Check if domain name is provided
    if [ -z "$DOMAIN_NAME" ]; then
        print_error "Please provide a domain name."
        echo "Usage: DOMAIN_NAME=yourdomain.com ./deploy.sh"
        exit 1
    fi
    
    print_status "Deploying to domain: ${DOMAIN_NAME}"
    echo
    
    # Run deployment steps
    check_prerequisites
    generate_ssh_key
    deploy_frontend
    deploy_infrastructure
    upload_frontend
    configure_dns
    
    echo
    print_status "Waiting for backend to be ready..."
    if wait_for_backend; then
        echo
        print_success "🎉 Deployment completed successfully!"
        echo
        print_status "Your application is now available at:"
        echo "  Frontend: https://${DOMAIN_NAME}"
        echo "  API: https://api.${DOMAIN_NAME}"
        echo
        print_status "Next steps:"
        echo "  1. Wait for DNS propagation (up to 48 hours)"
        echo "  2. Test your application"
        echo "  3. Set up monitoring and alerts"
        echo "  4. Configure backups"
        echo
    else
        print_warning "Deployment completed but backend is not ready yet."
        print_status "Please check the EC2 instance and try again later."
    fi
}

# Run main function
main "$@" 