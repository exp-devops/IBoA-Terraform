locals {
  rabbitmq_common_tags = var.tags
}

# IAM Role for RabbitMQ EC2 Instance
resource "aws_iam_role" "rabbitmq_role" {
  name = "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.rabbitmq_common_tags, tomap({
    Name = "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-role"
  }))
}

# Attach AmazonSSMManagedInstanceCore policy to rabbitmq role
resource "aws_iam_role_policy_attachment" "rabbitmq_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.rabbitmq_role.name
}

# IAM Instance Profile for RabbitMQ
resource "aws_iam_instance_profile" "rabbitmq_profile" {
  name = "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-profile"
  role = aws_iam_role.rabbitmq_role.name

  tags = merge(local.rabbitmq_common_tags, tomap({
    Name = "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-profile"
  }))
}

##### Key pair generation #####
resource "tls_private_key" "rabbitmq_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "rabbitmqprivate_key" {
  content         = tls_private_key.rabbitmq_key.private_key_pem
  filename        = "${path.root}/keys/${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-key.pem"
  file_permission = "0400" # Read-only for the current user
}

# Upload public key to AWS EC2 Key Pair
resource "aws_key_pair" "rabbitmq_key_pair" {
  key_name   = "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-key"
  public_key = tls_private_key.rabbitmq_key.public_key_openssh

  tags = merge(local.rabbitmq_common_tags, tomap({ "Name" : "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-key" }))
}

########## EC2 ##########
resource "aws_instance" "rabbitmq_ec2" {
  ami                         = var.rabbitmqEC2["ami"]
  instance_type               = var.rabbitmqEC2["instance_type"]
  subnet_id                   = var.private_subnet_01
  key_name                    = aws_key_pair.rabbitmq_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.rabbitmq.id]
  iam_instance_profile        = aws_iam_instance_profile.rabbitmq_profile.name

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  root_block_device {
    volume_size           = var.rabbitmqEC2["volume_size"]
    volume_type           = var.rabbitmqEC2["volume_type"]
    encrypted             = true
    kms_key_id            = var.kms_key # KMS key ARN for encryption
    delete_on_termination = var.rabbitmqEC2["delete_on_termination"]
    tags                  = merge(local.rabbitmq_common_tags, tomap({ "Name" : "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-root-volume" }))
  }

  #   disable_api_termination = var.rabbitmqEC2["disable_api_termination"]

  #   user_data = base64encode(<<-EOF
  #       #!/bin/bash
  #       sudo apt update && sudo apt install -y fail2ban
  #     EOF
  #   )

  tags = merge(local.rabbitmq_common_tags, tomap({ "Name" : "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq" }))
}

######### Elastic IP (EIP) ##########
resource "aws_eip" "rabbitmq_ec2_eip" {
  domain     = "vpc"
  depends_on = [var.igw_id]

  tags = merge(local.rabbitmq_common_tags, tomap({ "Name" : "${var.project_name}-${var.project_segment}-${var.project_env}-rabbitmq-eip" }))
}

# Associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "rabbitmq_ec2_eip_associate" {
  instance_id   = aws_instance.rabbitmq_ec2.id
  allocation_id = aws_eip.rabbitmq_ec2_eip.id
}
