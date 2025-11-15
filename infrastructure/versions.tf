terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "{{TERRAFORM_STATE_BUCKET}}"
  #   key            = "trend-app/terraform.tfstate"
  #   region         = "{{AWS_REGION}}"
  #   dynamodb_table = "{{TERRAFORM_STATE_DDB}}"
  #   encrypt        = true
  # }
}
