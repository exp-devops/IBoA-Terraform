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
  description = "Tags for the EKS cluster and related resources"
}

variable "private_subnet_01" {
  type        = string
  description = "ID of the first private subnet"
}

variable "private_subnet_02" {
  type        = string
  description = "ID of the second private subnet"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "eksProperty" {
  type        = map(string)
  description = "EKS cluster and node group properties"
}

/*variable "eks_cluster_sg_id" {
  type        = string
  description = "Security group ID for the EKS cluster"
}

variable "eks_additional_sg_id" {
  type        = string
  description = "Security group ID for the additional EKS resources"
}*/

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key to use for EKS encryption"
}

variable "eks_cluster_security_group_id" {
  type        = string
  description = "Security group ID for the EKS cluster"
}

variable "bastion_sg_id" {
  type        = string
  description = "Security group ID for the bastion host to allow access to EKS cluster"
}

