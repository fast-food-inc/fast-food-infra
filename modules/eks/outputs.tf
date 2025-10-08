output "cluster_id" {
  description = "ID do cluster EKS"
  value       = aws_eks_cluster.fast_food_cluster.id
}

output "cluster_arn" {
  description = "ARN do cluster EKS"
  value       = aws_eks_cluster.fast_food_cluster.arn
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = aws_eks_cluster.fast_food_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group do cluster EKS"
  value       = aws_eks_cluster.fast_food_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Certificado de autoridade do cluster"
  value       = aws_eks_cluster.fast_food_cluster.certificate_authority[0].data
}

output "node_group_arn" {
  description = "ARN do node group"
  value       = aws_eks_node_group.fast_food_nodes.arn
}

output "node_group_status" {
  description = "Status do node group"
  value       = aws_eks_node_group.fast_food_nodes.status
}

output "nlb_arn" {
  description = "ARN do Network Load Balancer"
  value       = aws_lb.eks_nlb.arn
}

output "nlb_dns_name" {
  description = "DNS name do Network Load Balancer"
  value       = aws_lb.eks_nlb.dns_name
}

output "nlb_zone_id" {
  description = "Zone ID do Network Load Balancer"
  value       = aws_lb.eks_nlb.zone_id
}

output "nlb_listener_arn" {
  description = "ARN do NLB Listener"
  value       = aws_lb_listener.eks_listener.arn
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = aws_lb_target_group.eks_tg.arn
}

output "secrets_access_role_arn" {
  description = "ARN of the IAM role for service account to access secrets"
  value       = aws_iam_role.secrets_access_role.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for EKS"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}
