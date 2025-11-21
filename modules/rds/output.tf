output "palms_rds_endpoint" {
  value = aws_db_instance.palms_db_instance.endpoint
}

output "palms_rds_writer_endpoint" {
  value = aws_db_instance.palms_db_instance.endpoint
}

output "palms_rds_username" {
  value = aws_db_instance.palms_db_instance.username
}

output "palms_rds_password" {
  value     = aws_db_instance.palms_db_instance.password
  sensitive = true
}

output "fineract_rds_endpoint" {
  value = aws_db_instance.fineract_db_instance.endpoint
}

output "fineract_rds_writer_endpoint" {
  value = aws_db_instance.fineract_db_instance.endpoint
}

output "fineract_rds_username" {
  value = aws_db_instance.fineract_db_instance.username
}

output "fineract_rds_password" {
  value     = aws_db_instance.fineract_db_instance.password
  sensitive = true
}

# Security Group Outputs
output "fineract_rds_sg_id" {
  value       = aws_security_group.fineract_rds_sg.id
  description = "Security group ID for the Fineract RDS instance"
}

output "palms_rds_sg_id" {
  value       = aws_security_group.palms_rds_sg.id
  description = "Security group ID for the PALMS RDS instance"
}