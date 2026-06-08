data "aws_caller_identity" "current" {}

module "vpc" {
  source                 = "./modules/vpc"
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
  source            = "./modules/eks"
  project_name      = var.project_name
  project_segment   = var.project_segment
  project_env       = var.project_env
  tags              = var.tags
  vpc_id            = module.vpc.vpc_id
  private_subnet_01 = module.vpc.private_subnet_01
  private_subnet_02 = module.vpc.private_subnet_02
  eksProperty       = var.eksProperty
  #eks_cluster_sg_id   = module.security_groups.eks_cluster_sg_id
  #eks_additional_sg_id = module.security_groups.eks_additional_sg_id
  eks_cluster_security_group_id = module.eks.default_cluster_security_group_id
  kms_key_arn                   = module.kms.kms_key.arn
  bastion_sg_id                 = module.ec2.bastion_sg_id
  eks_deployment_role_arn       = module.iam.eks_deployment_role_arn
}

# module "alb" {
#   source           = "./modules/alb"
#   project_name     = var.project_name
#   project_segment  = var.project_segment
#   project_env      = var.project_env
#   tags             = var.tags
#   vpc_id           = module.vpc.vpc_id
#   public_subnet_01 = module.vpc.public_subnet_01
#   public_subnet_02 = module.vpc.public_subnet_02
#   kms_key_arn      = module.kms.kms_key.arn
# }

# module "waf" {
#   source       = "./modules/waf"
#   project_name = var.project_name
#   project_env  = var.project_env
#   tags         = var.tags
#   alb_arn      = module.alb.alb_arn
# }

module "secrets_manager" {
  source                = "./modules/secrets_manager"
  project_name          = var.project_name
  project_segment       = var.project_segment
  project_env           = var.project_env
  tags                  = var.tags
  kms_key_id            = module.kms.kms_key.id
  rdsProperty           = var.rdsProperty
  rdsProperty_mysql     = var.rdsProperty_mysql
  palms_rds_username    = module.rds.palms_rds_username
  palms_rds_password    = module.rds.palms_rds_password
  fineract_rds_username = module.rds.fineract_rds_username
  fineract_rds_password = module.rds.fineract_rds_password
}

module "acm" {
  source                    = "./modules/acm"
  tags                      = var.tags
  project_name              = var.project_name
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  project_env               = var.project_env
}

module "kms" {
  source          = "./modules/kms"
  tags            = var.tags
  project_segment = var.project_segment
  project_name    = var.project_name
  project_env     = var.project_env
}

module "ecr" {
  source          = "./modules/ecr"
  tags            = var.tags
  project_segment = var.project_segment
  project_name    = var.project_name
  project_env     = var.project_env
}

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
  source            = "./modules/rds"
  aws_region        = var.aws_region
  project_segment   = var.project_segment
  rdsProperty       = var.rdsProperty
  rdsProperty_mysql = var.rdsProperty_mysql
  project_name      = var.project_name
  project_env       = var.project_env
  tags              = var.tags
  private_subnet_01 = module.vpc.private_subnet_01
  private_subnet_02 = module.vpc.private_subnet_02
  vpc_id            = module.vpc.vpc_id
  kms_key           = module.kms.kms_key
  network_cidr      = var.network_cidr
  # Security group variables for RDS internal security groups
  fineract_rds_allowed_ips      = var.fineract_rds_allowed_ips
  palms_rds_allowed_ips         = var.palms_rds_allowed_ips
  bastion_sg_id                 = module.ec2.bastion_sg_id
  eks_cluster_security_group_id = module.eks.default_cluster_security_group_id
}

module "ec2" {
  source            = "./modules/ec2"
  tags              = var.tags
  project_name      = var.project_name
  project_segment   = var.project_segment
  project_env       = var.project_env
  public_subnet_01  = module.vpc.public_subnet_01
  private_subnet_01 = module.vpc.private_subnet_01
  # Security group variables for EC2 internal security groups
  vpc_id                        = module.vpc.vpc_id
  bastion_ssh_allowed_ips       = var.bastion_ssh_allowed_ips
  eks_cluster_security_group_id = module.eks.default_cluster_security_group_id
  fineract_rds_sg_id            = module.rds.fineract_rds_sg_id
  palms_rds_sg_id               = module.rds.palms_rds_sg_id
  igw_id                        = module.vpc.igw_id
  kms_key                       = module.kms.kms_key.arn
  bastionEC2                    = var.bastionEC2
  # rabbitmqEC2                   = var.rabbitmqEC2
}

module "iam" {
  source            = "./modules/iam"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  region            = var.aws_region
  namespace         = "solviprod"
  service_account_name = "solvi-sa"
  eks_cluster_name  = module.eks.cluster_name
  tags              = var.tags
}

# VPC Peering module for Jenkins cross-account connectivity
# NOTE: This module accepts the VPC peering connection created from Jenkins account
# You must first create the peering request from Jenkins account (796973480744)
# After creating the peering connection, provide the connection ID here
module "vpc_peering" {
  source                    = "./modules/vpc_peering"
  project_name              = var.project_name
  project_segment           = var.project_segment
  project_env               = var.project_env
  tags                      = var.tags
  vpc_peering_connection_id = var.vpc_peering_connection_id
  jenkins_vpc_cidr          = var.jenkins_vpc_cidr
  public_route_table_id     = module.vpc.public_route_table_id
  private_route_table_id    = module.vpc.private_route_table_id
}

/*module "ses" {
  source = "./modules/ses"

  project_name    = var.project_name
  project_segment = var.project_segment
  project_env     = var.project_env
  ses_domain_name = var.ses_domain_name
  aws_region      = var.aws_region
  ses_subdomain   = var.ses_subdomain
}*/