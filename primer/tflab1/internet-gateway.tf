
# Internet Gateway for our EKS learning VPC
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_lab_vpc.id

  tags = {
    Name        = "eks-learning-igw"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}
