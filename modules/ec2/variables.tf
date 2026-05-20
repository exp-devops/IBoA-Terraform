variable "tags" {
  description = "Project Tags"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "project_segment" {
  type        = string
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

variable "igw_id" {
  description = "Internet Gateway ID"
}

variable "kms_key" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

variable "private_subnet_01" {
  description = "Private subnet for the RabbitMQ server"
}

# variable "rabbitmqEC2" {
#   description = "Configuration for RabbitMQ EC2 instance"
# }

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "bastion_ssh_allowed_ips" {
  type        = map(string)
  description = "Map of allowed IP addresses for SSH access"
}

variable "eks_cluster_security_group_id" {
  description = "Default security group ID for the EKS cluster created by AWS"
  type        = string
}

variable "fineract_rds_sg_id" {
  description = "Security group ID for the Fineract RDS instance"
  type        = string
}

variable "palms_rds_sg_id" {
  description = "Security group ID for the PALMS RDS instance"
  type        = string
}
