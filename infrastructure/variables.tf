variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = "default"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = ""
  # Get your Account ID: aws sts get-caller-identity --query Account --output text
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "trend-app"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.large"
}

variable "jenkins_ami" {
  description = "AMI ID for Jenkins EC2 (leave empty for latest Amazon Linux 2 or add it )"
  type        = string
  default     = ""
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "trend-app-eks-by-abhi"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.31"
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.large"]
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS nodes"
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 5
}

variable "jenkins_key_pair_name" {
  description = "EC2 key pair name for SSH access to Jenkins"
  type        = string
  default     = ""
  # Create a key pair first: aws ec2 create-key-pair --key-name trend-app-key --region us-east-1
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH to Jenkins"
  type        = list(string)
  default     = ["0.0.0.0/0"] # CHANGE THIS IN PRODUCTION
}

variable "allowed_jenkins_cidr" {
  description = "CIDR blocks allowed to access Jenkins web UI"
  type        = list(string)
  default     = ["0.0.0.0/0"] # CHANGE THIS IN PRODUCTION
}
