# Random string to use as master password unless one is specified
resource "random_password" "master_password_rds_palms" {
  length  = 32
  special = false
}

# DB subnet group for PostgreSQL RDS
resource "aws_db_subnet_group" "palms_db_subnet_group" {
  name       = "${var.project_name}-${var.project_segment}-${var.project_env}-palms-rds-subnet-group"
  subnet_ids = [var.private_subnet_01, var.private_subnet_02]
  
  tags = merge(
    local.common_tags, 
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-palms-rds-subnet-group"
    }
  )
}

# Parameter group for PostgreSQL
resource "aws_db_parameter_group" "palms_pg14" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-postgres14-pg"
  family      = "postgres14"
  description = "Custom parameter group for PostgreSQL 14"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# PostgreSQL RDS Instance
resource "aws_db_instance" "palms_db_instance" {
  identifier          = "${var.project_name}${var.project_segment}${var.project_env}palmsrdsinstance"
  engine              = var.rdsProperty["ENGINE"]
  engine_version      = var.rdsProperty["ENGINE_VERSION"]
  instance_class      = var.rdsProperty["INSTANCE_CLASS"]
  allocated_storage   = var.rdsProperty["ALLOCATED_STORAGE"]
  storage_type        = var.rdsProperty["STORAGE_TYPE"]
  backup_retention_period = var.rdsProperty["BACKUP_RETENTION_PERIOD"]
  max_allocated_storage = var.rdsProperty["MAX_ALLOCATED_STORAGE"]
  backup_window         = var.rdsProperty["BACKUP_WINDOW"]
  maintenance_window    = var.rdsProperty["MAINTENANCE_WINDOW"]
  auto_minor_version_upgrade = var.rdsProperty["AUTO_MINOR_VERSION_UPGRADE"]
  skip_final_snapshot = var.rdsProperty["SKIP_FINAL_SNAPSHOT"]
  final_snapshot_identifier = var.rdsProperty["FINAL_SNAPSHOT_IDENTIFIER"]
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.palms_db_subnet_group.name
  deletion_protection     = var.rdsProperty["DELETION_PROTECTION"]
  apply_immediately   = true
  storage_encrypted  = true
  kms_key_id         = var.kms_key.arn
  parameter_group_name = aws_db_parameter_group.palms_pg14.name
  vpc_security_group_ids = [var.palms_rds_sg_id]

  username     = var.rdsProperty["USERNAME"]
  password     = random_password.master_password_rds_palms.result
  db_name      = var.rdsProperty["DATABASE_NAME"]

  tags = merge(
    local.common_tags,
    tomap({
      "Name" = "${var.project_name}-${var.project_segment}-${var.project_env}-palms-db-instance"
    })
  )
}
