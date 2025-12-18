# Routes for VPC Peering Connection

# Route from EKS public subnets to Jenkins VPC
resource "aws_route" "public_to_jenkins" {
  count = var.vpc_peering_connection_id != "" ? 1 : 0

  route_table_id            = var.public_route_table_id
  destination_cidr_block    = var.jenkins_vpc_cidr
  vpc_peering_connection_id = var.vpc_peering_connection_id

  depends_on = [aws_vpc_peering_connection_accepter.jenkins_peering]
}

# Route from EKS private subnets to Jenkins VPC
resource "aws_route" "private_to_jenkins" {
  count = var.vpc_peering_connection_id != "" ? 1 : 0

  route_table_id            = var.private_route_table_id
  destination_cidr_block    = var.jenkins_vpc_cidr
  vpc_peering_connection_id = var.vpc_peering_connection_id

  depends_on = [aws_vpc_peering_connection_accepter.jenkins_peering]
}
