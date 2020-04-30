locals {
  azs = ["ap-northeast-1a", "ap-northeast-1c"]
}

resource "aws_vpc" "daylight" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "daylight-vpc"
  }
}

resource "aws_internet_gateway" "daylight" {
  vpc_id = aws_vpc.daylight.id

  tags = {
    Name = "daylight-igw"
  }
}

resource "aws_subnet" "daylight_public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.daylight.id
  cidr_block              = format("10.0.%d.0/24", count.index + 1)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = "true"

  tags = {
    Name = format("daylight-public-%d", local.azs[count.index])
  }
}

resource "aws_route_table" "daylight_public_to_igw" {
  vpc_id = aws_vpc.daylight.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.daylight.id
  }

  tags = {
    Name = "daylight-public-to-igw"
  }
}

resource "aws_route_table_association" "daylight_public" {
  count          = length(local.azs)
  subnet_id      = element(aws_subnet.daylight_public.*.id, count.index)
  route_table_id = aws_route_table.daylight_public_to_igw.id
}
