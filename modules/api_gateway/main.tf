// Module: HTTP API Gateway + Hybrid Integration (Lambda + EKS)
resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    max_age       = var.cors_max_age
  }
}

# Lambda Integration (Authentication)
resource "aws_lambda_permission" "apigw" {
  count         = var.lambda_arn != "" ? 1 : 0
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  count                  = var.lambda_arn != "" ? 1 : 0
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# VPC Link for private integration with NLB
resource "aws_apigatewayv2_vpc_link" "eks_vpc_link" {
  name               = "${var.api_name}-vpc-link"
  security_group_ids = var.vpc_link_security_group_ids
  subnet_ids         = var.vpc_link_subnet_ids

  tags = var.tags
}

# EKS Integration (Application Services) via VPC Link
resource "aws_apigatewayv2_integration" "eks_integration" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = var.eks_nlb_listener_arn
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks_vpc_link.id

  request_parameters = {
    "overwrite:path" = "$request.path"
  }
}

# Routes Configuration
resource "aws_apigatewayv2_route" "lambda_routes" {
  for_each  = var.lambda_arn != "" ? var.lambda_routes : {}
  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration[0].id}"

  depends_on = [aws_apigatewayv2_integration.lambda_integration]
}

resource "aws_apigatewayv2_route" "eks_routes" {
  for_each  = var.eks_routes
  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.eks_integration.id}"

  depends_on = [aws_apigatewayv2_integration.eks_integration]
}

# Default route (catch-all for EKS)
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.eks_integration.id}"

  depends_on = [aws_apigatewayv2_integration.eks_integration]
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = var.throttling_rate_limit
    throttling_burst_limit = var.throttling_burst_limit
  }
}
