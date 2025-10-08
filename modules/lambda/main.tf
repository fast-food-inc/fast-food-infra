// Module: Lambda function (ZIP upload) with role and environment variables
resource "aws_lambda_function" "this" {
  count         = var.package_path != "" ? 1 : 0
  function_name = var.function_name
  filename      = var.package_path
  source_code_hash = filebase64sha256(var.package_path)
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn
  environment {
    variables = var.environment
  }
  timeout = var.timeout
  tags    = var.tags
}

# Permissão comentada - já é criada pelo módulo API Gateway
# resource "aws_lambda_permission" "allow_apigw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.this.arn
#   principal     = "apigateway.amazonaws.com"
# }
