# Elastic IP for our optional public NAT gateway
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name        = "eks-learning-nat-eip"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

# Optional public NAT gateway
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name        = "eks-learning-nat"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_internet_gateway.eks_igw,
    aws_route_table_association.public_a
  ]
}
