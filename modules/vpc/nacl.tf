##### NACL #####

# Get S3 prefix list for the region
data "aws_prefix_list" "s3" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.${var.aws_region}.s3"]
  }
}

# Create a NACL for the VPC
resource "aws_network_acl" "tf_vpc_nacl" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-nacl" })
  )
}

# Associate NACL with public subnet 01
resource "aws_network_acl_association" "tf_nacl_association_public_01" {
  subnet_id      = aws_subnet.tf_subnet_public_01.id
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
}

# Associate NACL with public subnet 02
resource "aws_network_acl_association" "tf_nacl_association_public_02" {
  subnet_id      = aws_subnet.tf_subnet_public_02.id
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
}

# Associate NACL with private subnet 01
resource "aws_network_acl_association" "tf_nacl_association_private_01" {
  subnet_id      = aws_subnet.tf_subnet_private_01.id
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
}

# Associate NACL with private subnet 02
resource "aws_network_acl_association" "tf_nacl_association_private_02" {
  subnet_id      = aws_subnet.tf_subnet_private_02.id
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
}

######## Outbound Rules #######

# Allow HTTPS outbound to S3 prefix list (for EKS CNI plugin and container images)
resource "aws_network_acl_rule" "allow_https_s3_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 195
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = data.aws_prefix_list.s3.cidr_blocks[0]
  from_port      = 443
  to_port        = 443
  egress         = true
}

# Allow HTTP outbound
resource "aws_network_acl_rule" "allow_http_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 200
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  egress         = true
}

# Allow HTTPS outbound
resource "aws_network_acl_rule" "allow_https_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 210
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  egress         = true
}

# Allow MySQL outbound within VPC
resource "aws_network_acl_rule" "allow_mysql_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 220
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  from_port      = 3306
  to_port        = 3306
  egress         = true
}

# Allow PostgreSQL outbound within VPC
resource "aws_network_acl_rule" "allow_postgres_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 230
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  from_port      = 5432
  to_port        = 5432
  egress         = true
}

# Allow RabbitMQ AMQP outbound within VPC
resource "aws_network_acl_rule" "allow_rabbitmq_amqp_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 240
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  from_port      = 5672
  to_port        = 5672
  egress         = true
}

# Allow RabbitMQ Management Console outbound within VPC
resource "aws_network_acl_rule" "allow_rabbitmq_management_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 250
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  from_port      = 15672
  to_port        = 15672
  egress         = true
}

# Allow Ephemeral Ports outbound for return traffic
resource "aws_network_acl_rule" "allow_ephemeral_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 260
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  egress         = true
}

######## Inbound Rules #######

# Allow HTTP inbound
resource "aws_network_acl_rule" "allow_http" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow HTTPS inbound
resource "aws_network_acl_rule" "allow_https" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow SSH inbound from specific IPs
resource "aws_network_acl_rule" "allow_ssh1" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "3.7.243.85/32"
  from_port      = 22
  to_port        = 22
}

# Allow SSH inbound from another specific IP
resource "aws_network_acl_rule" "allow_ssh2" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 121
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "13.239.132.165/32"
  from_port      = 22
  to_port        = 22
}

# Allow MySQL inbound within VPC
resource "aws_network_acl_rule" "allow_mysql_inbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  from_port      = 3306
  to_port        = 3306
}

# Allow PostgreSQL inbound within VPC
resource "aws_network_acl_rule" "allow_postgres_inbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 140
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  from_port      = 5432
  to_port        = 5432
}

# Allow RabbitMQ AMQP inbound within VPC
resource "aws_network_acl_rule" "allow_rabbitmq_amqp_inbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 150
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  from_port      = 5672
  to_port        = 5672
}

# Allow RabbitMQ Management Console inbound within VPC
resource "aws_network_acl_rule" "allow_rabbitmq_management_inbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 160
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  from_port      = 15672
  to_port        = 15672
}

# Allow Ephemeral Ports inbound for return traffic
resource "aws_network_acl_rule" "allow_custom_ports" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 170
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow all internal VPC traffic
resource "aws_network_acl_rule" "allow_internal" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 180
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
}