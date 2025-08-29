############################### Common Variables ###############################
project_name     = "iboa"
project_segment      = "palms"
project_env     = "test"
aws_region     = "ap-southeast-2"
aws_cli_profile_name     = "iboatest"

tags = {
  "Project"     = "iboa-palms"
}

############################### VPC Variables ###############################
network_cidr           = "10.0.0.0/16"
public_subnet_01_cidr  = "10.0.1.0/24"
public_subnet_02_cidr  = "10.0.2.0/24"
private_subnet_01_cidr = "10.0.3.0/24"
private_subnet_02_cidr = "10.0.4.0/24"

############################### ACM ###############################
/*cdn_aws_region = "us-east-1"
domain_name = "customer-onboading-dev.iboa.com.au"
subject_alternative_names = [
  "customer-onboading-dev-api.iboa.com.au",
  "customer-onboading-dev-background.iboa.com.au",
]

alb_domain_name = "cob-alb-dev.iboa.com.au"

############################### Cloudfront Variables ###############################
DomainNames = {
  "react_frontend_domain" = "customer-onboading-dev.iboa.com.au"
  "api_be_domain"           = "customer-onboading-dev-api.iboa.com.au"
  "api_background_domain" = "customer-onboading-dev-background.iboa.com.au"
  "alb_domain"           = "cob-alb-dev.iboa.com.au"
}

# webSSLCertificateArn = {
#   "cdn_ssl"     = "arn:aws:acm:us-east-1:337909776681:certificate/9364b7eb-83f6-47c2-baed-39a62"
#   "alb_ssl"     = "arn:aws:acm:eu-west-2:337909776681:certificate/7575a3d2-cc2f-4404-bcda-85e52e"
# }

############################### WAF ###############################
waf_allowed_ips = [
  "103.141.54.138/32",
  "3.7.243.85/32",
  "103.121.27.178/32",
  "103.135.95.18/32",
  "103.79.223.18/32",
  "18.168.156.169/32", #NAT IP to be modified after creation.
  "13.41.101.210/32" #NAT IP to be modified after creation.
]
*/
############################### RDS Database ###############################
rdsProperty = {
  "ENGINE"                  = "postgres"
  "ENGINE_VERSION"          = "14.12"
  "INSTANCE_CLASS"          = "db.t3.small"
  "BACKUP_RETENTION_PERIOD" = "7"
  "MULTI_AZ"                = false
  "PORT"                    = "5432"
  "DELETION_PROTECTION"     = false
  "USERNAME"                = "palmspre"
  "DATABASE_NAME"           = "palms_preprod"
  "ALLOCATED_STORAGE"       = "100"
  "STORAGE_TYPE"            = "gp3"
  "MAX_ALLOCATED_STORAGE"   = "1000"
  "BACKUP_WINDOW"           = "15:00-15:30"
  "MAINTENANCE_WINDOW"      = "Mon:16:00-Mon:17:30"
  "AUTO_MINOR_VERSION_UPGRADE" = "false"
  "SKIP_FINAL_SNAPSHOT"        = false
  "FINAL_SNAPSHOT_IDENTIFIER" = "terraform-finalisnapshot"
  #"parameterGroupFamily"      = "postgres14"
}

rdsProperty_mysql = {
  "ENGINE"                  = "mysql"
  "ENGINE_VERSION"          = "8.0.37"
  "INSTANCE_CLASS"          = "db.t3.micro"
  "BACKUP_RETENTION_PERIOD" = "7"
  "MULTI_AZ"                = false
  "PORT"                    = "3306"
  "DELETION_PROTECTION"     = false
  "USERNAME"                = "fineractadmin"
  "DATABASE_NAME"           = "fineractDB"
  "ALLOCATED_STORAGE"       = "20"
  "STORAGE_TYPE"            = "gp3"
  "MAX_ALLOCATED_STORAGE"   = "100"
  "BACKUP_WINDOW"           = "18:00-18:30"
  "MAINTENANCE_WINDOW"      = "Tue:16:00-Tue:17:30"
  "AUTO_MINOR_VERSION_UPGRADE" = "false"
  "SKIP_FINAL_SNAPSHOT"        = false
  "FINAL_SNAPSHOT_IDENTIFIER"  = "terraform-finalisnapshot-mysql"
}

