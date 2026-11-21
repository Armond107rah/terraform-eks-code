
# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name        = "eks-public-route-table"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

# Associate public subnet A
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Associate public subnet B
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private route table for Availability Zone A
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.eks_lab_vpc.id

  tags = {
    Name        = "eks-private-route-table-a"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

# Private route table for Availability Zone B
resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.eks_lab_vpc.id

  tags = {
    Name        = "eks-private-route-table-b"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

# Associate private subnet A
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

# Associate private subnet B
resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

# Optional outbound route for private subnet A
resource "aws_route" "private_a_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}

# Optional outbound route for private subnet B
resource "aws_route" "private_b_nat" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[0].id
}
