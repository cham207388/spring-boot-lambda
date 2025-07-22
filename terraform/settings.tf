terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42"
    }
  }

  # Only use S3 backend for AWS environment
  backend "s3" {
    bucket         = "project-terraform-state-abc"
    key            = "spring-boot-lambda/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "project-terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
  
  # LocalStack configuration (only applied when use_localstack = true)
  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      apigateway     = "http://localhost:4566"
      cloudwatch     = "http://localhost:4566"
      dynamodb       = "http://localhost:4566"
      ec2            = "http://localhost:4566"
      es             = "http://localhost:4566"
      elasticache    = "http://localhost:4566"
      firehose       = "http://localhost:4566"
      iam            = "http://localhost:4566"
      kinesis        = "http://localhost:4566"
      lambda         = "http://localhost:4566"
      rds            = "http://localhost:4566"
      redshift       = "http://localhost:4566"
      route53        = "http://localhost:4566"
      s3             = "http://localhost:4566"
      secretsmanager = "http://localhost:4566"
      ses            = "http://localhost:4566"
      sns            = "http://localhost:4566"
      sqs            = "http://localhost:4566"
      ssm            = "http://localhost:4566"
      stepfunctions  = "http://localhost:4566"
      sts            = "http://localhost:4566"
    }
  }
  
  # LocalStack specific settings
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null
  s3_use_path_style = var.use_localstack
}