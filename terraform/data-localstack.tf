# LocalStack mock caller identity
data "aws_caller_identity" "current" {
  # LocalStack uses a fixed account ID
  # This is a mock data source for LocalStack
} 