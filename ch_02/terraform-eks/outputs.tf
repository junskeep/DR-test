# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint_primary" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.primary_cluster.endpoint
}


output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name_primary" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.primary_cluster.name
}

output "cluster_endpoint_recovery" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.recovery_cluster.endpoint
}



output "cluster_name_recovery" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.primary_cluster.name
}
