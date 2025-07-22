variable "aws_region" {
  default = "us-east-1"
}

# LocalStack doesn't need real ACM certificates
variable "acm_certificate_arn" {
  description = "The ACM certificate ARN for custom domain (not used in LocalStack)"
  type        = string
  default     = "arn:aws:acm:us-east-1:000000000000:certificate/test-cert"
} 