# Define VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${local.environment}: VPC"
  }
}

# Define primary subnet for DB
resource "aws_subnet" "db_subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = var.db_subnet_cidr
  availability_zone = var.aws_az_01

  tags = {
    Name = "${local.environment}: primary db subnet"
  }
}

# Define backup subnet for DB
resource "aws_subnet" "db_subnet_backup" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = var.db_backup_subnet_cidr
  availability_zone = var.aws_az_02

  tags = {
    Name = "${local.environment}: backup db subnet"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.environment}: internet gateway"
  }
}

# Define the route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${local.environment}: route table"
  }
}

# would be better to have a loop for subnets in different AZ's
# maybe when i get better at terraform we can do that
resource "aws_subnet" "subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = var.subnet_cidr
  availability_zone = var.aws_az_01

  tags = {
    Name = "${local.environment}: primary app subnet"
  }
}

resource "aws_subnet" "backup" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = var.backup_cidr
  availability_zone = var.aws_az_02

  tags = {
    Name = "${local.environment}: backup"
  }
}

# it would be better to apply these in a loop
# maybe when i get better at terraform we can do that
resource "aws_route_table_association" "subnet_route_table_association" {
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_route_table_association" "backup_route_table_association" {
  subnet_id      = "${aws_subnet.backup.id}"
  route_table_id = "${aws_route_table.route_table.id}"
}
