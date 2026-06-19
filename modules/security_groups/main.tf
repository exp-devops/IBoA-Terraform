# Security Group for ALB created by Kubernetes Ingress (AWS Load Balancer Controller)
# Attach this SG to the Ingress resource via annotation:
#   alb.ingress.kubernetes.io/security-groups: <ingress_alb_sg_id>

resource "aws_security_group" "ingress_alb_sg" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-ingress-alb-sg"
  description = "Security group for ALB created by Kubernetes Ingress"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from everywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from everywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-ingress-alb-sg"
    }
  )
}
