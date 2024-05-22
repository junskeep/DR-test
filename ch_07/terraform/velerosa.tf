provider "kubernetes" {
  host                   = aws_eks_cluster.primary_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.primary_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.primary_cluster.name]
    command     = "aws"
  }
}

resource "kubernetes_service_account" "velero_sa" {
  metadata {
    name      = "velero"
    namespace = "velero"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.velero_role.arn
    }
  }
}

resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.velero_role.arn
    }
  }
}