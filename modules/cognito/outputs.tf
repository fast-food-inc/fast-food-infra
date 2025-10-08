output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  value = aws_cognito_user_pool.this.arn
}

output "client_id" {
  value = aws_cognito_user_pool_client.this.id
}

output "client_secret" {
  value       = aws_cognito_user_pool_client.this.client_secret
  description = "Only populated if generate_client_secret = true"
}
