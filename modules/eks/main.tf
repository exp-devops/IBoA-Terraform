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
  filename        = "${path.root}/pem/${var.project_name}-${var.project_segment}-${var.project_env}-eks-key.pem"
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

# Security group rule to allow Jenkins VPC CIDR access to EKS cluster on port 443
resource "aws_security_group_rule" "eks_cluster_from_jenkins" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.jenkins_vpc_cidr]
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description       = "Allow HTTPS traffic from Jenkins VPC to EKS cluster API"
}

# EKS Access Entry for IAM User
resource "aws_eks_access_policy_association" "devops_user" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::507217480696:user/devopsexperionsolviqa"

  access_scope {
    type = "cluster"
  }
}

# EKS Access Entry for IAM User
resource "aws_eks_access_entry" "devops_user" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::507217480696:user/devopsexperionsolviqa"
  type          = "STANDARD"
}

# Additional EKS access entry for qasolvidevelopereks IAM user
resource "aws_eks_access_entry" "qasolvidevelopereks_user" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::507217480696:user/qasolvidevelopereks"
  type          = "STANDARD"
}

# Additional EKS access policy association for qasolvidevelopereks IAM user
resource "aws_eks_access_policy_association" "qasolvidevelopereks_user" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"
  principal_arn = "arn:aws:iam::507217480696:user/qasolvidevelopereks"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.qasolvidevelopereks_user]
}

# EKS Access Entry for EKS Deployment Role
resource "aws_eks_access_entry" "eks_deployment_role" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.eks_deployment_role_arn
  type          = "STANDARD"
}

# EKS Access Policy Association for EKS Deployment Role
resource "aws_eks_access_policy_association" "eks_deployment_role" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  principal_arn = var.eks_deployment_role_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.eks_deployment_role]
}

# EKS Add-ons
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "coredns"
  addon_version               = "v1.13.1-eksbuild.1" # Use appropriate version
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.21.1-eksbuild.1" # Use appropriate version
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.35.0-eksbuild.2" # Use appropriate version
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "node_monitoring_agent" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "eks-node-monitoring-agent"
  addon_version               = "v1.5.2-eksbuild.1" # Use appropriate version
  resolve_conflicts_on_update = "OVERWRITE"
}

# resource "aws_eks_addon" "aws_ebs_csi_driver" {
#   cluster_name                = aws_eks_cluster.main.name
#   addon_name                  = "aws-ebs-csi-driver"
#   addon_version               = "v1.52.1-eksbuild.1"
#   service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
#   resolve_conflicts_on_update = "OVERWRITE"
#   resolve_conflicts_on_create = "OVERWRITE"

#   depends_on = [
#     aws_iam_role_policy_attachment.ebs_csi_driver_irsa
#   ]
# }

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = "v6.2.0-eksbuild.1" # Use appropriate version
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

resource "aws_launch_template" "eks_node_group" {
  name_prefix = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-ng-"
  key_name    = aws_key_pair.eks_key_pair.key_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = tonumber(var.eksProperty["NODE_DISK_SIZE"])
      volume_type = "gp3"
      encrypted   = true
      kms_key_id  = var.kms_key_arn
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-node-volume"
      }
    )
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-ng-lt"
    }
  )
}

resource "aws_eks_node_group" "node_group_SOLVI_general" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.project_segment}-${var.project_env}-SOLVI-general"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [var.private_subnet_01, var.private_subnet_02]
  instance_types  = [var.eksProperty["NODE_INSTANCE_TYPE"]]

  launch_template {
    id      = aws_launch_template.eks_node_group.id
    version = aws_launch_template.eks_node_group.latest_version
  }

  scaling_config {
    desired_size = tonumber(var.eksProperty["SOLVIGENERAL_DESIRED_SIZE"])
    max_size     = tonumber(var.eksProperty["SOLVIGENERAL_MAX_SIZE"])
    min_size     = tonumber(var.eksProperty["SOLVIGENERAL_MIN_SIZE"])
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  labels = {
    dedicated   = "general"
    Environment = var.project_env
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-Solvi-General-NG"
    }
  )
}

resource "aws_eks_node_group" "node_group_SOLVI_dedicated" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.project_segment}-${var.project_env}-SOLVI-dedicated"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [var.private_subnet_01, var.private_subnet_02]
  instance_types  = [var.eksProperty["NODE_INSTANCE_TYPE"]]

  launch_template {
    id      = aws_launch_template.eks_node_group.id
    version = aws_launch_template.eks_node_group.latest_version
  }

  scaling_config {
    desired_size = tonumber(var.eksProperty["SOLVIDEDICATED_DESIRED_SIZE"])
    max_size     = tonumber(var.eksProperty["SOLVIDEDICATED_MAX_SIZE"])
    min_size     = tonumber(var.eksProperty["SOLVIDEDICATED_MIN_SIZE"])
  }

  taint {
    key    = "dedicated"
    value  = "highresource"
    effect = "NO_SCHEDULE"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  labels = {
    dedicated   = "highresource"
    Environment = var.project_env
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-Solvi-Dedicated-NG"
    }
  )
}

resource "aws_eks_node_group" "node_group_FINERACT" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.project_segment}-${var.project_env}-FINERACT"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [var.private_subnet_01, var.private_subnet_02]
  instance_types  = [var.eksProperty["NODE_INSTANCE_TYPE"]]

  launch_template {
    id      = aws_launch_template.eks_node_group.id
    version = aws_launch_template.eks_node_group.latest_version
  }

  scaling_config {
    desired_size = tonumber(var.eksProperty["FINERACT_DESIRED_SIZE"])
    max_size     = tonumber(var.eksProperty["FINERACT_MAX_SIZE"])
    min_size     = tonumber(var.eksProperty["FINERACT_MIN_SIZE"])
  }

  taint {
    key    = "dedicated"
    value  = "palmsfineract"
    effect = "NO_SCHEDULE"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  labels = {
    NodeGroup   = "FINERACT"
    dedicated = "palmsfineract"
    Environment = var.project_env
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-Fineract-NG"
    }
  )
}