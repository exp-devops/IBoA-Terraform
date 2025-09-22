variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "project_segment" {
  type        = string
  description = "Segment of the project"
}

variable "project_env" {
  type        = string
  description = "Environment of the project"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for encrypting the secrets"
}

variable "rdsProperty" {
  type        = map(string)
  description = "PostgreSQL RDS properties"
}

variable "rdsProperty_mysql" {
  type        = map(string)
  description = "MySQL RDS properties"
}

variable "palms_rds_username" {
  type        = string
  description = "PostgreSQL RDS username"
}

variable "palms_rds_password" {
  type        = string
  description = "PostgreSQL RDS password"
  sensitive   = true
}

variable "fineract_rds_username" {
  type        = string
  description = "MySQL RDS username"
}

variable "fineract_rds_password" {
  type        = string
  description = "MySQL RDS password"
  sensitive   = true
}
