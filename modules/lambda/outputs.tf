output "function_arn" {
  value = length(aws_lambda_function.this) > 0 ? aws_lambda_function.this[0].arn : ""
}

output "function_name" {
  value = length(aws_lambda_function.this) > 0 ? aws_lambda_function.this[0].function_name : ""
}
