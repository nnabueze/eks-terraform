output "eks_cluster_endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.aws_eks.certificate_authority 
}

output "eks-cluster-name" {
  value = aws_eks_cluster.aws_eks.id
}

output "s3-bucket-name" {
  value = data.aws_s3_bucket.selected.id
}

output "hosted-zone-ns-servers" {
  value = aws_route53_zone.primary.name_servers
}