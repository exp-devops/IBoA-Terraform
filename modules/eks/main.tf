# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.project_segment}-${var.project_env}-cluster"
  version  = var.eksProperty["CLUSTER_VERSION"]
  role_arn = aws_iam_role.eks_cluster_role.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  vpc_config {
    subnet_ids              = [var.private_subnet_01, var.private_subnet_02]
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [var.eks_cluster_sg_id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-cluster"
    }
  )
}

/*# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-cluster-sg"
    }
  )
}*/

# EKS Node Groups
resource "aws_eks_node_group" "node_group_1" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.project_segment}-${var.project_env}-palmsNG-1"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [var.private_subnet_01]
  instance_types  = [var.eksProperty["NODE_INSTANCE_TYPE"]]
  disk_size       = tonumber(var.eksProperty["NODE_DISK_SIZE"])

  scaling_config {
    desired_size = tonumber(var.eksProperty["NG1_DESIRED_SIZE"])
    max_size     = tonumber(var.eksProperty["NG1_MAX_SIZE"])
    min_size     = tonumber(var.eksProperty["NG1_MIN_SIZE"])
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  labels = {
    NodeGroup = "group1"
    Environment = var.project_env
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-palmsNG-1"
    }
  )
}

resource "aws_eks_node_group" "node_group_2" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.project_segment}-${var.project_env}-fineractNG-2"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [var.private_subnet_02]
  instance_types  = [var.eksProperty["NODE_INSTANCE_TYPE"]]
  disk_size       = tonumber(var.eksProperty["NODE_DISK_SIZE"])

  scaling_config {
    desired_size = tonumber(var.eksProperty["NG2_DESIRED_SIZE"])
    max_size     = tonumber(var.eksProperty["NG2_MAX_SIZE"])
    min_size     = tonumber(var.eksProperty["NG2_MIN_SIZE"])
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-fineractNG-2"
    }
  )
}
