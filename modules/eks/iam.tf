# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-cluster-role"
    }
  )
}

# Attach required policies to cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# IAM Role for EKS Node Groups
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-node-role"
    }
  )
}

# Attach required policies to node role

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_patch_association" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_node_role.name
}

 resource "aws_iam_role_policy_attachment" "ebs_csi_driver_irsa" {
   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
   role       = aws_iam_role.eks_node_role.name
 }

# OIDC Provider for IRSA
data "tls_certificate" "eks_cluster_certificate" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_certificate.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-oidc-provider"
    }
  )
}

# IAM Role for EBS CSI Driver (IRSA)
# data "aws_iam_policy_document" "ebs_csi_driver_assume_role" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks_oidc_provider.arn]
#       type        = "Federated"
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud"
#       values   = ["sts.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "ebs_csi_driver" {
#   name               = "${var.project_name}-${var.project_segment}-${var.project_env}-ebs-csi-driver-role"
#   assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role.json

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.project_name}-${var.project_segment}-${var.project_env}-ebs-csi-driver-role"
#     }
#   )
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_irsa" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.ebs_csi_driver.name
# }
