resource "aws_lambda_function" "springboot_lambda" {
  function_name = "springboot-course-api"
  handler       = "com.abc.StreamLambdaHandler::handleRequest"
  runtime       = "java21"
  memory_size   = 512
  timeout       = 30
  role          = aws_iam_role.lambda_exec_role.arn

  filename         = "${path.module}/../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip"
  source_code_hash = filebase64sha256("${path.module}/../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip")

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_dynamodb_crud_attach
  ]
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.springboot_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.course_api.execution_arn}/*/*"
}