palms_rds_allowed_ips = {
  "3.7.243.85/32" = "Exp_OpenVPN_IP"
}

fineract_rds_allowed_ips = {
  "3.7.243.85/32" = "Exp_OpenVPN_IP"
}

############################### EKS ###############################
eksProperty = {
  "CLUSTER_VERSION"     = "1.32"
  "NODE_INSTANCE_TYPE"  = "t3.medium"
  "NODE_DISK_SIZE"      = "30"
  "NG1_DESIRED_SIZE"    = "1"
  "NG1_MAX_SIZE"        = "1"
  "NG1_MIN_SIZE"        = "1"
  "NG2_DESIRED_SIZE"    = "1"
  "NG2_MAX_SIZE"        = "1"
  "NG2_MIN_SIZE"        = "1"
}

############################### EC2 ###############################
bastionEC2 = {
  "ami"     = "ami-0deeb71371199f16f"
  "instance_type" = "t3.micro"
  "volume_size" = "8"
  "volume_type" = "gp3"
  "encrypted" = "true"
  "delete_on_termination" = "true"
}
 
bastion_ssh_allowed_ips = {
  "3.7.243.85/32" = "Exp_OpenVPN_IP"
}

############################### ALB ###############################
/*alb_app_port     = 80
az_count     = "2"
health_check_path = "/api/healthcheck"

bg_service_port = 80
bg_health_check_path = "/"

############################### ECS Fargate Variables ###############################

### Backend
ecs_task_execution_role_name     = "EcsTaskExecutionRole-dev"
app_image     = "404690015370.dkr.ecr.ap-south-1.amazonaws.com/iboa-prod:latest"
container_app_port     = 8080
docker_app_port = 8080
app_count     = 1
fargate_cpu     = "1024"
fargate_memory     = "2048"
fargate_backend_envs = {
  "RDS_POSTGRES_ENDPOINT"          = "iboa-cob-dev-rds-instance.cfi22aoekveb.ap-southeast-2.rds.amazonaws.com"
  "RDS_POSTGRES_PORT"              = "5432"
  "RDS_POSTGRES_DB"                = "iboa-cob-dev-app-db"
  "RDS_POSTGRES_USERNAME"          = "iboa_app_dev_app_user"
  "RDS_POSTGRES_PASSWORD"          = "Rv/Q5Vqb%>P/CM!P"
  "ASPNETCORE_ENVIRONMENT"                           = "Development"
  "ConnectionStrings__PostgresConnection"             = "arn:aws:secretsmanager:ap-southeast-2:282517244365:secret:iboa-cob-dev-backend_secret-z6seZT"
}

### Background
background_container_port = 8080
background_fargate_cpu = "1024"
background_fargate_memory = "2048"
background_docker_port = 8080
background_app_count = 0
bg_task_execution_role_name = "EcsTaskExecutionRole-background-dev"

############################### Codepipeline ###############################

#### Codepipeline Microservice Variables ####
github_be_branch        = "develop"
github_owner        = "experiongithub"
github_be_repo         = "IBOA_IDV_Services"
#github_token        = "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"
github_token        = "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" #iboa-github-token
github_webhook_secret = "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"

#### CodeBuild Microservice Variables ####
codebuild_image = "aws/codebuild/standard:7.0"
BE_Dockerfile_path = "IBOA.IDV.WebAPI/Dockerfile"
image_tag = "latest"

bg_Dockerfile_path = "IBOA.IDV.WebAPI/Dockerfile"
bg_image_tag  = "latest"

#### Codepipeline Webapp Variables #### 
codebuild_image_webapp  = "aws/codebuild/standard:7.0"
github_frontend_branch  = "dashboards-ui"
github_frontend_repo  = "IBOA_IDV_Client"


############################### SES ###############################
ses_domain_name = "iboa.com.au"
ses_subdomain = "cob-dev.iboa.com.au"*/