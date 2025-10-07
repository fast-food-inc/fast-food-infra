# Fast Food Infrastructure Configuration
# Copy this file to terraform.tfvars and update the values

# AWS Configuration
aws_region = "us-east-1"

# Cognito Configuration
cognito_user_pool_name = "fast-food-auth-user-pool"
cognito_client_name    = "fast-food-auth-client"

# Additional Cognito Settings (optional)
cognito_mfa_configuration             = "OFF"
cognito_username_attributes           = []
cognito_auto_verified_attributes      = []
cognito_allow_admin_create_user_only  = false
cognito_explicit_auth_flows           = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
cognito_prevent_user_existence_errors = "ENABLED"
cognito_generate_client_secret        = false
cognito_callback_urls                 = []
cognito_logout_urls                   = []
cognito_refresh_token_validity        = 30
cognito_supported_identity_providers  = ["COGNITO"]

# Secrets Configuration
jwt_secret_name        = "fast-food-jwt-secret"
jwt_secret_string      = "" # Set via CI/CD secrets or AWS Secrets Manager
jwt_secret_description = "JWT secret for Fast Food application authentication"

# Lambda Configuration (Infrastructure only)
lambda_role_name     = "fast-food-auth-lambda-role"
lambda_function_name = "fast-food-auth-identify"
lambda_package_path  = "" # Must be provided by CI/CD pipeline
lambda_handler       = "dist/handlers/identifyHandler.identifyHandler"
lambda_runtime       = "nodejs18.x"
lambda_timeout       = 15

# API Gateway Configuration
api_name       = "fast-food-auth-api"
api_stage_name = "$default"

# EKS Configuration
eks_cluster_name        = "fast-food-cluster"
eks_kubernetes_version  = "1.29"
eks_node_instance_types = ["t3.medium"]
eks_desired_capacity    = 2
eks_max_capacity        = 4
eks_min_capacity        = 1

# Tags
tags = {
  environment = "dev"
  project     = "fast-food"
  managed_by  = "terraform"
}
