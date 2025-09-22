output "postgres_secret_arn" {
  description = "ARN of the PostgreSQL RDS credentials secret"
  value       = aws_secretsmanager_secret.postgres_rds_credentials.arn
}

output "postgres_secret_name" {
  description = "Name of the PostgreSQL RDS credentials secret"
  value       = aws_secretsmanager_secret.postgres_rds_credentials.name
}

output "mysql_secret_arn" {
  description = "ARN of the MySQL RDS credentials secret"
  value       = aws_secretsmanager_secret.mysql_rds_credentials.arn
}

output "mysql_secret_name" {
  description = "Name of the MySQL RDS credentials secret"
  value       = aws_secretsmanager_secret.mysql_rds_credentials.name
}
