output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "The endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_arn" {
  description = "The ARN of the API Gateway"
  value       = aws_apigatewayv2_api.this.arn
}

output "stage_id" {
  description = "The ID of the default stage"
  value       = aws_apigatewayv2_stage.default.id
}

output "vpc_link_id" {
  description = "The ID of the VPC Link"
  value       = aws_apigatewayv2_vpc_link.eks_vpc_link.id
}
