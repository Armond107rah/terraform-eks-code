
resource "aws_eks_cluster" "learning" {
  count = var.enable_eks_cluster ? 1 : 0

  name     = "terraform-eks-learning"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_cluster_version

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"

    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true

    public_access_cidrs = [
      var.admin_public_cidr
    ]
  }

  tags = {
    Name        = "terraform-eks-learning"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]
}
