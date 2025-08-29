locals {
  palms_rds_sg_common_tags = var.tags
}

resource "aws_security_group" "palms_rds_sg" {
  vpc_id = var.vpc_id
  name   = "${var.project_name}-${var.project_segment}-${var.project_env}-palms-rds-sg"

  dynamic "ingress" {
    for_each = var.palms_rds_allowed_ips
    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [ingress.key]  # Use the current IP from the map
      description = ingress.value  # Use the description from the map
    }
  } 

  ingress {
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [var.bastion_sg_id]
  description     = "Allow Postgres from Bastion SG"
}

ingress {
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [aws_security_group.eks_cluster_sg.id]
  description     = "Allow Postgres from EKS Cluster"
}
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.palms_rds_sg_common_tags, tomap({
    Name = "${var.project_name}-${var.project_segment}-${var.project_env}-palms-rds-sg"
  }))
}