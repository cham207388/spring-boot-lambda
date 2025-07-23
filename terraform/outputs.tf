output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.springboot_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.springboot_lambda.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.course_table.name
}

output "localstack_dashboard" {
  description = "LocalStack Dashboard URL"
  value       = "https://app.localstack.cloud/"
}

output "lambda_invoke_url" {
  description = "LocalStack Lambda invoke URL"
  value       = "http://localhost:4566/_localstack/lambda"
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.springboot_api.id
}

output "api_gateway_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.springboot_api.execution_arn
}

output "api_gateway_invoke_url" {
  description = "API Gateway invoke URL"
  value       = var.use_localstack ? "http://${aws_api_gateway_rest_api.springboot_api.id}.execute-api.localhost.localstack.cloud:4566/${aws_api_gateway_stage.dev.stage_name}" : aws_api_gateway_stage.dev.invoke_url
}

output "api_gateway_root_url" {
  description = "API Gateway root URL for testing"
  value       = var.use_localstack ? "http://localhost:4566/restapis/${aws_api_gateway_rest_api.springboot_api.id}/${aws_api_gateway_stage.dev.stage_name}/_user_request_" : aws_api_gateway_stage.dev.invoke_url
}