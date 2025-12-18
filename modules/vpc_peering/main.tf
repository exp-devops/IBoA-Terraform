# VPC Peering Connection - Cross Account
# This creates a peering connection from this account (accepter) to Jenkins account (requester)

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# VPC Peering Connection (Accepter side)
# Only creates when vpc_peering_connection_id is provided
resource "aws_vpc_peering_connection_accepter" "jenkins_peering" {
  count = var.vpc_peering_connection_id != "" ? 1 : 0

  vpc_peering_connection_id = var.vpc_peering_connection_id
  auto_accept               = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-jenkins-peering"
      Side = "Accepter"
    }
  )
}

# Note: The requester side (Jenkins account) needs to create the VPC peering connection request
# They need to run:
# aws ec2 create-vpc-peering-connection \
#   --vpc-id vpc-057dedf7580220880 \
#   --peer-vpc-id <YOUR_EKS_VPC_ID> \
#   --peer-owner-id <YOUR_ACCOUNT_ID> \
#   --peer-region ap-southeast-2 \
#   --region ap-southeast-2

# Or use Terraform in Jenkins account:
# resource "aws_vpc_peering_connection" "jenkins_to_eks" {
#   vpc_id        = "vpc-057dedf7580220880"
#   peer_vpc_id   = "<YOUR_EKS_VPC_ID>"
#   peer_owner_id = "<YOUR_ACCOUNT_ID>"
#   peer_region   = "ap-southeast-2"
#   
#   tags = {
#     Name = "jenkins-to-eks-peering"
#   }
# }
