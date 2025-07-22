resource "aws_lambda_function" "springboot_lambda" {
  function_name = "springboot-course-api"
  handler       = "com.abc.StreamLambdaHandler::handleRequest"
  runtime       = "java17"
  memory_size   = 512
  timeout       = 300
  role          = aws_iam_role.lambda_exec_role.arn
  architectures = ["arm64"]

  filename         = "${path.module}/../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip"
  source_code_hash = filebase64sha256("${path.module}/../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip")

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_dynamodb_crud_attach
  ]
}