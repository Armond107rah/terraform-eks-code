
# Preparatory internal security group
resource "aws_security_group" "eks_internal" {
  name_prefix = "eks-learning-internal-"
  description = "Internal communication for future EKS workloads"
  vpc_id      = aws_vpc.eks_lab_vpc.id

  tags = {
    Name      = "eks-learning-internal-sg"
    Project   = "terraform-eks-learning"
    ManagedBy = "Terraform"
  }
}

# Allow communication among resources
# attached to this same security group
resource "aws_vpc_security_group_ingress_rule" "internal_self" {
  security_group_id            = aws_security_group.eks_internal.id
  referenced_security_group_id = aws_security_group.eks_internal.id

  ip_protocol = "-1"

  description = "Allow internal group-to-group communication"
}

# Allow outbound communication inside our VPC
resource "aws_vpc_security_group_egress_rule" "internal_vpc" {
  security_group_id = aws_security_group.eks_internal.id

  cidr_ipv4   = "10.50.0.0/16"
  ip_protocol = "-1"

  description = "Allow outbound traffic within the VPC"
}
