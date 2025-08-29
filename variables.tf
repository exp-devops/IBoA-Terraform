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
  type = map(string)
  description = "Configuration for bastion EC2 instance"
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

/*##### Auto scaling ###
# variable "web_server_ami" {
#   description = "webServer AMI ID"
# }
# variable "web_server_instance_type" {
#   description = "Websserver instance type"
# }

##### Security Group #####

variable "bastion_ssh_allowed_ips" {
  description = "List of allowed IPs for SSH access to the bastion host"
  type        = map(string)
}
variable "bastionEC2" {
  description = "Configuration for bastion EC2 instance"
  type        = map(string)
}

##### ALB #####
variable "alb_app_port" {
  description = "Port exposed by the ALB image to redirect traffic to docker"
}
variable "az_count" {
  description = "Number of AZs to cover in a given region"
}
variable "health_check_path" {
  description = "Health Check path for application"
}

#***# Background Service Variables #***# 

variable "bg_service_port" {
  description = "Port exposed by the background service"
}
variable "bg_health_check_path" {
  description = "Health Check path for background service"
}

### ECS Fargate Variables ###

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
}
variable "app_image" {
  description = "Docker image to run in the ECS cluster"
}
variable "container_app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
}
variable "docker_app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
}
variable "app_count" {
  description = "Number of docker containers to run"
}
variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}
variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
}


#### Background Fargate Variables ####
variable "background_container_port" {
  description = "Port exposed by the background docker image to redirect traffic to"
}
variable "background_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}
variable "background_fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
}
variable "background_docker_port" {
  description = "Port exposed by the background docker image to redirect traffic to"
}
variable "background_app_count" {
  description = "Number of background docker containers to run"
}
# variable "background_task_sg_id" {
#   description = "Security group ID for the background ECS task"
# }
# variable "background_target_group_arn" {
#   description = "Target group ARN for the background ECS service"
# }
variable "bg_task_execution_role_name" {
  description = "IAM role name for background ECS task execution"
  type        = string
}


# ##### Secrets Manager #####
# variable "secret_name" {
#   description = "The name of the secret in AWS Secrets Manager"
#   type        = string
# }


### CodePipeline ###
variable "github_webhook_secret" {
  description = "GitHub Webhook Secret"
}
variable "github_be_branch" {
  description = "GitHub Branch"
}
variable "github_owner" {
  description = "GitHub Owner"
}
variable "github_be_repo" {
  description = "GitHub Repository"
}
variable "github_token" {
  description = "GitHub Token"
}

### Code Build- Backend Microservice ###
variable "codebuild_image" {
  description = "CodeBuild Image"
}
variable "image_tag" {
}
variable "BE_Dockerfile_path" {
  description = "Path to the Dockerfile for the backend service"
}

variable "fargate_backend_envs" {
  type        = map(string)
  description = "Environment variables for the backend ECS service"
}

variable "codebuild_image_webapp" {
  description = "CodeBuild Image for WebApp"

}

#### Background Module Variables ####
variable "bg_image_tag" {
  description = "Image Tag"
}
variable "bg_Dockerfile_path" {
  description = "Path to the Dockerfile for the background service"
}

### Frontend
variable "github_frontend_branch" {
  description = "GitHub Branch"
}
variable "github_frontend_repo" {
  description = "GitHub Repository"
}


###### SES #####
variable "ses_domain_name" {
  description = "The domain name to verify with SES"
  type        = string
}
variable "ses_subdomain" {
  description = "Subdomain from which emails are allowed to be sent"
}*/