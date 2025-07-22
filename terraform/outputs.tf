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