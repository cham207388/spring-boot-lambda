output "api_invoke_url" {
  description = "Base URL to access the deployed API"
  value       = "https://${aws_api_gateway_rest_api.course_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.dev_stage.stage_name}"
}