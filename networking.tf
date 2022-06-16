##############################################
# VPC and network within VPC
##############################################
# creating a vpc
resource "aws_vpc" "aws-vpc" {
  cidr_block           = "172.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

# creating internet gateway
resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }

}

# Creating private subnet within two availability zone
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.aws-vpc.id
  count             = local.az-count
  cidr_block        = "172.0.${10+count.index}.0/24"
  availability_zone = data.aws_availability_zones.az-available.names[count.index]

  tags = {
    Name        = "${var.app_name}-private-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

# creating public subnet within two AZ
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = "172.0.${20+count.index}.0/24"
  availability_zone       = data.aws_availability_zones.az-available.names[count.index]
  count                   = local.az-count
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

# creating route table for public subnets
resource "aws_route_table" "public" {
  count          = local.az-count
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name        = "${var.app_name}-routing-table-public"
    Environment = var.app_environment
  }
}

# creating a route from public sub to IGW
resource "aws_route" "public" {
  count          = local.az-count
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws-igw.id
}

# associating router table with public subnet
resource "aws_route_table_association" "public" {
  count          = local.az-count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[count.index].id
}

# creating route table for private subnets
resource "aws_route_table" "private" {
  count          = local.az-count
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name        = "${var.app_name}-routing-table-private"
    Environment = var.app_environment
  }
}

# creating a route from public sub to IGW
resource "aws_route" "private" {
  count          = local.az-count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.gw[count.index].id
}

# associating router table with public subnet
resource "aws_route_table_association" "private" {
  count          = local.az-count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}

##########################################
# Nat gateway
#########################################
# create two natgateway for two subnet
resource "aws_nat_gateway" "gw" {
  count          = local.az-count
  allocation_id = aws_eip.eip-for-nat[count.index].id
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = {
    Name        = "${var.app_name}-gw"
    Environment = var.app_environment
  }
}

# elastic ip
# Create Elestic Ip for NAT within the AZ to be associated with NAT gateway
resource "aws_eip" "eip-for-nat" {
    count   = local.az-count
    vpc     = true
  
    tags = {
        Name        = "${var.app_name}-eip-for-nat"
        Environment = var.app_environment
    }

    depends_on = [
      aws_internet_gateway.aws-igw
    ]
}