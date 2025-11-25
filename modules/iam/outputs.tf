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