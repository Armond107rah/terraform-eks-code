
output "public_subnet_ids" {
  description = "IDs of our public subnets"

  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "IDs of our private subnets"

  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "availability_zones" {
  description = "Availability Zones used by our subnets"

  value = [
    aws_subnet.public_a.availability_zone,
    aws_subnet.public_b.availability_zone
  ]
}

# Internet Gateway output
output "internet_gateway_id" {
  description = "ID of our VPC Internet Gateway"
  value       = aws_internet_gateway.eks_igw.id
}

# Public route table output
output "public_route_table_id" {
  description = "ID of our public route table"
  value       = aws_route_table.public.id
}

# Private route table outputs
output "private_route_table_ids" {
  description = "IDs of the private route tables"

  value = [
    aws_route_table.private_a.id,
    aws_route_table.private_b.id
  ]
}

output "nat_gateway_id" {
  description = "ID of the optional NAT gateway"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "eks_cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  value       = aws_iam_role.eks_nodes.arn
}

output "eks_internal_security_group_id" {
  description = "ID of our internal EKS security group"
  value       = aws_security_group.eks_internal.id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value = (
    var.enable_eks_cluster
    ? aws_eks_cluster.learning[0].name
    : null
  )
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value = (
    var.enable_eks_cluster
    ? aws_eks_cluster.learning[0].endpoint
    : null
  )
}

output "eks_cluster_version" {
  description = "EKS Kubernetes version"
  value = (
    var.enable_eks_cluster
    ? aws_eks_cluster.learning[0].version
    : null
  )
}

output "eks_node_group_name" {
  description = "Name of the managed EKS node group"

  value = (
    var.enable_eks_nodes
    ? aws_eks_node_group.learning[0].node_group_name
    : null
  )
}

output "eks_node_group_status" {
  description = "Status of the managed EKS node group"

  value = (
    var.enable_eks_nodes
    ? aws_eks_node_group.learning[0].status
    : null
  )
}
