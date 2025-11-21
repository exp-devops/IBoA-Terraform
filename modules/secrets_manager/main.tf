# Create secret for PostgreSQL RDS
resource "aws_secretsmanager_secret" "postgres_rds_credentials" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-SOLVIpostgres-RDS-credentials"
  description = "PostgreSQL RDS credentials for ${var.project_name}-${var.project_env}"
  kms_key_id  = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name     = "${var.project_name}-${var.project_segment}-${var.project_env}-SOLVIpostgres-RDS-credentials"
      Database = "PostgreSQL"
    }
  )
}

# Store PostgreSQL credentials
resource "aws_secretsmanager_secret_version" "postgres_rds_credentials" {
  secret_id = aws_secretsmanager_secret.postgres_rds_credentials.id
  secret_string = jsonencode({
    username = var.palms_rds_username
    password = var.palms_rds_password
    engine   = "postgres"
    port     = var.rdsProperty["PORT"]
  })
}

# Create secret for MySQL RDS
resource "aws_secretsmanager_secret" "mysql_rds_credentials" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-FINERACTmysql-RDS-credentials"
  description = "MySQL RDS credentials for ${var.project_name}-${var.project_env}"
  kms_key_id  = var.kms_key_id

  tags = merge(
    var.tags,
    {
      Name     = "${var.project_name}-${var.project_segment}-${var.project_env}-FINERACTmysql-RDS-credentials"
      Database = "MySQL"
    }
  )
}

# Store MySQL credentials
resource "aws_secretsmanager_secret_version" "mysql_rds_credentials" {
  secret_id = aws_secretsmanager_secret.mysql_rds_credentials.id
  secret_string = jsonencode({
    username = var.fineract_rds_username
    password = var.fineract_rds_password
    engine   = "mysql"
    port     = var.rdsProperty_mysql["PORT"]
  })
}

# Create a resource policy for PostgreSQL credentials
resource "aws_secretsmanager_secret_policy" "SOLVIpostgres_rds_credentials" {
  secret_arn = aws_secretsmanager_secret.postgres_rds_credentials.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnablePostgresRDSAccess"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Create a resource policy for MySQL credentials
resource "aws_secretsmanager_secret_policy" "FINERACTmysql_rds_credentials" {
  secret_arn = aws_secretsmanager_secret.mysql_rds_credentials.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableMySQLRDSAccess"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
