############################### Common Variables ###############################
project_name         = "iboa"
project_segment      = "solvi"
project_env          = "qa"
aws_region           = "ap-southeast-2"
aws_cli_profile_name = "iboasolviqa"

tags = {
  "Project" = "iboa-solvi"
}

############################### VPC Variables ###############################
network_cidr           = "10.3.0.0/16"
public_subnet_01_cidr  = "10.3.1.0/24"
public_subnet_02_cidr  = "10.3.2.0/24"
private_subnet_01_cidr = "10.3.3.0/24"
private_subnet_02_cidr = "10.3.4.0/24"

############################### RDS Database ###############################
rdsProperty = {
  "ENGINE"                     = "postgres"
  "ENGINE_VERSION"             = "14.15"
  "INSTANCE_CLASS"             = "db.t3.small"
  "BACKUP_RETENTION_PERIOD"    = "7"
  "MULTI_AZ"                   = false
  "PORT"                       = "5432"
  "DELETION_PROTECTION"        = false
  "USERNAME"                   = "solviqadbuser"
  "DATABASE_NAME"              = "solviqadb"
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
  "ENGINE_VERSION"             = "8.0.42"
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
  "103.121.27.178/32" = "experion_tvm_forticlient_primary"
  "103.79.223.18/32"  = "experion_tvm_forticlient_secondary"
  "103.135.95.18/32"  = "experion_cochin_forticlient_primary"
  "103.141.54.138/32" = "experion_cochin_forticlient_secondary"
}

fineract_rds_allowed_ips = {
  "103.121.27.178/32" = "experion_tvm_forticlient_primary"
  "103.79.223.18/32"  = "experion_tvm_forticlient_secondary"
  "103.135.95.18/32"  = "experion_cochin_forticlient_primary"
  "103.141.54.138/32" = "experion_cochin_forticlient_secondary"
}

############################### EKS ###############################
eksProperty = {
  "CLUSTER_VERSION"       = "1.35"
  "NODE_INSTANCE_TYPE"    = "t3a.medium"
  "NODE_DISK_SIZE"        = "30"
  "SOLVIGENERAL_DESIRED_SIZE"    = "1"
  "SOLVIGENERAL_MAX_SIZE"        = "1"
  "SOLVIGENERAL_MIN_SIZE"        = "1"
  "SOLVIDEDICATED_DESIRED_SIZE"  = "1"
  "SOLVIDEDICATED_MAX_SIZE"      = "1"
  "SOLVIDEDICATED_MIN_SIZE"      = "1"
  "FINERACT_DESIRED_SIZE" = "1"
  "FINERACT_MAX_SIZE"     = "1"
  "FINERACT_MIN_SIZE"     = "1"
}

############################### EC2 ###############################
bastionEC2 = {
  "ami"                   = "ami-0bf1982bfc7bbc490"
  "instance_type"         = "t3a.micro"
  "volume_size"           = "8"
  "volume_type"           = "gp3"
  "encrypted"             = "true"
  "delete_on_termination" = "true"
}

bastion_ssh_allowed_ips = {
  "103.121.27.178/32" = "experion_tvm_forticlient_primary"
  "103.79.223.18/32"  = "experion_tvm_forticlient_secondary"
  "103.135.95.18/32"  = "experion_cochin_forticlient_primary"
  "103.141.54.138/32" = "experion_cochin_forticlient_secondary"
}

# RabbitMQ EC2
# rabbitmqEC2 = {
#   "ami"                   = "ami-0deeb71371199f16f" # 
#   "instance_type"         = "t3.micro"
#   "volume_size"           = "8"
#   "volume_type"           = "gp3"
#   "delete_on_termination" = true
# }

############################### VPC Peering for Jenkins ###############################
vpc_peering_connection_id = "pcx-06be408e421cd4223"
jenkins_vpc_cidr          = "10.15.0.0/16"

