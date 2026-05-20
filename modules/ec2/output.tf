# output "fileserver_ec2_public_ip" {
#   value = aws_instance.tf_fileserver_ec2.public_ip
# }

# View the private key (be cautious, as this is sensitive information)
output "bastionserver_private_key" {
  value       = tls_private_key.bastion_key.private_key_pem
  description = "The generated private key for the file server"
  sensitive   = true # Mark as sensitive to avoid it being displayed in logs
}

# View the public key
output "bastionserver_public_key" {
  value       = tls_private_key.bastion_key.public_key_openssh
  description = "The generated public key for the file server"
}

# # View the private key (be cautious, as this is sensitive information)
# output "rabbitmqserver_private_key" {
#   value       = tls_private_key.rabbitmq_key.private_key_pem
#   description = "The generated private key for the RabbitMQ server"
#   sensitive   = true # Mark as sensitive to avoid it being displayed in logs
# }

# View the public key
# output "rabbitmqserver_public_key" {
#   value       = tls_private_key.rabbitmq_key.public_key_openssh
#   description = "The generated public key for the RabbitMQ server"
# }

# Security Group Outputs
output "bastion_sg_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion_sg.id
}

# output "rabbitmq_sg_id" {
#   description = "ID of the RabbitMQ security group"
#   value       = aws_security_group.rabbitmq.id
# }