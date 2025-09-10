# Random string to use as master password unless one is specified
resource "random_password" "master_password_rds_fineract" {
  length  = 32
  special = false
}

# DB subnet group for MySQL RDS
resource "aws_db_subnet_group" "fineract_db_subnet_group" {
  name       = "${var.project_name}-${var.project_segment}-${var.project_env}-fineract-rds-subnet-group"
  subnet_ids = [var.private_subnet_01, var.private_subnet_02]
  
  tags = merge(
    local.common_tags, 
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-fineract-rds-subnet-group"
    }
  )
}

# Parameter group for MySQL
resource "aws_db_parameter_group" "fineract_mysql" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-mysql8-pg"
  family      = "mysql8.0"
  description = "Custom parameter group for MySQL 8.0"

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# MySQL RDS Instance
resource "aws_db_instance" "fineract_db_instance" {
  identifier          = "${var.project_name}-${var.project_segment}-${var.project_env}-fineractrdsinstance"
  engine              = var.rdsProperty_mysql["ENGINE"]
  engine_version      = var.rdsProperty_mysql["ENGINE_VERSION"]
  instance_class      = var.rdsProperty_mysql["INSTANCE_CLASS"]
  allocated_storage   = var.rdsProperty_mysql["ALLOCATED_STORAGE"]
  storage_type        = var.rdsProperty_mysql["STORAGE_TYPE"]
  backup_retention_period = var.rdsProperty_mysql["BACKUP_RETENTION_PERIOD"]
  max_allocated_storage = var.rdsProperty_mysql["MAX_ALLOCATED_STORAGE"]
  backup_window         = var.rdsProperty_mysql["BACKUP_WINDOW"]
  maintenance_window    = var.rdsProperty_mysql["MAINTENANCE_WINDOW"]
  auto_minor_version_upgrade = var.rdsProperty_mysql["AUTO_MINOR_VERSION_UPGRADE"]
  skip_final_snapshot = var.rdsProperty_mysql["SKIP_FINAL_SNAPSHOT"]
  final_snapshot_identifier = var.rdsProperty_mysql["FINAL_SNAPSHOT_IDENTIFIER"]
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.fineract_db_subnet_group.name
  deletion_protection     = var.rdsProperty_mysql["DELETION_PROTECTION"]
  apply_immediately   = true
  storage_encrypted  = true
  kms_key_id         = var.kms_key.arn
  parameter_group_name = aws_db_parameter_group.fineract_mysql.name
  vpc_security_group_ids = [var.fineract_rds_sg_id]

  username     = var.rdsProperty_mysql["USERNAME"]
  password     = random_password.master_password_rds_fineract.result
  db_name      = var.rdsProperty_mysql["DATABASE_NAME"]

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${var.project_name}-${var.project_segment}-${var.project_env}-fineract-db-instance"
    })
  )
}
