###################
# IAM Role for EKS Cluster
###################
resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.project_name}-eks-cluster-iam-role"
  path = "/"
  assume_role_policy = jsonencode(
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
  )
}

###################
# Attach Policy to EKS Cluster Role
###################
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-cluster-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-cluster-role.name
}

###################
# IAM Role for WorkerNodes
###################
resource "aws_iam_role" "eks-node-role" {
  name = "${var.project_name}-eks-nodes-iam-role"
  assume_role_policy = jsonencode(
    {
      Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
        Service = "ec2.amazonaws.com"
        }
      }]
      Version = "2012-10-17"
    }
  )
 }

###################
# Attach Policy to EKS Nodes Role
###################
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.eks-node-role.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.eks-node-role.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.eks-node-role.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.eks-node-role.name
 }


###################
# EKS Cluster
###################
resource "aws_eks_cluster" "ekscluster" {
  name = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids = module.vpc.private_subnets
  }

  depends_on = [
    aws_iam_role.eks-cluster-role
 ]
}

###################
# EKS Nodes
###################
resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.ekscluster.name
  node_group_name = "${var.project_name}-workernodes"
  node_role_arn  = aws_iam_role.eks-node-role.arn
  subnet_ids   =  module.vpc.private_subnets
  instance_types = ["t3.xlarge"]
 
  scaling_config {
    desired_size = 1
    max_size   = 1
    min_size   = 1
  }
 
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

}