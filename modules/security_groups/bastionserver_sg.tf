locals {
  bastion_sg_common_tags = var.tags
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id
  name   = "${var.project_name}-${var.project_segment}-${var.project_env}-bastion-sg"

  dynamic "ingress" {
    for_each = var.bastion_ssh_allowed_ips
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.key]  # Use the current IP from the map
      description = ingress.value  # Use the description from the map
    }
  } 
  
  dynamic "egress" {
    for_each = var.bastion_ssh_allowed_ips
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [egress.key]
      description = "Allow all outbound to ${egress.value}"
    }
  }

  tags = merge(local.bastion_sg_common_tags, tomap({
    Name = "${var.project_name}-${var.project_segment}-${var.project_env}}-bastion-sg"
  }))
}