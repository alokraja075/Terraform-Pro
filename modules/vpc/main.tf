data "aws_availability_zones" "available" {}

locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.available.names

  public_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [for idx, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, idx)]

  private_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [for idx, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, idx + length(local.azs))]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({ Name = var.name }, var.tags)
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ Name = "${var.name}-igw" }, var.tags)
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidrs[tonumber(each.key)]
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = merge({ Name = "${var.name}-public-${each.key}" }, var.tags)
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidrs[tonumber(each.key)]
  availability_zone = each.value

  tags = merge({ Name = "${var.name}-private-${each.key}" }, var.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ Name = "${var.name}-public-rt" }, var.tags)
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = var.enable_nat ? length(local.azs) : 0

  vpc = true
  tags = merge({ Name = "${var.name}-nat-eip-${count.index}" }, var.tags)
}

resource "aws_nat_gateway" "nat" {
  count = var.enable_nat ? length(local.azs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge({ Name = "${var.name}-nat-${count.index}" }, var.tags)
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id
  tags   = merge({ Name = "${var.name}-private-rt-${each.key}" }, var.tags)
}

resource "aws_route" "private_nat" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.enable_nat ? aws_nat_gateway.nat[tonumber(each.key)].id : null
  depends_on = var.enable_nat ? [aws_nat_gateway.nat] : []
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
