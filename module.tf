data "aws_caller_identity" "current" {}

module "vpc" {
  source                  = "./modules/vpc"
  aws_region             = var.aws_region
  project_name           = var.project_name
  project_env            = var.project_env
  network_cidr           = var.network_cidr
  project_segment        = var.project_segment
  tags                   = var.tags
  public_subnet_01_cidr  = var.public_subnet_01_cidr
  public_subnet_02_cidr  = var.public_subnet_02_cidr
  private_subnet_01_cidr = var.private_subnet_01_cidr
  private_subnet_02_cidr = var.private_subnet_02_cidr
}

module "eks" {
  source              = "./modules/eks"
  project_name        = var.project_name
  project_segment     = var.project_segment
  project_env         = var.project_env
  tags                = var.tags
  vpc_id              = module.vpc.vpc_id
  private_subnet_01   = module.vpc.private_subnet_01
  private_subnet_02   = module.vpc.private_subnet_02
  eksProperty         = var.eksProperty
  #eks_cluster_sg_id   = module.security_groups.eks_cluster_sg_id
  #eks_additional_sg_id = module.security_groups.eks_additional_sg_id
  eks_cluster_security_group_id = module.eks.default_cluster_security_group_id
  kms_key_arn         = module.kms.kms_key.arn
}

module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  project_segment   = var.project_segment
  project_env       = var.project_env
  tags             = var.tags
  vpc_id           = module.vpc.vpc_id
  public_subnet_01 = module.vpc.public_subnet_01
  public_subnet_02 = module.vpc.public_subnet_02
  kms_key_arn      = module.kms.kms_key.arn
}

module "waf" {
  source       = "./modules/waf"
  project_name = var.project_name
  project_env  = var.project_env
  tags        = var.tags
  alb_arn     = module.alb.alb_arn
}

module "secrets_manager" {
  source                = "./modules/secrets_manager"
  project_name          = var.project_name
  project_segment       = var.project_segment
  project_env          = var.project_env
  tags                 = var.tags
  kms_key_id          = module.kms.kms_key.id
  rdsProperty         = var.rdsProperty
  rdsProperty_mysql   = var.rdsProperty_mysql
  palms_rds_username    = module.rds.palms_rds_username
  palms_rds_password    = module.rds.palms_rds_password
  fineract_rds_username = module.rds.fineract_rds_username
  fineract_rds_password = module.rds.fineract_rds_password
}

/*module "acm" {
  source                    = "./modules/acm"
  tags                      = var.tags
  project_name              = var.project_name
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  project_env               = var.project_env
  aws_cli_profile_name      = var.aws_cli_profile_name
  cdn_aws_region            = var.cdn_aws_region
  alb_domain_name           = var.alb_domain_name
}*/

module "kms" {
  source          = "./modules/kms"
  tags            = var.tags
  project_segment = var.project_segment
  project_name    = var.project_name
  project_env     = var.project_env
}
/*module "ecr" {
  source          = "./modules/ecr"
  tags            = var.tags
  project_segment = var.project_segment
  project_name    = var.project_name
  project_env     = var.project_env
}*/

module "s3" {
  source          = "./modules/s3"
  project_name    = var.project_name
  project_segment = var.project_segment
  project_env     = var.project_env
  tags            = var.tags
  aws_account_id  = data.aws_caller_identity.current.account_id
  kms_key_arn     = module.kms.kms_key.arn
}

/*module "cloudfront" {
  source                       = "./modules/cloudfront"
  tags                         = var.tags
  project_name                 = var.project_name
  project_env                  = var.project_env
  frontend_S3_Bucket           = module.s3.frontend_S3_Bucket
  DomainNames                  = var.DomainNames
  project_segment              = var.project_segment
  webSSLCertificateArn         = module.acm.cdn_acm_certificate_arn
  web_acl_waf_arn              = module.waf.web_acl_waf_arn
  alb_domain_name              = var.alb_domain_name
  frontend_s3_website_endpoint = module.s3.frontend_s3_website_endpoint
  alb_arn                      = module.alb.alb_arn
}*/

module "rds" {
  source              = "./modules/rds"
  aws_region          = var.aws_region
  project_segment     = var.project_segment
  rdsProperty         = var.rdsProperty
  rdsProperty_mysql   = var.rdsProperty_mysql
  project_name        = var.project_name
  project_env         = var.project_env
  tags                = var.tags
  private_subnet_01   = module.vpc.private_subnet_01
  private_subnet_02   = module.vpc.private_subnet_02
  vpc_id              = module.vpc.vpc_id
  kms_key             = module.kms.kms_key
  network_cidr        = var.network_cidr
  palms_rds_sg_id     = module.security_groups.palms_rds_sg_id
  fineract_rds_sg_id  = module.security_groups.fineract_rds_sg_id
}

module "ec2" {
  source           = "./modules/ec2"
  tags             = var.tags
  project_name     = var.project_name
  project_segment  = var.project_segment
  project_env      = var.project_env
  public_subnet_01 = module.vpc.public_subnet_01
  private_subnet_01 = module.vpc.private_subnet_01
  bastion_sg_id    = module.security_groups.bastion_sg_id
  rabbitmq_sg_id   = module.security_groups.rabbitmq_sg_id
  igw_id           = module.vpc.igw_id
  kms_key          = module.kms.kms_key.arn
  bastionEC2       = var.bastionEC2
  rabbitmqEC2      = var.rabbitmqEC2
}

module "security_groups" {
  source = "./modules/security_groups"

