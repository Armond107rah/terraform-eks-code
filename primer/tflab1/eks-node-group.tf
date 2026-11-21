
# Managed EC2 worker nodes for Amazon EKS
resource "aws_eks_node_group" "learning" {
  count = var.enable_eks_nodes ? 1 : 0

  cluster_name  = aws_eks_cluster.learning[0].name
  node_role_arn = aws_iam_role.eks_nodes.arn

  node_group_name = "eks-learning-workers"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  instance_types = [
    var.eks_node_instance_type
  ]

  ami_type      = "AL2023_x86_64_STANDARD"
  capacity_type = "ON_DEMAND"
  disk_size     = 20

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name        = "eks-learning-workers"
    Environment = "lab"
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker,
    aws_iam_role_policy_attachment.ecr_pull,
    aws_iam_role_policy_attachment.eks_cni,
    aws_route.private_a_nat,
    aws_route.private_b_nat
  ]

  lifecycle {
    precondition {
      condition = (
        var.enable_eks_cluster &&
        var.enable_nat_gateway
      )

      error_message = "EKS nodes require the cluster and NAT gateway to be enabled."
    }
  }
}
