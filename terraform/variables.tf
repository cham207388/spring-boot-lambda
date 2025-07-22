variable "aws_region" {
  default = "us-east-2"
}

variable "use_localstack" {
  description = "Whether to deploy to LocalStack instead of AWS"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "The ACM certificate ARN for custom domain in us-east-1"
  type        = string
  default     = null
}