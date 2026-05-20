output "default_cluster_security_group_id" {
  description = "Default security group ID for the EKS cluster created by AWS"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}
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

/*output "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  value       = var.eks_cluster_sg_id
}*/



output "node_group_SOLVI_dedicated_id" {
  description = "ID of the solvi dedicated node group"
  value       = aws_eks_node_group.node_group_SOLVI_dedicated.id
}

output "node_group_SOLVI_general_id" {
  description = "ID of the solvi general node group"
  value       = aws_eks_node_group.node_group_SOLVI_general.id
}

output "node_group_FINERACT_id" {
  description = "ID of the fineract node group"
  value       = aws_eks_node_group.node_group_FINERACT.id
}

# OIDC Provider outputs for IRSA
output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider for IRSA"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# output "ebs_csi_driver_role_arn" {
#   description = "ARN of the EBS CSI driver IAM role"
#   value       = aws_iam_role.ebs_csi_driver.arn
# }
