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

# EKS Outputs
/* EKS outputs removed while the EKS module is temporarily disabled.
   Re-enable these outputs if/when module "eks" is restored in main.tf.
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
*/
