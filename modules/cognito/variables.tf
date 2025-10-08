variable "user_pool_name" {
  type        = string
  description = "Name of the Cognito User Pool"
}

variable "client_name" {
  type        = string
  description = "Name of the User Pool Client"
}

variable "mfa_configuration" {
  type        = string
  description = "MFA configuration for the user pool (OFF/SMS/ON)"
  default     = "OFF"
}

variable "username_attributes" {
  type        = list(string)
  description = "Attributes that can be used to sign in (e.g., email or phone_number)"
  default     = []
}

variable "auto_verified_attributes" {
  type        = list(string)
  description = "Attributes to auto-verify"
  default     = []
}

variable "lambda_config" {
  type        = map(string)
  description = "Map of lambda triggers for the user pool"
  default     = {}
}

variable "allow_admin_create_user_only" {
  type    = bool
  default = false
}

variable "explicit_auth_flows" {
  type    = list(string)
  default = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

variable "prevent_user_existence_errors" {
  type    = string
  default = "ENABLED"
}

variable "generate_client_secret" {
  type    = bool
  default = false
}

variable "callback_urls" {
  type    = list(string)
  default = []
}

variable "logout_urls" {
  type    = list(string)
  default = []
}

variable "refresh_token_validity" {
  type    = number
  default = 30
}

variable "supported_identity_providers" {
  type    = list(string)
  default = ["COGNITO"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
