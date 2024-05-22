# Datasource: EKS Cluster Auth
data "aws_eks_cluster_auth" "primary_cluster" {
  name = local.cluster_name_primary
}
# HELM Provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }

}