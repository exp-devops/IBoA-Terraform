locals {
  fineract_rds_sg_common_tags = var.tags
}

resource "aws_security_group" "fineract_rds_sg" {
  vpc_id = var.vpc_id
  name   = "${var.project_name}-${var.project_segment}-${var.project_env}-fineract-rds-sg"

  dynamic "ingress" {
    for_each = var.fineract_rds_allowed_ips
    content {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [ingress.key]
      description = ingress.value
    }
  } 

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
    description     = "Allow MySQL from Bastion SG"
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
    description     = "Allow MySQL from EKS Cluster"
  }
  
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.bastion_sg_id]
    description     = "Allow all outbound to Bastion SG"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.eks_cluster_security_group_id]
    description     = "Allow all outbound to EKS Cluster SG"
  }

  tags = merge(local.fineract_rds_sg_common_tags, tomap({
    Name = "${var.project_name}-${var.project_segment}-${var.project_env}-fineract-sg"
  }))
}