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
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:IBoASecretManager-*"
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

# IAM Policy for KMS read/decrypt access used by the IRSA role
resource "aws_iam_policy" "kms_readonly_irsa" {
  name        = "kms_readonly_irsa"
  description = "Policy to allow the IRSA role to read key metadata and decrypt with the project KMS key"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:DescribeKey",
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })

  tags = var.tags
}

# Attach KMS read/decrypt policy to the IRSA role
resource "aws_iam_role_policy_attachment" "kms_readonly_irsa_attachment" {
  policy_arn = aws_iam_policy.kms_readonly_irsa.arn
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

# IAM Policy for SSM session access to bastion instance
resource "aws_iam_policy" "bastion_ssm" {
  name        = "bastion_ssm"
  description = "Policy to allow SSM session access to bastion instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:ResumeSession"
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/${var.bastion_instance_id}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession"
        ]
        Resource = [
          "arn:aws:ssm:${var.region}::document/AWS-StartPortForwardingSessionToRemoteHost"
        ]
      }
    ]
  })

  tags = var.tags
}

# Attach bastion_ssm policy to EKSreadonly group
resource "aws_iam_group_policy_attachment" "eks_readonly_bastion_ssm_policy" {
  group      = aws_iam_group.eks_readonly.name
  policy_arn = aws_iam_policy.bastion_ssm.arn
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
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
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

# IAM Policy for Grafana CloudWatch access
resource "aws_iam_policy" "grafana_cloudwatch_policy" {
  name        = "GrafanaCloudWatchAccessPolicy"
  description = "Policy to allow Amazon Managed Grafana to read CloudWatch metrics and logs for EKS monitoring"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "tag:GetResources"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM Role for Grafana cross-account access
resource "aws_iam_role" "grafana_cloudwatch_role" {
  name        = "GrafanaCloudWatchCrossAccountRole"
  description = "Cross-account role for Amazon Managed Grafana to access CloudWatch metrics and logs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.grafana_account_id}:role/IBoA_grafana"
        }
        Action    = "sts:AssumeRole"
        Condition = {}
      }


    ]
  })

  tags = merge(
    var.tags,
    {
      Name    = "GrafanaCloudWatchCrossAccountRole"
      Purpose = "Cross-account monitoring for Amazon Managed Grafana"
    }
  )
}

# Attach CloudWatch policy to Grafana role
resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_attachment" {
  policy_arn = aws_iam_policy.grafana_cloudwatch_policy.arn
  role       = aws_iam_role.grafana_cloudwatch_role.name
}

# IAM Policy for EKS Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "cluster_autoscaler"
  description = "Policy for EKS Cluster Autoscaler to manage Auto Scaling groups"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = ["*"]
      }
    ]
  })

  tags = var.tags
}

# IAM Role for EKS Cluster Autoscaler with OIDC trust relationship
resource "aws_iam_role" "cluster_autoscaler" {
  name        = "AmazonEKSClusterAutoscalerRole"
  description = "IAM role for EKS Cluster Autoscaler with IRSA"

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
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "AmazonEKSClusterAutoscalerRole"
    }
  )
}

# Attach Cluster Autoscaler policy to the role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attachment" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}

# IAM Policy for SES
resource "aws_iam_policy" "ses_custom" {
  name        = "ses_custom"
  description = "Policy to allow sending emails via AWS SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendRawEmail",
          "ses:SendEmail",
          "ses:SendTemplatedEmail",
          "ses:GetSendQuota"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM User for SES
resource "aws_iam_user" "ses_qa" {
  name = "ses_qa"

  tags = var.tags
}

# Access key for ses_qa user
resource "aws_iam_access_key" "ses_qa_access_key" {
  user = aws_iam_user.ses_qa.name
}

# IAM User for EKS API access
resource "aws_iam_user" "qasolvidevelopereks" {
  name = "qasolvidevelopereks"

  tags = var.tags
}

# Access key for qasolvidevelopereks user
resource "aws_iam_access_key" "qasolvidevelopereks_access_key" {
  user = aws_iam_user.qasolvidevelopereks.name
}

# Console login profile for qasolvidevelopereks user
resource "aws_iam_user_login_profile" "qasolvidevelopereks_login_profile" {
  user                    = aws_iam_user.qasolvidevelopereks.name
  password_length         = 20
  password_reset_required = true
}

# Add qasolvidevelopereks to the EKSreadonly IAM group
resource "aws_iam_user_group_membership" "qasolvidevelopereks_eks_readonly" {
  user = aws_iam_user.qasolvidevelopereks.name

  groups = [
    aws_iam_group.eks_readonly.name
  ]
}

# Attach ses_custom policy to ses_qa user
resource "aws_iam_user_policy_attachment" "ses_qa_ses_custom_attachment" {
  user       = aws_iam_user.ses_qa.name
  policy_arn = aws_iam_policy.ses_custom.arn
}

# Attach secret_readonly_irsa policy to ses_qa user
resource "aws_iam_user_policy_attachment" "ses_qa_secret_readonly_attachment" {
  user       = aws_iam_user.ses_qa.name
  policy_arn = aws_iam_policy.secret_readonly_irsa.arn
}

# IAM Policy for scoped read/write access to S3 customer documents folder
resource "aws_iam_policy" "s3_read_write_access" {
  name        = "s3_read_write_access"
  description = "Allows list/get/put/delete access only for qaiboadocuments/customer-documents"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::qaiboadocuments"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::qaiboadocuments/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::qaiboadocuments/customer-documents/*"
      }
    ]
  })

  tags = var.tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "s3_read_write_access_policy_attachment" {
  policy_arn = aws_iam_policy.s3_read_write_access.arn
  role       = aws_iam_role.solvi_irsa_role.name
}

# IAM Role for CEDE S3 access (assumed by s3_access_role from account 228886154405)
resource "aws_iam_role" "s3_access_role_cede" {
  name = "s3_access_role_cede"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::228886154405:role/cede-irsa-role"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach s3_read_write_access policy to s3_access_role_cede
resource "aws_iam_role_policy_attachment" "s3_access_role_cede_policy_attachment" {
  policy_arn = aws_iam_policy.s3_read_write_access.arn
  role       = aws_iam_role.s3_access_role_cede.name
}

# IAM Policy for AWS Load Balancer Controller
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for AWS Load Balancer Controller to manage ELB resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "ec2:GetSecurityGroupsForVpc",
          "ec2:DescribeIpamPools",
          "ec2:DescribeRouteTables",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTrustStores",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeCapacityReservation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSecurityGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = "arn:aws:ec2:*:*:security-group/*"
        Condition = {
          StringEquals = {
            "ec2:CreateAction" = "CreateSecurityGroup"
          }
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "arn:aws:ec2:*:*:security-group/*"
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]
        Condition = {
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster"  = "true"
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyListenerAttributes",
          "elasticloadbalancing:ModifyCapacityReservation",
          "elasticloadbalancing:ModifyIpPools"
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags"
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ]
        Condition = {
          StringEquals = {
            "elasticloadbalancing:CreateAction" = [
              "CreateTargetGroup",
              "CreateLoadBalancer"
            ]
          }
          Null = {
            "aws:RequestTag/elbv2.k8s.aws/cluster" = "false"
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ]
        Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:SetRulePriorities"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM Role for AWS Load Balancer Controller with OIDC trust relationship
resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "AmazonEKSLoadBalancerControllerRole"

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
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS Load Balancer Controller policy to the role
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attachment" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
  role       = aws_iam_role.aws_load_balancer_controller.name
}