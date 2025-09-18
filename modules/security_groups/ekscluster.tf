# EKS Cluster Security Group
/*resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-eks-cluster-sg"
    }
  )
}

resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster_sg.id
}

# Allow inbound traffic from additional security group
resource "aws_security_group_rule" "cluster_inbound_additional_sg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_additional_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
  description              = "Allow inbound traffic from additional security group"
}*/
