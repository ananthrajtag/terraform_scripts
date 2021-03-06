provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

}

resource "aws_vpc" "vpc" {

  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.stack_name}-vpc"
  }
}


resource "aws_subnet" "private_subnet_1" {

  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet("${var.vpc_cidr_block}", 8, 0)}"
  availability_zone = "${var.availability_zones[var.aws_region][0]}"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "${var.stack_name}-private-subnet-${var.availability_zones[var.aws_region][0]}"
  }
}

resource "aws_subnet" "private_subnet_2" {

  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet("${var.vpc_cidr_block}", 8, 1)}"
  availability_zone = "${var.availability_zones[var.aws_region][1]}"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "${var.stack_name}-private-subnet-${var.availability_zones[var.aws_region][1]}"
  }
}

resource "aws_subnet" "public_subnet_1" {

  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet("${var.vpc_cidr_block}", 8, 2)}"
  availability_zone = "${var.availability_zones[var.aws_region][0]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.stack_name}-public-subnet-${var.availability_zones[var.aws_region][0]}"
  }
}

resource "aws_subnet" "public_subnet_2" {

  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet("${var.vpc_cidr_block}", 8, 3)}"
  availability_zone = "${var.availability_zones[var.aws_region][1]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.stack_name}-public-subnet-${var.availability_zones[var.aws_region][1]}"
  }
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${var.stack_name}-internet-gateway"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = "${aws_subnet.public_subnet_1.id}"
  allocation_id = "${aws_eip.nat_gateway_eip.id}"
  tags = {
    Name = "${var.stack_name}-nat-gateway"
  }
}

resource "aws_eip" "nat_gateway_eip" {
  vpc      = true
}


resource "aws_route_table" "public_route_table" {

  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags = {
    Name = "${var.stack_name}-public-route-table"
  }

}

resource "aws_route_table" "private_route_table" {

  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat_gateway.id}"
  }

  tags = {
    Name = "${var.stack_name}-private-route-table"
  }

}

resource "aws_route_table_association" "public_route_table_association_1" {

  subnet_id = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_route_table_association_2" {

  subnet_id = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "private_route_table_association_1" {

  subnet_id = "${aws_subnet.private_subnet_1.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"

}

resource "aws_route_table_association" "private_route_table_association_2" {

  subnet_id = "${aws_subnet.private_subnet_2.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"

}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

