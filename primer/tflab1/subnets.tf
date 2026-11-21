
# Retrieve available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Public subnet in Availability Zone A
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.eks_lab_vpc.id
  cidr_block              = "10.50.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name                     = "eks-public-subnet-a"
    Tier                     = "public"
    "kubernetes.io/role/elb" = "1"
  }
}

# Public subnet in Availability Zone B
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.eks_lab_vpc.id
  cidr_block              = "10.50.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name                     = "eks-public-subnet-b"
    Tier                     = "public"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private subnet in Availability Zone A
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.eks_lab_vpc.id
  cidr_block              = "10.50.11.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name                              = "eks-private-subnet-a"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Private subnet in Availability Zone B
resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.eks_lab_vpc.id
  cidr_block              = "10.50.12.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name                              = "eks-private-subnet-b"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}
