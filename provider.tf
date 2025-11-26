# provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Specify the provider and access details
provider "aws" {
  shared_credentials_files = ["C:\\Users\\bhaskar.nandagopal\\.aws\\credentials"]
  profile                  = var.aws_cli_profile_name
  region                   = var.aws_region
  default_tags {
    tags = {
      Environment = var.project_env
      ManagedBy   = "Terraform"
    }
  }
}