

resource "aws_iam_policy" "velero_policy" {
  name        = "velero-policy-${var.region}"
  path        = "/"
  description = "velero policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ]
        Resource = [
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/*",
          "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:snapshot/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:ListBucketVersions"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}/*",
          "arn:aws:s3:::${var.bucket_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/VeleroAccess"
        ]
      }
    ]
  })
}



resource "aws_iam_role" "velero_role" {
  name = "velero-access-${var.region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.primary_cluster.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.primary_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:velero:velero",
            "${replace(aws_eks_cluster.primary_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "velero_attach" {
  role       = aws_iam_role.velero_role.name
  policy_arn = aws_iam_policy.velero_policy.arn
}

output "velero_role_arn" {
  value       = aws_iam_role.velero_role.arn
  description = "Velero ARN of the role"
}