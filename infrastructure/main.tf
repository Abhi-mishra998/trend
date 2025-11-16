# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  allowed_jenkins_cidr = var.allowed_jenkins_cidr
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name     = var.project_name
  environment      = var.environment
  aws_account_id   = var.aws_account_id
  eks_cluster_name = var.eks_cluster_name
  region           = var.aws_region
}

# Jenkins EC2 Module
module "jenkins" {
  source = "./modules/jenkins"

  project_name         = var.project_name
  environment          = var.environment
  instance_type        = var.jenkins_instance_type
  ami_id               = var.jenkins_ami
  subnet_id            = module.vpc.public_subnet_ids[0]
  security_group_ids   = [module.security_groups.jenkins_sg_id]
  iam_instance_profile = module.iam.jenkins_instance_profile_name
  key_name             = var.jenkins_key_pair_name # Create EC2 key pair first
  cluster_name         = var.eks_cluster_name
  aws_region           = var.aws_region
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name        = var.project_name
  environment         = var.environment
  cluster_name        = var.eks_cluster_name
  cluster_version     = var.eks_cluster_version
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_role_arn       = module.iam.eks_node_role_arn
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired_size
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size
  cluster_sg_id       = module.security_groups.eks_cluster_sg_id
  node_sg_id          = module.security_groups.eks_node_sg_id
}
