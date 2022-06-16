########################
# EKS CLUSTER
#######################
# creating eks custer
resource "aws_eks_cluster" "aws_eks" {
  name     = "${var.app_name}-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = aws_subnet.private.*.id
  }

  tags = {
    Name = "${var.app_name}-${var.app_environment}"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}

# creating eks worker node 
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "${var.app_name}-node"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private.*.id
  instance_types  = var.worker_node_type
  

  remote_access {
    ec2_ssh_key = aws_key_pair.bh-key-pair.key_name
    source_security_group_ids = [aws_security_group.eks-node-sg.id]
  }

  scaling_config {
    desired_size = 4
    max_size     = 4
    min_size     = 4
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_key_pair" "bh-key-pair" {
  key_name   = "${var.app_name}-key-pair"
  public_key = file(var.public-key-pair)
}