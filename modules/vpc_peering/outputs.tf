output "vpc_peering_connection_id" {
  description = "VPC Peering Connection ID"
  value       = var.vpc_peering_connection_id != "" ? aws_vpc_peering_connection_accepter.jenkins_peering[0].id : null
}

output "vpc_peering_connection_status" {
  description = "VPC Peering Connection Status"
  value       = var.vpc_peering_connection_id != "" ? aws_vpc_peering_connection_accepter.jenkins_peering[0].accept_status : "Not configured"
}
