resource "null_resource" "install_velero" {
  depends_on = [
    aws_eks_cluster.primary_cluster,
    aws_eks_node_group.primary_nodes,
    aws_eks_addon.primary_cluster_ebs_csi,
    aws_iam_role.eks_nodegroup_role,
    aws_iam_policy.velero_policy,
    aws_iam_role.velero_role,
    kubernetes_namespace.velero,
  kubernetes_service_account.velero_sa]

  triggers = {
    velero_version = "v1.8.0"
    bucket         = var.bucket_name
    region         = var.region
    account_id     = data.aws_caller_identity.current.account_id
  }

  provisioner "local-exec" {
    command = <<EOT
      velero install \
        --provider aws \
        --plugins velero/velero-plugin-for-aws:${self.triggers.velero_version} \
        --bucket ${self.triggers.bucket} \
        --backup-location-config region=${self.triggers.region} \
        --snapshot-location-config region=${self.triggers.region} \
        --pod-annotations iam.amazonaws.com/role=arn:aws:iam::${self.triggers.account_id}:role/velero-access-${var.region} \
        --no-secret
    EOT
  }
}
