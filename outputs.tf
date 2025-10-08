output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  value = module.cognito.user_pool_arn
}

output "cognito_client_id" {
  value = module.cognito.client_id
}

output "cognito_client_secret" {
  value     = module.cognito.client_secret
  sensitive = true
}

output "lambda_function_arn" {
  value = module.lambda.function_arn
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "api_gateway_invoke_url" {
  value = module.api_gateway.api_endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = module.ecr.repository_url
}

output "db_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = module.db_secrets.secret_arn
}

# EKS Outputs
output "eks_cluster_id" {
  description = "ID do cluster EKS"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group do cluster EKS"
  value       = module.eks.cluster_security_group_id
}

output "eks_nlb_dns_name" {
  description = "DNS name of the EKS Network Load Balancer"
  value       = module.eks.nlb_dns_name
}

output "eks_nlb_arn" {
  description = "ARN of the EKS Network Load Balancer"
  value       = module.eks.nlb_arn
}

output "eks_nlb_listener_arn" {
  description = "ARN of the EKS NLB Listener"
  value       = module.eks.nlb_listener_arn
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_secrets_role_arn" {
  description = "ARN of the IAM role for service account to access secrets"
  value       = module.eks.secrets_access_role_arn
}
