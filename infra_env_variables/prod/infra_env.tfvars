############################### Common Variables ###############################
project_name         = "iboa"
project_segment      = "solvi"
project_env          = "prod"
aws_region           = "ap-southeast-2"
aws_cli_profile_name = "iboaprod"

tags = {
  "Project" = "iboa-solvi"
}

############################### VPC Variables ###############################
network_cidr           = "10.0.0.0/16"
public_subnet_01_cidr  = "10.0.1.0/24"
public_subnet_02_cidr  = "10.0.2.0/24"
private_subnet_01_cidr = "10.0.3.0/24"
private_subnet_02_cidr = "10.0.4.0/24"

############################### RDS Database ###############################
rdsProperty = {
  "ENGINE"                     = "postgres"
  "ENGINE_VERSION"             = "14.15"
  "INSTANCE_CLASS"             = "db.t3.small"
  "BACKUP_RETENTION_PERIOD"    = "7"
  "MULTI_AZ"                   = false
  "PORT"                       = "5432"
  "DELETION_PROTECTION"        = false
  "USERNAME"                   = "solviprod"
  "DATABASE_NAME"              = "solvi_prod"
  "ALLOCATED_STORAGE"          = "100"
  "STORAGE_TYPE"               = "gp3"
  "MAX_ALLOCATED_STORAGE"      = "1000"
  "BACKUP_WINDOW"              = "15:00-15:30"
  "MAINTENANCE_WINDOW"         = "Mon:16:00-Mon:17:30"
  "AUTO_MINOR_VERSION_UPGRADE" = "false"
  "SKIP_FINAL_SNAPSHOT"        = false
  "FINAL_SNAPSHOT_IDENTIFIER"  = "terraform-finalisnapshot"
  #"parameterGroupFamily"      = "postgres14"
}

rdsProperty_mysql = {
  "ENGINE"                     = "mysql"
  "ENGINE_VERSION"             = "8.0.37"
  "INSTANCE_CLASS"             = "db.t3.micro"
  "BACKUP_RETENTION_PERIOD"    = "7"
  "MULTI_AZ"                   = false
  "PORT"                       = "3306"
  "DELETION_PROTECTION"        = false
  "USERNAME"                   = "fineractadmin"
  "DATABASE_NAME"              = "fineractDB"
  "ALLOCATED_STORAGE"          = "20"
  "STORAGE_TYPE"               = "gp3"
  "MAX_ALLOCATED_STORAGE"      = "100"
  "BACKUP_WINDOW"              = "18:00-18:30"
  "MAINTENANCE_WINDOW"         = "Tue:16:00-Tue:17:30"
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
  "CLUSTER_VERSION"       = "1.34"
  "NODE_INSTANCE_TYPE"    = "t3.medium"
  "NODE_DISK_SIZE"        = "30"
  "SOLVI_DESIRED_SIZE"    = "1"
  "SOLVI_MAX_SIZE"        = "1"
  "SOLVI_MIN_SIZE"        = "1"
  "FINERACT_DESIRED_SIZE" = "1"
  "FINERACT_MAX_SIZE"     = "1"
  "FINERACT_MIN_SIZE"     = "1"
}

############################### EC2 ###############################
bastionEC2 = {
  "ami"                   = "ami-0deeb71371199f16f"
  "instance_type"         = "t3.micro"
  "volume_size"           = "8"
  "volume_type"           = "gp3"
  "encrypted"             = "true"
  "delete_on_termination" = "true"
}

bastion_ssh_allowed_ips = {
  "3.7.243.85/32" = "Exp_OpenVPN_IP"
}

# RabbitMQ EC2
rabbitmqEC2 = {
  "ami"                   = "ami-0deeb71371199f16f" # 
  "instance_type"         = "t3.micro"
  "volume_size"           = "8"
  "volume_type"           = "gp3"
  "delete_on_termination" = true
}

