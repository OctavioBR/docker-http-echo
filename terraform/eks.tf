resource "aws_eks_cluster" "green" {
  name     = "green"
  version  = "1.26"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = module.eks_vpc.private_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_eks]
}

resource "aws_eks_node_group" "spot_small" {
  cluster_name    = aws_eks_cluster.green.name
  node_group_name = "spot-small"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = module.eks_vpc.private_subnets
  capacity_type   = "SPOT"
  instance_types  = ["t3.small"]
  disk_size       = 10

  scaling_config {
    min_size     = 1
    max_size     = 5
    desired_size = 1
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_ecr,
    aws_iam_role_policy_attachment.node_cni,
  ]
}
