output "jenkins_sg_id" {
  description = "Jenkins security group ID"
  value       = aws_security_group.jenkins.id
}

output "eks_cluster_sg_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.eks_cluster.id
}

output "eks_node_sg_id" {
  description = "EKS node security group ID"
  value       = aws_security_group.eks_node.id
}
