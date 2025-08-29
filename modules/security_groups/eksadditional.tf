# Additional EKS Security Group (for worker nodes and other resources)
resource "aws_security_group" "eks_additional_sg" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-additional-sg"
  description = "Additional security group for EKS worker nodes and related resources"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-additional-sg"
    }
  )
}

# Allow all traffic between resources in this security group
resource "aws_security_group_rule" "additional_self_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_additional_sg.id
  security_group_id        = aws_security_group.eks_additional_sg.id
  description              = "Allow all internal traffic"
}

# Allow all outbound traffic
resource "aws_security_group_rule" "additional_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_additional_sg.id
}

# Allow all traffic from cluster security group
resource "aws_security_group_rule" "additional_inbound_cluster_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_additional_sg.id
  description              = "Allow all traffic from cluster security group"
}
