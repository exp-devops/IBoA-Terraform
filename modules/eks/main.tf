resource "aws_security_group" "eks_remote_access" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-remote-access-sg"
  description = "Security group for remote access to EKS nodes, whitelisting the default EKS cluster security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
    description     = "Allow all traffic from default EKS cluster security group"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-remote-access-sg"
    }
  )
}
##### Key pair generation for EKS nodes #####
resource "tls_private_key" "eks_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save EKS private key locally
resource "local_file" "eks_private_key" {
  content         = tls_private_key.eks_key.private_key_pem
  filename        = "${path.root}/keys/${var.project_name}-${var.project_segment}-${var.project_env}-eks-key.pem"
  file_permission = "0400" # Read-only for the current user
}

# Upload EKS public key to AWS EC2 Key Pair
resource "aws_key_pair" "eks_key_pair" {
  key_name   = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-key"
  public_key = tls_private_key.eks_key.public_key_openssh
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.project_segment}-${var.project_env}-cluster"
  version  = var.eksProperty["CLUSTER_VERSION"]
  role_arn = aws_iam_role.eks_cluster_role.arn

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  kubernetes_network_config {
    ip_family = "ipv4"
  }

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
    #security_group_ids      = [var.eks_cluster_sg_id]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
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

# Security group rule to allow bastion host access to EKS cluster on port 443
resource "aws_security_group_rule" "eks_cluster_from_bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.bastion_sg_id
  security_group_id        = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description              = "Allow HTTPS traffic from bastion host to EKS cluster"
}

# EKS Access Entry for IAM User
resource "aws_eks_access_policy_association" "devops_user" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::782683897710:user/devopsexperion"

  access_scope {
    type = "cluster"
  }
}

# EKS Access Entry for IAM User
resource "aws_eks_access_entry" "devops_user" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::782683897710:user/devopsexperion"
  type          = "STANDARD"
}

# EKS Add-ons
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  addon_version               = "v1.11.4-eksbuild.24" # Use appropriate version
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.20.4-eksbuild.1" # Use appropriate version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.32.6-eksbuild.12" # Use appropriate version
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.52.1-eksbuild.1"
  service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver_irsa
  ]
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = "v4.6.0-eksbuild.1" # Use appropriate version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
  #preserve                    = true
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
resource "aws_eks_node_group" "node_group_SOLVI" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.project_segment}-${var.project_env}-SOLVI"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [var.private_subnet_01]
  instance_types  = [var.eksProperty["NODE_INSTANCE_TYPE"]]
  disk_size       = tonumber(var.eksProperty["NODE_DISK_SIZE"])

  scaling_config {
    desired_size = tonumber(var.eksProperty["SOLVI_DESIRED_SIZE"])
    max_size     = tonumber(var.eksProperty["SOLVI_MAX_SIZE"])
    min_size     = tonumber(var.eksProperty["SOLVI_MIN_SIZE"])
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.eks_key_pair.key_name
    source_security_group_ids = [aws_security_group.eks_remote_access.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  labels = {
    NodeGroup   = "SOLVI"
    Environment = var.project_env
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-Solvi-NG"
    }
  )
}

resource "aws_eks_node_group" "node_group_FINERACT" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.project_segment}-${var.project_env}-FINERACT"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [var.private_subnet_02]
  instance_types  = [var.eksProperty["NODE_INSTANCE_TYPE"]]
  disk_size       = tonumber(var.eksProperty["NODE_DISK_SIZE"])

  scaling_config {
    desired_size = tonumber(var.eksProperty["FINERACT_DESIRED_SIZE"])
    max_size     = tonumber(var.eksProperty["FINERACT_MAX_SIZE"])
    min_size     = tonumber(var.eksProperty["FINERACT_MIN_SIZE"])
  }

  taint {
    key    = "dedicated"
    value  = "solvifineract"
    effect = "NO_SCHEDULE"
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.eks_key_pair.key_name
    source_security_group_ids = [aws_security_group.eks_remote_access.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  labels = {
    NodeGroup   = "FINERACT"
    Environment = var.project_env
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-Fineract-NG"
    }
  )
}