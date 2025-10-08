variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Terraform state backend configuration is handled via backend.hcl
# No variables needed for backend configuration

variable "cognito_user_pool_name" {
  type    = string
  default = "fast-food-auth-user-pool"
}

variable "cognito_client_name" {
  type    = string
  default = "fast-food-auth-client"
}

variable "cognito_lambda_config" {
  type    = map(string)
  default = {}
}

# Additional Cognito Configuration
variable "cognito_mfa_configuration" {
  type        = string
  description = "MFA configuration for the user pool (OFF/SMS/ON)"
  default     = "OFF"
}

variable "cognito_username_attributes" {
  type        = list(string)
  description = "Attributes that can be used to sign in (e.g., email or phone_number)"
  default     = []
}

variable "cognito_auto_verified_attributes" {
  type        = list(string)
  description = "Attributes to auto-verify"
  default     = []
}

variable "cognito_allow_admin_create_user_only" {
  type    = bool
  default = false
}

variable "cognito_explicit_auth_flows" {
  type    = list(string)
  default = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

variable "cognito_prevent_user_existence_errors" {
  type    = string
  default = "ENABLED"
}

variable "cognito_generate_client_secret" {
  type    = bool
  default = false
}

variable "cognito_callback_urls" {
  type    = list(string)
  default = []
}

variable "cognito_logout_urls" {
  type    = list(string)
  default = []
}

variable "cognito_refresh_token_validity" {
  type    = number
  default = 30
}

variable "cognito_supported_identity_providers" {
  type    = list(string)
  default = ["COGNITO"]
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "jwt_secret_name" {
  type    = string
  default = "fast-food-jwt-secret"
}

variable "jwt_secret_string" {
  type    = string
  default = "" // should be overridden in tfvars or CI
}

variable "jwt_secret_description" {
  type        = string
  description = "Description for the JWT secret in AWS Secrets Manager"
  default     = "JWT secret for Fast Food application authentication"
}

variable "lambda_role_name" {
  type    = string
  default = "fast-food-auth-lambda-role"
}

variable "lambda_function_name" {
  type    = string
  default = "fast-food-auth-identify"
}

variable "lambda_package_path" {
  type        = string
  description = "Path to the Lambda function package (should be provided by CI/CD pipeline)"
  default     = ""
}

variable "lambda_handler" {
  type    = string
  default = "dist/handlers/identifyHandler.identifyHandler"
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs18.x"
}

variable "lambda_timeout" {
  type    = number
  default = 15
}

variable "api_name" {
  type    = string
  default = "fast-food-auth-api"
}

variable "api_stage_name" {
  type    = string
  default = "$default"
}

# ECR Configuration
variable "ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository for Docker images"
  default     = "fast-food-api"
}

# RDS/Database Configuration
variable "db_secret_name" {
  type        = string
  description = "Name of the secret for database credentials"
  default     = "fast-food-db-credentials"
}

variable "db_username" {
  type        = string
  description = "Database username"
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "db_host" {
  type        = string
  description = "Database host endpoint (from RDS repo)"
  default     = ""
}

variable "db_port" {
  type        = string
  description = "Database port"
  default     = "5432"
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "fastfooddb"
}

variable "lambda_routes" {
  type        = map(string)
  description = "Routes that should go to Lambda (authentication)"
  default = {
    "auth"     = "POST /auth"
    "identify" = "POST /identify"
    "login"    = "POST /login"
  }
}

variable "eks_routes" {
  type        = map(string)
  description = "Routes that should go to EKS (application services)"
  default = {
    "orders"   = "ANY /orders/{proxy+}"
    "products" = "ANY /products/{proxy+}"
    "users"    = "ANY /users/{proxy+}"
    "health"   = "GET /health"
  }
}

# CORS Configuration
variable "cors_allow_origins" {
  type        = list(string)
  description = "Allowed origins for CORS"
  default     = ["*"]
}

variable "cors_allow_methods" {
  type        = list(string)
  description = "Allowed methods for CORS"
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  type        = list(string)
  description = "Allowed headers for CORS"
  default     = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Amz-Security-Token"]
}

variable "cors_max_age" {
  type        = number
  description = "Max age for CORS preflight requests"
  default     = 86400
}

# Throttling Configuration
variable "throttling_rate_limit" {
  type        = number
  description = "Rate limit for API Gateway throttling"
  default     = 1000
}

variable "throttling_burst_limit" {
  type        = number
  description = "Burst limit for API Gateway throttling"
  default     = 2000
}

# EKS Variables
variable "eks_cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "fast-food-cluster"
}

variable "eks_kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  # Use a widely supported patch series; override in dev.tfvars if needed.
  # If this version is rejected by AWS, we'll try letting EKS pick the default.
  default = "1.28"
}

variable "eks_node_instance_types" {
  description = "Tipos de instância para os nodes EKS"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_desired_capacity" {
  description = "Capacidade desejada do node group"
  type        = number
  default     = 2
}

variable "eks_max_capacity" {
  description = "Capacidade máxima do node group"
  type        = number
  default     = 4
}

variable "eks_min_capacity" {
  description = "Capacidade mínima do node group"
  type        = number
  default     = 1
}

# Variáveis para autenticação administrativa (Cognito)
variable "cognito_admin_user_pool_id" {
  type        = string
  description = "ID do Cognito User Pool para administradores (opcional). Se vazio, o módulo Cognito cria um novo user pool."
  default     = ""
}

variable "cognito_admin_client_id" {
  type        = string
  description = "ID do Cognito Client para administradores (opcional). Se vazio, o módulo Cognito criará um novo client e exporá o client_id como saída."
  default     = ""
}

variable "jwt_admin_secret_name" {
  type        = string
  description = "Nome do secret para JWT de administradores"
  default     = "fast-food-jwt-admin-secret"
}

variable "jwt_admin_secret_string" {
  type        = string
  description = "Valor do secret para JWT de administradores (use Secrets Manager em produção)"
  default     = "admin_secret"
}
