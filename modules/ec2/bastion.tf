locals {
  bastion_common_tags = var.tags
}

##### Key pair generation #####
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.bastion_key.private_key_pem
  filename        = "${path.root}/keys/${var.project_name}-${var.project_segment}-${var.project_env}-bastion-key.pem"
  file_permission = "0400"  # Read-only for the current user
}

# Upload public key to AWS EC2 Key Pair
resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "${var.project_name}-${var.project_segment}-${var.project_env}-bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh

  tags = merge(local.bastion_common_tags, tomap({"Name": "${var.project_name}-${var.project_segment}-${var.project_env}-bastion-key"}))
}

########## EC2 ##########
resource "aws_instance" "bastion_ec2" {
  ami           = var.bastionEC2["ami"]
  instance_type = var.bastionEC2["instance_type"]
  subnet_id     = var.public_subnet_01
  key_name      = aws_key_pair.bastion_key_pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [var.bastion_sg_id]
  
  root_block_device {
    volume_size           = var.bastionEC2["volume_size"]
    volume_type           = var.bastionEC2["volume_type"]
    encrypted             = var.bastionEC2["encrypted"]
    kms_key_id            = var.kms_key  # KMS key ARN for encryption
    delete_on_termination = var.bastionEC2["delete_on_termination"]
    tags = merge(local.bastion_common_tags, tomap({"Name": "${var.project_name}-${var.project_segment}-${var.project_env}-bastion-root-volume"}))
  }
  
#   disable_api_termination = var.bastionEC2["disable_api_termination"]
  
#   user_data = base64encode(<<-EOF
#       #!/bin/bash
#       sudo apt update && sudo apt install -y fail2ban
#     EOF
#   )

  tags = merge(local.bastion_common_tags, tomap({"Name": "${var.project_name}-${var.project_segment}-${var.project_env}-bastion"}))
}

######### Elastic IP (EIP) ##########
resource "aws_eip" "bastion_ec2_eip" {
  domain     = "vpc"
  depends_on = [var.igw_id]

  tags = merge(local.bastion_common_tags, tomap({"Name": "${var.project_name}-${var.project_segment}-${var.project_env}-bastion-eip"}))
}

# Associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "bastion_ec2_eip_associate" {
  instance_id   = aws_instance.bastion_ec2.id
  allocation_id = aws_eip.bastion_ec2_eip.id
}
