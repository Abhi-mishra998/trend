variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. production, dev)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID (12 digits)"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "region" {
  description = "AWS region (e.g. ap-south-1)"
  type        = string
}
