output "bastion_sg_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion_sg.id
}

output "palms_rds_sg_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.palms_rds_sg.id
}

output "fineract_rds_sg_id" {
  description = "ID of the fineract RDS security group"
  value       = aws_security_group.fineract_rds_sg.id
}

/*output "eks_cluster_sg_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster_sg.id
}

output "eks_additional_sg_id" {
  description = "ID of the additional EKS security group"
  value       = aws_security_group.eks_additional_sg.id
}*/

output "rabbitmq_sg_id" {
  description = "ID of the RabbitMQ security group"
  value       = aws_security_group.rabbitmq.id
}
