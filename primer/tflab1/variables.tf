
variable "enable_nat_gateway" {
  description = "Whether to create a NAT gateway for private subnet outbound access"
  type        = bool
  default     = false
}

variable "enable_eks_cluster" {
  description = "Controls whether the EKS cluster is created"
  type        = bool
  default     = false
}

variable "eks_cluster_version" {
  description = "Kubernetes minor version for EKS"
  type        = string
  default     = "1.36"
}

variable "admin_public_cidr" {
  description = "Allowed public IPv4 CIDR for kubectl access"
  type        = string

  # Safe placeholder, not a working administrator IP
  default = "192.0.2.1/32"
}

variable "enable_eks_nodes" {
  description = "Controls creation of the managed EKS node group"
  type        = bool
  default     = false
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.medium"
}