  tags                      = var.tags
  project_name              = var.project_name
  project_segment           = var.project_segment
  project_env               = var.project_env
  vpc_id                    = module.vpc.vpc_id
  bastion_ssh_allowed_ips   = var.bastion_ssh_allowed_ips
  palms_rds_allowed_ips     = var.palms_rds_allowed_ips
  rds_port                  = var.rdsProperty["PORT"]
  bastion_sg_id             = module.security_groups.bastion_sg_id
  fineract_rds_allowed_ips  = var.fineract_rds_allowed_ips
  eks_cluster_security_group_id = module.eks.default_cluster_security_group_id
  fineract_rds_sg_id = module.security_groups.fineract_rds_sg_id
  palms_rds_sg_id    = module.security_groups.palms_rds_sg_id
  #alb_sg_id                 = module.security_groups.alb_sg_id
  #container_app_port        = var.container_app_port
  #background_container_port = var.background_container_port
}

/*module "ecs" {
  source                       = "./modules/ecs"
  tags                         = var.tags
  project_segment              = var.project_segment
  project_name                 = var.project_name
  project_env                  = var.project_env
  aws_region                   = var.aws_region
  secret_manager_arn           = module.secrets_manager.secret_manager_arn
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
  app_image                    = var.app_image
  container_app_port           = var.container_app_port
  docker_app_port              = var.docker_app_port
  app_count                    = var.app_count
  fargate_cpu                  = var.fargate_cpu
  fargate_memory               = var.fargate_memory
  vpc_id                       = module.vpc.vpc_id
  private_subnet_01            = module.vpc.private_subnet_01
  private_subnet_02            = module.vpc.private_subnet_02
  ecs_task_sg_id               = module.security_groups.ecs_task_sg_id
  app_target_group_arn         = module.alb.app_target_group_arn
  alb_listener_arn             = module.alb.http_listener_arn # or https_listener_arn if using that
  backend_ecr_repo_url         = module.ecr.backend_ecr_repo_url
  aws_account_id               = data.aws_caller_identity.current.account_id
  fargate_backend_envs         = var.fargate_backend_envs
  background_container_port    = var.background_container_port
  background_fargate_cpu       = var.background_fargate_cpu
  background_fargate_memory    = var.background_fargate_memory
  background_docker_port       = var.background_docker_port
  background_app_count         = var.background_app_count
  background_task_sg_id        = module.security_groups.ecs_background_task_sg_id
  background_ecr_repo_url      = module.ecr.background_ecr_repo_url
  bg_task_execution_role_name  = var.bg_task_execution_role_name
  background_target_group_arn  = module.alb.background_target_group_arn
  ses_domain_name              = var.ses_domain_name
}*/

/*module "secrets_manager" {
  source          = "./modules/secrets_manager"
  tags            = var.tags
  project_name    = var.project_name
  project_segment = var.project_segment
  project_env     = var.project_env
}*/


/*module "codepipeline" {
  source = "./modules/codepipeline"

  ############## Codepipline Moudle Common Variables ##############

  #### React Frontend Variables ####
  tags            = var.tags
  project_name    = var.project_name
  project_segment = var.project_segment
  project_env     = var.project_env
  aws_region      = var.aws_region
  github_branch   = var.github_be_branch
  github_owner    = var.github_owner
  github_repo     = var.github_be_repo
  github_token    = var.github_token

  ##deployment variables
  github_be_branch = var.github_be_branch
  github_be_repo   = var.github_be_repo


  ############## Webapp Module Variables ##############
  ecsClusterName        = module.ecs.ecs_cluster.name
  ecsBackendServiceName = module.ecs.ecsBackendServiceName.name
  #github_webhook_secret      = "${var.github_webhook_secret}"
  github_frontend_repo   = var.github_frontend_repo
  github_frontend_branch = var.github_frontend_branch
  codebuild_image_webapp = var.codebuild_image_webapp
  frontendS3Bucket       = module.s3.frontend_S3_Bucket.bucket
  frontendS3Bucket_arn   = module.s3.frontend_S3_Bucket.arn
  cloudFrontId           = module.cloudfront.frontend_cloudfront_distribution_id

  ############## Microservice Module Variables ##############

  #### Common Variables ####
  image_tag       = var.image_tag
  codebuild_image = var.codebuild_image
  aws_account_id  = data.aws_caller_identity.current.account_id

  #### Backend Module Variables ####
  ecrBackendRepositoryName   = module.ecr.ecr_backend_repository_name
  ecrBackendRepositoryURL    = module.ecr.backend_ecr_repo_url
  ecsBackendServiceContainer = tolist(module.ecs.ecs_backend_service_container.load_balancer)[0].container_name
  BE_Dockerfile_path         = var.BE_Dockerfile_path


  #### Background Module Variables ####
  ecsBackgroundServiceName = module.ecs.ecsBackgroundServiceName.name

  ecrBackgroundRepositoryName   = module.ecr.ecr_background_repository_name
  bg_image_tag                  = var.bg_image_tag
  ecrBackgroundRepositoryURL    = module.ecr.background_ecr_repo_url
  ecsBackgroundServiceContainer = tolist(module.ecs.ecs_background_service_container.load_balancer)[0].container_name
  bg_Dockerfile_path            = var.bg_Dockerfile_path
}*/

/*module "ses" {
  source = "./modules/ses"

  project_name    = var.project_name
  project_segment = var.project_segment
  project_env     = var.project_env
  ses_domain_name = var.ses_domain_name
  aws_region      = var.aws_region
  ses_subdomain   = var.ses_subdomain
}*/