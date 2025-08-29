variable "tags" {
  description = "Project Tags"
}

variable "project_name" {
    type = string
  description = "Project name"
}

variable "project_segment" {
  type = string
  description = "client name of the project"
}

variable "project_env" {
  type = string
}

variable "bastionEC2" {
  description = "Configuration for bastion EC2 instance"
}

variable "public_subnet_01" {
  description = "Public subnet for the bastion host"
}

variable "bastion_sg_id" {
  description = "Security group ID for the bastion host"
}

variable "igw_id" {
  description = "Internet Gateway ID"
}

variable "kms_key" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

# variable "network_cidr" {
#   description = "CIDR block for the VPC"
# }
