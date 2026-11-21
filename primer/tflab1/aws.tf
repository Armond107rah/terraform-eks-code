terraform {
  required_version = "> 1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # access_config on aws_eks_cluster requires 5.33.0 or newer
      version = ">= 5.33.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region                   = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}

variable "region" {
  description = "The name of the AWS Region"
  type        = string
  default     = "eu-west-1"
}


