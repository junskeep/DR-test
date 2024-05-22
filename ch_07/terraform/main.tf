data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name_primary = "DR-test-${random_string.suffix.result}"
  name                 = "DR-test-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "velero-test-vpc"
  }
}

resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = slice(["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"], count.index, count.index + 1)[0]
  availability_zone = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]

  map_public_ip_on_launch = true

  tags = {
    Name                                                  = "Public-${count.index}"
    "kubernetes.io/cluster/${local.cluster_name_primary}" = "shared"
    "kubernetes.io/role/elb"                              = 1
  }
}

resource "aws_subnet" "private" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = slice(["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"], count.index, count.index + 1)[0]
  availability_zone       = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  map_public_ip_on_launch = true
  tags = {
    Name                                                  = "Private-${count.index}"
    "kubernetes.io/cluster/${local.cluster_name_primary}" = "shared"
    "kubernetes.io/role/internal-elb"                     = 1
  }
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id

}
resource "aws_eip" "nat" {
  count = 1
}

resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "eks_route_table_association1" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.eks_route_table.id
}
resource "aws_route_table_association" "eks_route_table_association2" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.eks_route_table.id
}

resource "aws_nat_gateway" "this" {
  count         = 1
  subnet_id     = aws_subnet.public[0].id
  allocation_id = aws_eip.nat[0].id
}
######################
# IAM Roles
######################
data "aws_caller_identity" "current" {}

# Create IAM Role
resource "aws_iam_role" "eks_master_role" {
  name = "${local.name}-eks-master-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}
#####################
# EKS Cluster
#####################
resource "aws_eks_cluster" "primary_cluster" {
  name     = local.cluster_name_primary
  role_arn = aws_iam_role.eks_master_role.arn
  version  = "1.26"
  vpc_config {
    subnet_ids             = aws_subnet.public[*].id
    endpoint_public_access = true
    public_access_cidrs = [
      "0.0.0.0/0"
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}


###################
# Managed Node Groups
###################

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${local.name}-eks-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.eks_nodegroup_role.name
}



resource "aws_eks_node_group" "primary_nodes" {
  cluster_name    = aws_eks_cluster.primary_cluster.name
  node_group_name = "${aws_eks_cluster.primary_cluster.name}-node"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = aws_subnet.public[*].id
  update_config {
    max_unavailable = 1
  }
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryPowerUser,
  ]

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
}

############################################
# APP Cluster EKS
############################################
resource "aws_eks_addon" "app_cluster_vpc-cni" {
  cluster_name                = aws_eks_cluster.primary_cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = "v1.15.1-eksbuild.1"
  tags = {
    "eks_addon" = "aws-vpc-cni"
  }
}

resource "aws_eks_addon" "app_cluster_kube-proxy" {
  cluster_name                = aws_eks_cluster.primary_cluster.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  addon_version               = "v1.28.2-eksbuild.2"
  depends_on = [
    aws_eks_cluster.primary_cluster,
    aws_eks_node_group.primary_nodes,
  ]
  tags = {
    "eks_addon" = "aws-kube-proxy"
  }
}