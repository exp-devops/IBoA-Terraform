# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# IAM Policy for secret readonly
resource "aws_iam_policy" "secret_readonly_irsa" {
  name        = "secret_readonly_irsa"
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
  name = "solvi_irsa_role"
  
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

# IAM Policy for ECR access
resource "aws_iam_policy" "aws_ecr" {
  name        = "AWS_ecr"
  description = "Policy to allow ECR push operations"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for EKS read-only access
resource "aws_iam_policy" "eks_readonly" {
  name        = "EKS_readonly"
  description = "Policy to allow read-only access to EKS clusters"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM Group for EKS Admin
resource "aws_iam_group" "eks_admin" {
  name = "EKSadmin"
}

# Attach AWS managed policy AmazonEKSClusterPolicy to EKSadmin group
resource "aws_iam_group_policy_attachment" "eks_admin_policy" {
  group      = aws_iam_group.eks_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Group for EKS Read-only
resource "aws_iam_group" "eks_readonly" {
  name = "EKSreadonly"
}

# Attach EKS_readonly custom policy to EKSreadonly group
resource "aws_iam_group_policy_attachment" "eks_readonly_policy" {
  group      = aws_iam_group.eks_readonly.name
  policy_arn = aws_iam_policy.eks_readonly.arn
}

# IAM Group for Jenkins
/*resource "aws_iam_group" "jenkins" {
  name = "Jenkins"
}

# Attach AWS_ecr custom policy to Jenkins group
resource "aws_iam_group_policy_attachment" "jenkins_policy" {
  group      = aws_iam_group.jenkins.name
  policy_arn = aws_iam_policy.aws_ecr.arn
}*/

# IAM Policy for EKS deployment
resource "aws_iam_policy" "eks_deployment_policy" {
  name        = "EKS_deployment_policy"
  description = "Policy to allow EKS cluster describe operations"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "eks:DescribeCluster"
        Resource = "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"
      }
    ]
  })

  tags = var.tags
}

# IAM Role for EKS deployment
resource "aws_iam_role" "eks_deployment_role" {
  name = "EKS_deployment_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::796973480744:role/Jenkins-EC2-Role"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach EKS deployment policy to the role
resource "aws_iam_role_policy_attachment" "eks_deployment_policy_attachment" {
  policy_arn = aws_iam_policy.eks_deployment_policy.arn
  role       = aws_iam_role.eks_deployment_role.name
}

# Attach AWS ECR policy to the EKS deployment role
resource "aws_iam_role_policy_attachment" "eks_deployment_ecr_attachment" {
  policy_arn = aws_iam_policy.aws_ecr.arn
  role       = aws_iam_role.eks_deployment_role.name
}