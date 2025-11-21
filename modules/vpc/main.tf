# Declare the data source
data "aws_availability_zones" "tf_availability_zones" {
  state = "available"
}

locals {
  common_tags             = var.tags
  public_route_cidr_block = "0.0.0.0/0"
}

resource "aws_vpc" "tf_vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = var.network_cidr
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-vpc" })
  )
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-igw" })
  )
}

resource "aws_subnet" "tf_subnet_public_01" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = var.public_subnet_01_cidr
  availability_zone = data.aws_availability_zones.tf_availability_zones.names[0]
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-public-subnet-01" })
  )
}

resource "aws_subnet" "tf_subnet_public_02" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = var.public_subnet_02_cidr
  availability_zone = data.aws_availability_zones.tf_availability_zones.names[1]
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-public-subnet-02" })
  )
}

resource "aws_subnet" "tf_subnet_private_01" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = var.private_subnet_01_cidr
  availability_zone = data.aws_availability_zones.tf_availability_zones.names[0]
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-private-subnet-01" })
  )
}

resource "aws_subnet" "tf_subnet_private_02" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = var.private_subnet_02_cidr
  availability_zone = data.aws_availability_zones.tf_availability_zones.names[1]
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-private-subnet-02" })
  )
}

resource "aws_route_table" "tf_rtb_public" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block                = local.public_route_cidr_block
    egress_only_gateway_id    = null
    gateway_id                = aws_internet_gateway.tf_igw.id
    ipv6_cidr_block           = null
    nat_gateway_id            = null
    network_interface_id      = null
    transit_gateway_id        = null
    vpc_peering_connection_id = null
    local_gateway_id          = null
    vpc_endpoint_id           = null
  }

  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-public-rt1" })
  )
}

resource "aws_route_table_association" "tf_rta_subnet_public" {
  subnet_id      = aws_subnet.tf_subnet_public_01.id
  route_table_id = aws_route_table.tf_rtb_public.id
}

resource "aws_route_table_association" "tf_rta_subnet_public_02" {
  subnet_id      = aws_subnet.tf_subnet_public_02.id
  route_table_id = aws_route_table.tf_rtb_public.id
}

/**** private subnets */
/*resource "aws_subnet" "tf_subnet_private_01" {
  vpc_id                  = aws_vpc.tf_vpc.id
  map_public_ip_on_launch = false
  cidr_block              = var.subnet_cidr["SUBNET_03"]
  availability_zone       = data.aws_availability_zones.tf_availability_zones.names[0]
  tags = merge(
    local.common_tags, tomap({Name = "${var.project_name}-${var.project_segment}-${var.project_env}-private-subnet-01"})
  )
}

resource "aws_subnet" "tf_subnet_private_02" {
  vpc_id                  = aws_vpc.tf_vpc.id
  map_public_ip_on_launch = false
  cidr_block              = var.subnet_cidr["SUBNET_04"]
  availability_zone       = data.aws_availability_zones.tf_availability_zones.names[1]
  tags = merge(
    local.common_tags, tomap({Name = "${var.project_name}-${var.project_segment}-${var.project_env}-private-subnet-02"})
  )
}*/

resource "aws_route_table" "tf_private_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-private-rt1" })
  )
}

resource "aws_route_table_association" "tf_private1_rt_ass" {
  subnet_id      = aws_subnet.tf_subnet_private_01.id
  route_table_id = aws_route_table.tf_private_rt.id
}

resource "aws_route_table_association" "tf_private2_rt_ass" {
  subnet_id      = aws_subnet.tf_subnet_private_02.id
  route_table_id = aws_route_table.tf_private_rt.id
}

/* Elastic IP for NAT */
resource "aws_eip" "tf_nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.tf_igw]
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-natgw-eip" })
  )
}

/* NAT */
resource "aws_nat_gateway" "tf_nat" {
  allocation_id = aws_eip.tf_nat_eip.id
  subnet_id     = aws_subnet.tf_subnet_public_01.id
  depends_on    = [aws_internet_gateway.tf_igw]
  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-nat-gwid" })
  )
}


resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.tf_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tf_nat.id
}

###########################
###### VPC Flow Logs ######
###########################

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.iam_role_vpc.arn
  log_destination = aws_cloudwatch_log_group.cloudwatch_log_group_vpc.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.tf_vpc.id

}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_vpc" {
  name              = "${var.project_name}-${var.project_segment}-${var.project_env}-cloudwatch-log-group"
  retention_in_days = 90
  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-cloudwatch_log_group" })
  )
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_role_vpc" {
  name               = "${var.project_name}-${var.project_segment}-${var.project_env}-vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    local.common_tags, tomap({ Name = "${var.project_name}-${var.project_segment}-${var.project_env}-vpc-flow-logs-role" })
  )
}

data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "iam_role_policy_vpc" {
  role   = aws_iam_role.iam_role_vpc.id
  policy = data.aws_iam_policy_document.iam_policy_document.json
}