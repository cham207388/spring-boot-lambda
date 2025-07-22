variable "aws_region" {
  default = "us-east-2"
}

variable "use_localstack" {
  description = "Whether to deploy to LocalStack instead of AWS"
  type        = bool
  default     = false
}