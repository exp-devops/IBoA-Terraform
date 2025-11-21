
# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.tf_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:*"]
        Resource  = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-s3-endpoint"
    }
  )
}

/*# EC2 Interface Endpoint
resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.tf_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.tf_subnet_private_01.id, aws_subnet.tf_subnet_private_02.id]
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-ec2-endpoint"
    }
  )
}

# ECR API Interface Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.tf_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.tf_subnet_private_01.id, aws_subnet.tf_subnet_private_02.id]
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-ecr-api-endpoint"
    }
  )
}

# ECR DKR Interface Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.tf_vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.tf_subnet_private_01.id, aws_subnet.tf_subnet_private_02.id]
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-ecr-dkr-endpoint"
    }
  )
}*/

# Associate S3 endpoint with private route table
resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.tf_private_rt.id
}
# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.project_name}-${var.project_segment}-${var.project_env}-vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.network_cidr]
    description = "Allow HTTPS from VPC CIDR"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.network_cidr]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-vpc-endpoint-sg"
    }
  )
}