resource "aws_lambda_function" "springboot_lambda" {
  function_name = "springboot-course-api"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "com.abc.StreamLambdaHandler.::handleRequest"
  runtime       = "java21"
  timeout       = 30
  memory_size   = 512
  filename      = "../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip"
  source_code_hash = filebase64sha256("../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip")
}
