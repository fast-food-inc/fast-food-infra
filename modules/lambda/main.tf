// Module: Lambda function (ZIP upload) with role and environment variables
// Creates Lambda with stub code if package_path is empty (code deployed separately)
data "archive_file" "stub_lambda" {
  type        = "zip"
  output_path = "${path.module}/stub-lambda.zip"

  source {
    content  = <<-EOT
      exports.handler = async (event) => {
        return {
          statusCode: 503,
          body: JSON.stringify({
            message: 'Lambda infrastructure created. Awaiting code deployment from fast-food-auth-lambda workflow.'
          })
        };
      };
    EOT
    filename = "index.js"
  }
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  filename         = var.package_path != "" ? var.package_path : data.archive_file.stub_lambda.output_path
  source_code_hash = var.package_path != "" ? filebase64sha256(var.package_path) : data.archive_file.stub_lambda.output_base64sha256
  handler          = var.handler
  runtime          = var.runtime
  role             = var.role_arn

  environment {
    variables = var.environment
  }

  # VPC Configuration (optional - for RDS access)
  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  timeout = var.timeout
  tags    = var.tags
  
  lifecycle {
    ignore_changes = [
      # Allow Lambda workflow to update code independently
      filename,
      source_code_hash,
      last_modified
    ]
  }
}

# Permissão comentada - já é criada pelo módulo API Gateway
# resource "aws_lambda_permission" "allow_apigw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.this.arn
#   principal     = "apigateway.amazonaws.com"
# }
