variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "video-enhancer"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for backend"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Ubuntu 22.04 LTS in us-east-1
} 