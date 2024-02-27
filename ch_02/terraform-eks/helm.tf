# Datasource: EKS Cluster Auth
data "aws_eks_cluster_auth" "primary_cluster" {
  name = local.cluster_name_primary
}
data "aws_eks_cluster_auth" "recovery_cluster" {
  name = local.cluster_name_recovery
}
# HELM Provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }

}
#resource "helm_release" "ebs_csi_driver" {
#  depends_on = [aws_iam_role.ebs_csi_iam_role]
#  name       = "${local.name}-aws-ebs-csi-driver"
#  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#  chart      = "aws-ebs-csi-driver"
#  namespace  = "kube-system"
#
#  set {
#    name  = "image.repository"
#    value = "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com/eks/aws-ebs-csi-driver" # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
#  }
#
#  set {
#    name  = "controller.serviceAccount.create"
#    value = "true"
#  }
#
#  set {
#    name  = "controller.serviceAccount.name"
#    value = "ebs-csi-controller-sa"
#  }
#
#  set {
#    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#    value = aws_iam_role.ebs_csi_iam_role.arn
#  }
#
#}
#
## EBS CSI Helm Release Outputs
#output "ebs_csi_helm_metadata" {
#  description = "Metadata Block outlining status of the deployed release."
#  value       = helm_release.ebs_csi_driver.metadata
#}