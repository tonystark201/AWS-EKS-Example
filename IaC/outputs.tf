
output "eks_cluster_name" {
    value = aws_eks_cluster.ekscluster.name
}

output "ecr_repository_url" {
    value = aws_ecr_repository.demo-repository.repository_url
}
