provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

data "aws_acm_certificate" "dev_cert" {
  domain      = "dev.alhagiebaicham.com"
  statuses    = ["ISSUED"]
  most_recent = true
  provider    = aws.us-east-1
}