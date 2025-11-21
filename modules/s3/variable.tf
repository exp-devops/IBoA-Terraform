/* Project name and environment.*/
variable "project_name" {
  type = string
}

variable "project_segment" {
  type        = string
  description = "client name of the project"
}

variable "project_env" {
  type        = string
  description = "Environment of the project"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
}

variable "aws_account_id" {
  type = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-2" # or your preferred region
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key to use for S3 bucket encryption"
}

locals {
  static_data_common_tags = var.tags
}




