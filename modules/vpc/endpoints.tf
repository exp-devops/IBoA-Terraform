# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.tf_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  
  tags = merge(
    local.common_tags, 
    tomap({
      Name = "${var.project_name}-${var.project_segment}-${var.project_env}-s3-endpoint"
    })
  )

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-${var.project_segment}-${var.project_env}-iboadocuments",
          "arn:aws:s3:::${var.project_name}-${var.project_segment}-${var.project_env}-iboadocuments/*"
        ]
      }
    ]
  })
}

# Associate VPC endpoint with private route table
resource "aws_vpc_endpoint_route_table_association" "private_s3_endpoint" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id = aws_route_table.tf_private_rt.id
}