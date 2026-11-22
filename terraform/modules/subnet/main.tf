resource "aws_subnet" "this" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr
  availability_zone       = var.az
  map_public_ip_on_launch = var.public

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "public" {
  count          = var.public ? 1 : 0
  subnet_id      = aws_subnet.this.id
  route_table_id = var.public_route_table_id
}
