terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket = "fast-food-terraform-state-397505580549"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources para VPC padrão
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Filter subnets to only include EKS-supported availability zones
data "aws_subnets" "eks_supported" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

# Security Group for EKS to access RDS
resource "aws_security_group" "eks_to_rds" {
  name        = "eks-to-rds-sg"
  description = "Allow EKS pods to access RDS"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description = "Allow outbound to RDS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  tags = merge(var.tags, {
    Name = "eks-to-rds-sg"
  })
}

module "cognito" {
  source = "./modules/cognito"

  user_pool_name                = var.cognito_user_pool_name
  client_name                   = var.cognito_client_name
  lambda_config                 = var.cognito_lambda_config
  mfa_configuration             = var.cognito_mfa_configuration
  username_attributes           = var.cognito_username_attributes
  auto_verified_attributes      = var.cognito_auto_verified_attributes
  allow_admin_create_user_only  = var.cognito_allow_admin_create_user_only
  explicit_auth_flows           = var.cognito_explicit_auth_flows
  prevent_user_existence_errors = var.cognito_prevent_user_existence_errors
  generate_client_secret        = var.cognito_generate_client_secret
  callback_urls                 = var.cognito_callback_urls
  logout_urls                   = var.cognito_logout_urls
  refresh_token_validity        = var.cognito_refresh_token_validity
  supported_identity_providers  = var.cognito_supported_identity_providers
  tags                          = var.tags
}

module "secrets" {
  source        = "./modules/secrets"
  secret_name   = var.jwt_secret_name
  description   = var.jwt_secret_description
  secret_string = var.jwt_secret_string
  tags          = var.tags
}

module "iam" {
  source       = "./modules/iam"
  role_name    = var.lambda_role_name
  secrets_arns = [module.secrets.secret_arn]
  cognito_arns = [module.cognito.user_pool_arn]
  tags         = var.tags
}

module "lambda" {
  source        = "./modules/lambda"
  function_name = var.lambda_function_name
  package_path  = var.lambda_package_path
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role_arn      = module.iam.lambda_role_arn
  environment = {
    COGNITO_USER_POOL_ID = module.cognito.user_pool_id
    COGNITO_CLIENT_ID    = module.cognito.client_id
    JWT_SECRET_ARN       = module.secrets.secret_arn
  }

  # VPC Configuration for RDS access
  vpc_subnet_ids         = data.aws_subnets.eks_supported.ids
  vpc_security_group_ids = [module.eks.cluster_security_group_id]

  timeout = var.lambda_timeout
  tags    = var.tags
}

# ECR Repository for Docker images
module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
  tags            = var.tags
}

# RDS Database Credentials in Secrets Manager
module "db_secrets" {
  source      = "./modules/secrets"
  secret_name = var.db_secret_name
  description = "Database credentials for Fast Food API"
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
  tags = var.tags
}

module "api_gateway" {
  source                      = "./modules/api_gateway"
  api_name                    = var.api_name
  lambda_arn                  = module.lambda.function_arn
  eks_nlb_arn                 = module.eks.nlb_arn
  eks_nlb_listener_arn        = module.eks.nlb_listener_arn
  vpc_link_subnet_ids         = data.aws_subnets.eks_supported.ids
  vpc_link_security_group_ids = [module.eks.cluster_security_group_id]
  stage_name                  = var.api_stage_name

  # Route Configuration
  lambda_routes = var.lambda_routes
  eks_routes    = var.eks_routes

  # CORS Configuration
  cors_allow_origins = var.cors_allow_origins
  cors_allow_methods = var.cors_allow_methods
  cors_allow_headers = var.cors_allow_headers
  cors_max_age       = var.cors_max_age

  # Throttling Configuration
  throttling_rate_limit  = var.throttling_rate_limit
  throttling_burst_limit = var.throttling_burst_limit

  tags = var.tags

  depends_on = [module.eks]
}
// Re-enable the EKS module: previously disabled due to version negotiation issues.
// Adjust `eks_kubernetes_version` in variables.tf or dev.tfvars if needed.
module "eks" {
  source = "./modules/eks"

  cluster_name        = var.eks_cluster_name
  kubernetes_version  = var.eks_kubernetes_version
  subnet_ids          = data.aws_subnets.eks_supported.ids
  private_subnet_ids  = data.aws_subnets.eks_supported.ids
  node_instance_types = var.eks_node_instance_types
  desired_capacity    = var.eks_desired_capacity
  max_capacity        = var.eks_max_capacity
  min_capacity        = var.eks_min_capacity
  secrets_arns        = [module.db_secrets.secret_arn, module.secrets.secret_arn]
  tags                = var.tags
}
