#### Common Variables ####
variable "project_name" {
  description = "Specify Environment for default tagging"
  type        = string
}
variable "aws_region" {
  description = "The AWS region things are created in"
  type        = string
}
variable "project_env" {
  type        = string
  description = "Environment of the project"
}
variable "aws_cli_profile_name" {
  type        = string
  description = "AWS CLI profile name to use for authentication"
}
variable "project_segment" {
  type        = string
  description = "project_segment"
}

variable "bastionEC2" {
  type        = map(string)
  description = "Configuration for bastion EC2 instance"
}

variable "rabbitmqEC2" {
  type        = map(string)
  description = "Configuration for RabbitMQ EC2 instance"
}

variable "bastion_ssh_allowed_ips" {
  type        = map(string)
  description = "Map of allowed IP addresses for SSH access to the bastion host"
}
variable "tags" {
  type        = map(string)
  description = "tags"
}
variable "network_cidr" {
  description = "CIDR block for the VPC"
}

#### VPC Variables ####
variable "public_subnet_01_cidr" {
  type        = string
  description = "CIDR block for the first public subnet"
}

variable "public_subnet_02_cidr" {
  type        = string
  description = "CIDR block for the second public subnet"
}

variable "private_subnet_01_cidr" {
  type        = string
  description = "CIDR block for the first private subnet"
}

variable "private_subnet_02_cidr" {
  type        = string
  description = "CIDR block for the second private subnet"
}

/*### ACM ###
variable "domain_name" {
  description = "Primary domain for the certificate"
  type        = string
}
variable "subject_alternative_names" {
  description = "Additional domain names for the certificate"
  type        = list(string)
  default     = []
}
variable "cdn_aws_region" {
  description = "Additional region for CDN SSL"
  type        = string
}
## ALB ACM ##
variable "alb_domain_name" {
  description = "Primary domain for the certificate"
  type        = string
}



### Cloudfront ####
variable "DomainNames" {
  type        = map(string)
  description = "tags"
}

##### WAF #####
variable "waf_allowed_ips" {
  type        = list(string)
  description = "List of allowed IP addresses"
}*/


#### RDS Database #####
variable "rdsProperty" {
  type        = map(string)
  description = "PostgreSQL RDS properties"
}

variable "rdsProperty_mysql" {
  type        = map(string)
  description = "MySQL RDS properties"
}

variable "palms_rds_allowed_ips" {
  type        = map(string)
  description = "Map of allowed IP addresses for RDS access"
}

variable "fineract_rds_allowed_ips" {
  type        = map(string)
  description = "Map of allowed IP addresses for Fineract RDS access"
}

#### EKS Variables #####
variable "eksProperty" {
  type        = map(string)
  description = "EKS cluster and node group properties"
}

#### VPC Peering Variables for Jenkins Connectivity #####
variable "vpc_peering_connection_id" {
  type        = string
  description = "VPC Peering Connection ID created from Jenkins account (796973480744)"
  default     = ""
}

variable "jenkins_vpc_cidr" {
  type        = string
  description = "CIDR block of Jenkins VPC for cross-account peering"
  default     = "10.15.0.0/16"
}


/*###### SES #####
variable "ses_domain_name" {
  description = "The domain name to verify with SES"
  type        = string
}
variable "ses_subdomain" {
  description = "Subdomain from which emails are allowed to be sent"
}*/