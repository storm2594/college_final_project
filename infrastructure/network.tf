# Primary Network
resource "aws_vpc" "primary" {
  provider             = aws.primary
  cidr_block           = var.vpc_cidr_primary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.project_name}-primary-vpc" }
}

data "aws_availability_zones" "primary" {
  provider = aws.primary
  state    = "available"
}

resource "aws_subnet" "primary_public" {
  count                   = 2
  provider                = aws.primary
  vpc_id                  = aws_vpc.primary.id
  cidr_block              = cidrsubnet(var.vpc_cidr_primary, 8, count.index)
  availability_zone       = data.aws_availability_zones.primary.names[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-primary-public-${count.index + 1}" }
}

resource "aws_subnet" "primary_private" {
  count             = 2
  provider          = aws.primary
  vpc_id            = aws_vpc.primary.id
  cidr_block        = cidrsubnet(var.vpc_cidr_primary, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.primary.names[count.index]

  tags = { Name = "${var.project_name}-primary-private-${count.index + 1}" }
}

resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id
  tags     = { Name = "${var.project_name}-primary-igw" }
}

resource "aws_eip" "primary_nat" {
  provider = aws.primary
  domain   = "vpc"
}

resource "aws_nat_gateway" "primary_nat" {
  provider      = aws.primary
  allocation_id = aws_eip.primary_nat.id
  subnet_id     = aws_subnet.primary_public[0].id
  tags          = { Name = "${var.project_name}-primary-nat" }
  depends_on    = [aws_internet_gateway.primary_igw]
}

resource "aws_route_table" "primary_public" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }
  tags = { Name = "${var.project_name}-primary-public-rt" }
}

resource "aws_route_table_association" "primary_public_rta" {
  count          = 2
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_public[count.index].id
  route_table_id = aws_route_table.primary_public.id
}

resource "aws_route_table" "primary_private" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.primary_nat.id
  }
  tags = { Name = "${var.project_name}-primary-private-rt" }
}

resource "aws_route_table_association" "primary_private_rta" {
  count          = 2
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_private[count.index].id
  route_table_id = aws_route_table.primary_private.id
}

# Secondary Network
resource "aws_vpc" "secondary" {
  provider             = aws.secondary
  cidr_block           = var.vpc_cidr_secondary
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.project_name}-secondary-vpc" }
}

data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state    = "available"
}

resource "aws_subnet" "secondary_public" {
  count                   = 2
  provider                = aws.secondary
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = cidrsubnet(var.vpc_cidr_secondary, 8, count.index)
  availability_zone       = data.aws_availability_zones.secondary.names[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-secondary-public-${count.index + 1}" }
}

resource "aws_subnet" "secondary_private" {
  count             = 2
  provider          = aws.secondary
  vpc_id            = aws_vpc.secondary.id
  cidr_block        = cidrsubnet(var.vpc_cidr_secondary, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.secondary.names[count.index]

  tags = { Name = "${var.project_name}-secondary-private-${count.index + 1}" }
}

resource "aws_internet_gateway" "secondary_igw" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id
  tags     = { Name = "${var.project_name}-secondary-igw" }
}

resource "aws_eip" "secondary_nat" {
  provider = aws.secondary
  domain   = "vpc"
}

resource "aws_nat_gateway" "secondary_nat" {
  provider      = aws.secondary
  allocation_id = aws_eip.secondary_nat.id
  subnet_id     = aws_subnet.secondary_public[0].id
  tags          = { Name = "${var.project_name}-secondary-nat" }
  depends_on    = [aws_internet_gateway.secondary_igw]
}

resource "aws_route_table" "secondary_public" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }
  tags = { Name = "${var.project_name}-secondary-public-rt" }
}

resource "aws_route_table_association" "secondary_public_rta" {
  count          = 2
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_public[count.index].id
  route_table_id = aws_route_table.secondary_public.id
}

resource "aws_route_table" "secondary_private" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.secondary_nat.id
  }
  tags = { Name = "${var.project_name}-secondary-private-rt" }
}

resource "aws_route_table_association" "secondary_private_rta" {
  count          = 2
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_private[count.index].id
  route_table_id = aws_route_table.secondary_private.id
}
