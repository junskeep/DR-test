# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#output "cluster_endpoint_primary" {
#  description = "Endpoint for EKS control plane"
#  value       = aws_eks_cluster.primary_cluster.endpoint
#}


output "region" {
  description = "AWS region"
  value       = var.region
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = var.bucket_name
}

output "cluster_name_primary" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.primary_cluster.name
}

