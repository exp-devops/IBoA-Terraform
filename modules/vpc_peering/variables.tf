variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "project_segment" {
  description = "Client name of the project"
  type        = string
}

variable "project_env" {
  description = "Environment of the project"
  type        = string
}

variable "tags" {
  description = "Project Tags"
  type        = map(string)
}

variable "vpc_peering_connection_id" {
  description = "VPC Peering Connection ID created from Jenkins account"
  type        = string
}

variable "jenkins_vpc_cidr" {
  description = "CIDR block of Jenkins VPC"
  type        = string
  default     = "10.15.0.0/16"
}

variable "public_route_table_id" {
  description = "Public route table ID"
  type        = string
}

variable "private_route_table_id" {
  description = "Private route table ID"
  type        = string
}
