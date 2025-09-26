resource "aws_security_group" "rabbitmq" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-sg"
  description = "Security group for RabbitMQ server"
  vpc_id      = var.vpc_id

  # RabbitMQ AMQP port for EKS cluster
  ingress {
    from_port       = 5672
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
    description     = "Allow AMQP from EKS cluster"
  }

  # SSH access from Bastion host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
  security_groups = [var.bastion_sg_id]
    description     = "Allow SSH from Bastion host"
  }

  # RabbitMQ management console - Dynamic IP allowlist
  dynamic "ingress" {
    for_each = var.bastion_ssh_allowed_ips
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.key]  # Use the current IP from the map
      description = "Allow management console access from ${ingress.value}"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [var.eks_cluster_security_group_id]
    description     = "Allow all outbound to EKS Cluster SG"
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.fineract_rds_sg_id]
    description     = "Allow MySQL traffic to Fineract RDS"
  }

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.palms_rds_sg_id]
    description     = "Allow PostgreSQL traffic to PALMS RDS"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-sg"
    }
  )
}
