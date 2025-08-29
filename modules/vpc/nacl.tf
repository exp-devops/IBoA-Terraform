##### NACL #####

# Create a NACL for the VPC
resource "aws_network_acl" "tf_vpc_nacl" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = merge(
    local.common_tags, tomap({Name = "${var.project_name}-${var.project_segment}-${var.project_env}-nacl"})
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

# Allow all outbound traffic
resource "aws_network_acl_rule" "allow_all_outbound" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 100
  protocol       = "-1" # -1 represents all protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true # Set to true for outbound rule
}

######## Inbound Rules #######

##### HTTP & HTTPS #####
resource "aws_network_acl_rule" "allow_http" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 99
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  egress         = false
}

resource "aws_network_acl_rule" "allow_https" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 101
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  egress         = false
}

##### SSH #####
resource "aws_network_acl_rule" "allow_ssh1" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 50
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "3.7.243.85/32"
  from_port      = 22
  to_port        = 22
  egress         = false
}

resource "aws_network_acl_rule" "allow_ssh2" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 51
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "103.135.95.18/32"
  from_port      = 22
  to_port        = 22
  egress         = false
}

resource "aws_network_acl_rule" "allow_ssh3" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 52
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "103.141.54.138/32"
  from_port      = 22
  to_port        = 22
  egress         = false
}

resource "aws_network_acl_rule" "allow_ssh4" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 53
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "103.121.27.178/32"
  from_port      = 22
  to_port        = 22
  egress         = false
}

resource "aws_network_acl_rule" "allow_ssh5" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 55
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "103.79.223.18/32"
  from_port      = 22
  to_port        = 22
  egress         = false
}


##### custom Inbound #####
resource "aws_network_acl_rule" "allow_custom1" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 25
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = "1024"  #For SFTP/ECR
  to_port        = "65535" #For SFTP/ECR
  egress         = false
}

resource "aws_network_acl_rule" "allow_internal" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 26
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.network_cidr
  egress         = false
}

resource "aws_network_acl_rule" "allow_VPC_NAT" {
  network_acl_id = aws_network_acl.tf_vpc_nacl.id
  rule_number    = 27
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "13.43.231.220/32"
  egress         = false
}