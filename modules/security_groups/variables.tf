### Common Variables ###
variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "project_segment" {
  type        = string
  description = "Project segment"
}

variable "project_env" {
  type        = string
  description = "Project environment"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

### Network Variables ###
variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

### Security Group Variables ###
variable "bastion_ssh_allowed_ips" {
  type        = map(string)
  description = "Map of allowed IP addresses for SSH access"
}

variable "palms_rds_allowed_ips" {
  type        = map(string)
  description = "Map of allowed IP addresses for RDS access"
}

variable "rds_port" {
  type        = string
  description = "Port number for RDS access"
  default     = "5432"  # Default PostgreSQL port
}

variable "bastion_sg_id" {
  description = "Security group ID of the bastion host"
  type        = string
}

variable "fineract_rds_allowed_ips" {
  type        = map(string)
  description = "Map of allowed IP addresses for RDS access"
}

