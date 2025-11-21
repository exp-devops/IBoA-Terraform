variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "project_env" {
  type        = string
  description = "Environment of the project"
}

variable "project_segment" {
  type        = string
  description = "Segment of the project"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the ALB and related resources"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "public_subnet_01" {
  type        = string
  description = "ID of the first public subnet"
}

variable "public_subnet_02" {
  type        = string
  description = "ID of the second public subnet"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key to use for S3 bucket encryption"
}
