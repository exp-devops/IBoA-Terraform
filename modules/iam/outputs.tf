output "policy_arn" {
  description = "ARN of the secret readonly IAM policy"
  value       = aws_iam_policy.secret_readonly_irsa.arn
}

output "policy_name" {
  description = "Name of the secret readonly IAM policy"
  value       = aws_iam_policy.secret_readonly_irsa.name
}

output "role_arn" {
  description = "ARN of the IRSA IAM role"
  value       = aws_iam_role.solvi_irsa_role.arn
}

output "role_name" {
  description = "Name of the IRSA IAM role"
  value       = aws_iam_role.solvi_irsa_role.name
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider used for IRSA"
  value       = var.oidc_provider_arn
}

output "aws_ecr_policy_arn" {
  description = "ARN of the AWS ECR IAM policy"
  value       = aws_iam_policy.aws_ecr.arn
}

output "aws_ecr_policy_name" {
  description = "Name of the AWS ECR IAM policy"
  value       = aws_iam_policy.aws_ecr.name
}

output "eks_readonly_policy_arn" {
  description = "ARN of the EKS readonly IAM policy"
  value       = aws_iam_policy.eks_readonly.arn
}

output "eks_readonly_policy_name" {
  description = "Name of the EKS readonly IAM policy"
  value       = aws_iam_policy.eks_readonly.name
}

output "eks_admin_group_name" {
  description = "Name of the EKSadmin IAM group"
  value       = aws_iam_group.eks_admin.name
}

output "eks_admin_group_arn" {
  description = "ARN of the EKSadmin IAM group"
  value       = aws_iam_group.eks_admin.arn
}

output "eks_readonly_group_name" {
  description = "Name of the EKSreadonly IAM group"
  value       = aws_iam_group.eks_readonly.name
}

output "eks_readonly_group_arn" {
  description = "ARN of the EKSreadonly IAM group"
  value       = aws_iam_group.eks_readonly.arn
}

/*output "jenkins_group_name" {
  description = "Name of the Jenkins IAM group"
  value       = aws_iam_group.jenkins.name
}

output "jenkins_group_arn" {
  description = "ARN of the Jenkins IAM group"
  value       = aws_iam_group.jenkins.arn
}*/

output "eks_deployment_role_arn" {
  description = "ARN of the EKS deployment IAM role"
  value       = aws_iam_role.eks_deployment_role.arn
}

output "eks_deployment_role_name" {
  description = "Name of the EKS deployment IAM role"
  value       = aws_iam_role.eks_deployment_role.name
}

output "eks_deployment_policy_arn" {
  description = "ARN of the EKS deployment IAM policy"
  value       = aws_iam_policy.eks_deployment_policy.arn
}

output "eks_deployment_policy_name" {
  description = "Name of the EKS deployment IAM policy"
  value       = aws_iam_policy.eks_deployment_policy.name
}

output "grafana_cloudwatch_role_arn" {
  description = "ARN of the Grafana CloudWatch cross-account IAM role"
  value       = aws_iam_role.grafana_cloudwatch_role.arn
}

output "grafana_cloudwatch_role_name" {
  description = "Name of the Grafana CloudWatch cross-account IAM role"
  value       = aws_iam_role.grafana_cloudwatch_role.name
}

output "grafana_external_id" {
  description = "External ID to use when configuring the data source in Grafana"
  value       = "${data.aws_caller_identity.current.account_id}-grafana"
}

output "ses_custom_policy_arn" {
  description = "ARN of the SES custom IAM policy"
  value       = aws_iam_policy.ses_custom.arn
}

output "ses_custom_policy_name" {
  description = "Name of the SES custom IAM policy"
  value       = aws_iam_policy.ses_custom.name
}

output "ses_qa_user_name" {
  description = "Name of the ses_qa IAM user"
  value       = aws_iam_user.ses_qa.name
}

output "ses_qa_user_arn" {
  description = "ARN of the ses_qa IAM user"
  value       = aws_iam_user.ses_qa.arn
}

output "ses_qa_access_key_id" {
  description = "Access key ID for ses_qa user"
  value       = aws_iam_access_key.ses_qa_access_key.id
}

output "ses_qa_secret_access_key" {
  description = "Secret access key for ses_qa user"
  value       = aws_iam_access_key.ses_qa_access_key.secret
  sensitive   = true
}