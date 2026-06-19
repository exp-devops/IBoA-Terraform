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

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the security group will be created"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the security group"
}
