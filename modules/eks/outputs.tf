output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  value       = var.eks_cluster_sg_id
}

output "node_group_1_id" {
  description = "ID of the first node group"
  value       = aws_eks_node_group.node_group_1.id
}

output "node_group_2_id" {
  description = "ID of the second node group"
  value       = aws_eks_node_group.node_group_2.id
}
