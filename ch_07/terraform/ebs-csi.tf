data "http" "ebs_csi_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-ebs-csi-driver/master/docs/example-iam-policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_policy" "ebs_csi_iam_policy" {
  name        = "${local.name}-AmazonEKS_EBS_CSI_Driver_Policy"
  path        = "/"
  description = "EBS CSI IAM Policy"
  #policy = data.http.ebs_csi_iam_policy.body
  policy = data.http.ebs_csi_iam_policy.response_body
}


resource "aws_iam_role" "ebs_csi_iam_role" {
  name = "${local.name}-ebs-csi-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.primary_cluster.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          "StringEquals" = {
            "${replace(aws_eks_cluster.primary_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa",
            "${replace(aws_eks_cluster.primary_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  tags = {
    tag-key = "${local.name}-ebs-csi-iam-role"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.ebs_csi_iam_policy.arn
  role       = aws_iam_role.ebs_csi_iam_role.name
}

data "tls_certificate" "primary_cluster" {
  url = aws_eks_cluster.primary_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "primary_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.primary_cluster.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.primary_cluster.url
}


resource "aws_eks_addon" "primary_cluster_ebs_csi" {
  depends_on                  = [
    aws_iam_role_policy_attachment.ebs_csi_iam_role_policy_attach,
    aws_eks_node_group.primary_nodes,
    aws_eks_cluster.primary_cluster
  ]
  cluster_name                = aws_eks_cluster.primary_cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.24.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.ebs_csi_iam_role.arn
  tags = {
    "eks_addon" = "aws-sebs-csi-driver"
  }
}
