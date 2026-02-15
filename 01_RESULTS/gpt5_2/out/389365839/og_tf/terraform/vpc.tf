data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.128.0.0/16"
}

resource "aws_subnet" "public" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.ecs_vpc.cidr_block, 8, 2 + count.index)
  vpc_id            = aws_vpc.ecs_vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  # instances launched in subnet get assigned a public IP
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.ecs_vpc.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.ecs_vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
}

resource "aws_internet_gateway" "gw" {
  depends_on = [aws_vpc.ecs_vpc]

  vpc_id = aws_vpc.ecs_vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.ecs_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_eip" "gateway" {
  count      = 2
  depends_on = [aws_internet_gateway.gw]
  vpc        = true
}

resource "aws_nat_gateway" "ecs_nat" {
  count         = 2
  allocation_id = element(aws_eip.gateway.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.ecs_nat.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}