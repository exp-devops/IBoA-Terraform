variable "vpc_id" {
  description = "vpc id"
}
variable "private_subnet_01" {
  description = "Private subnet"
}
variable "private_subnet_02" {
  description = "Private subnet"
}
variable "tags" {
  description = "Project Tags"
}
variable "kms_key" {
  description = "KMS key "
}
variable "aws_region" {
  description = "aws region"
}
variable "rdsProperty" {
   type = map(string)
  description = "Map of RDS properties including PORT and other configurations"
}
variable "rdsProperty_mysql" {
   type = map(string)
  description = "Map of MySQL RDS properties including PORT and other configurations"
}
variable "project_name" {
  type        = string
  description = "project_name"
}
variable "project_env" {
  type        = string
  description = "project_env"
}
variable "project_segment" {
  description = "client name of the project"
}
variable "network_cidr" {
  description = "CIDR block for the VPC"
}

# #### Lambda Variables ####
# variable "run_lambda_init" {
#   type    = bool
#   default = false
# }
 variable "palms_rds_sg_id" {
   description = "Security group for the PostgreSQL RDS instance"
   type        = string
}

variable "fineract_rds_sg_id" {
   description = "Security group for the MySQL RDS instance"
   type        = string
}

