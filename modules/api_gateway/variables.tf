variable "api_name" {
  type        = string
  description = "Name of the API Gateway"
  default     = "fast-food-api"
}

variable "lambda_arn" {
  type        = string
  description = "ARN of the Lambda function for authentication"
  default     = ""
}

variable "eks_load_balancer_arn" {
  type        = string
  description = "ARN of the EKS load balancer for application services"
  default     = ""
}

variable "stage_name" {
  type        = string
  description = "Name of the API Gateway stage"
  default     = "$default"
}

# Route Configuration
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
    "orders"    = "ANY /orders/{proxy+}"
    "products"  = "ANY /products/{proxy+}"
    "users"     = "ANY /users/{proxy+}"
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

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
