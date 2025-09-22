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

  # RabbitMQ management console
  ingress {
    from_port       = 15672
    to_port         = 15672
    protocol        = "tcp"
  security_groups = [var.bastion_sg_id]
    description     = "Allow management console access from Bastion host"
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
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-sg"
    }
  )
}
