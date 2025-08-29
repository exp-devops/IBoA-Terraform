variable "project_name" {
  description = "Name of the project"
}
variable "network_cidr" {
  description = "CIDR block for the VPC"
}
variable "private_subnet_01_cidr" {
  description = "CIDR block for the first private subnet"
}
variable "private_subnet_02_cidr" {
  description = "CIDR block for the second private subnet"
}
variable "public_subnet_01_cidr" {
  description = "CIDR block for the first public subnet"
}
variable "public_subnet_02_cidr" {
  description = "CIDR block for the second public subnet"
}
variable "project_env" {
  description = "Environment of the project"
}
variable "project_segment" {
  description = "client name of the project"
}
variable "tags" {
  description = "Project Tags"
}
variable "aws_region" {
  description = "AWS region to deploy the resources"
}