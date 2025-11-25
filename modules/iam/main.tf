# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# IAM Policy for secret readonly
resource "aws_iam_policy" "secret_readonly_irsa" {
  name        = "secret-readonly-irsa"
  description = "Policy to allow reading secrets from AWS Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*"
      }
    ]
  })

  tags = var.tags
}

# IAM Role with trust relationship for IRSA
resource "aws_iam_role" "solvi_irsa_role" {
  name = "solvi-irsa-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "solvi_irsa_policy_attachment" {
  policy_arn = aws_iam_policy.secret_readonly_irsa.arn
  role       = aws_iam_role.solvi_irsa_role.name
}