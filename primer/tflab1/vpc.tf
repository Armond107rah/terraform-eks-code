
resource "aws_vpc" "eks_lab_vpc" {
  cidr_block           = "10.50.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name        = "terraform-eks-learning-vpc"
    Environment = "lab"
    Project     = "terraform-eks-code"
    ManagedBy   = "Terraform"
  }
}
