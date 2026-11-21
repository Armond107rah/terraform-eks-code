
# IAM trust policy for the EKS control plane
data "aws_iam_policy_document" "eks_cluster_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# EKS cluster IAM role
resource "aws_iam_role" "eks_cluster" {
  name = "eks-learning-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume.json

  tags = {
    Project   = "terraform-eks-learning"
    ManagedBy = "Terraform"
  }
}

# Attach AWS managed policy
resource "aws_iam_role_policy_attachment" "eks_cluster" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM trust policy for EC2 worker nodes
data "aws_iam_policy_document" "eks_node_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role for EKS worker nodes
resource "aws_iam_role" "eks_nodes" {
  name = "eks-learning-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume.json

  tags = {
    Project   = "terraform-eks-learning"
    ManagedBy = "Terraform"
  }
}

# Worker node permissions
resource "aws_iam_role_policy_attachment" "eks_worker" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Read-only image-pull access to ECR
resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

# Temporary lab permissions for VPC CNI
resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
