// Terraform module: Cognito User Pool + User Pool Client (custom auth support)
// Responsibility: provisiona um User Pool configurado para ALLOW_CUSTOM_AUTH e um User Pool Client

resource "aws_cognito_user_pool" "this" {
  name                     = var.user_pool_name
  mfa_configuration        = var.mfa_configuration
  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes
  // Optional lambda triggers (dynamic block)
  dynamic "lambda_config" {
    for_each = length(var.lambda_config) > 0 ? [var.lambda_config] : []
    content {
      pre_authentication             = lookup(lambda_config.value, "pre_authentication", null)
      post_authentication            = lookup(lambda_config.value, "post_authentication", null)
      post_confirmation              = lookup(lambda_config.value, "post_confirmation", null)
      pre_sign_up                    = lookup(lambda_config.value, "pre_sign_up", null)
      pre_token_generation           = lookup(lambda_config.value, "pre_token_generation", null)
      user_migration                 = lookup(lambda_config.value, "user_migration", null)
      define_auth_challenge          = lookup(lambda_config.value, "define_auth_challenge", null)
      create_auth_challenge          = lookup(lambda_config.value, "create_auth_challenge", null)
      verify_auth_challenge_response = lookup(lambda_config.value, "verify_auth_challenge_response", null)
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = var.allow_admin_create_user_only
  }

  // Basic password policy (customize via variables if needed)
  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = var.client_name
  user_pool_id = aws_cognito_user_pool.this.id

  // Explicit flows required for custom auth
  explicit_auth_flows = var.explicit_auth_flows

  prevent_user_existence_errors = var.prevent_user_existence_errors
  generate_secret               = var.generate_client_secret

  // Optional OAuth/Callback settings (defaults empty)
  callback_urls          = var.callback_urls
  logout_urls            = var.logout_urls
  refresh_token_validity = var.refresh_token_validity

  supported_identity_providers = var.supported_identity_providers
}
