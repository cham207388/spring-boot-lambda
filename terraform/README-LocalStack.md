# LocalStack Deployment Guide

This guide will help you deploy your Spring Boot Lambda application to LocalStack for local development and testing.

## Prerequisites

1. **LocalStack running** on port 4566
2. **Terraform** installed (version ~> 1.7)
3. **Java 21** and **Maven** for building the Lambda package
4. **Docker** (for running LocalStack)

## Quick Start

### 1. Start LocalStack

If you don't have LocalStack running, start it with:

```bash
docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack
```

### 2. Build the Lambda Package

From the project root, build the Lambda package:

```bash
mvn clean package
```

This will create the file: `target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip`

### 3. Deploy to LocalStack

Navigate to the terraform directory and run the deployment script:

```bash
cd terraform
./deploy-localstack.sh
```

## Manual Deployment Steps

If you prefer to deploy manually:

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Plan the Deployment

```bash
terraform plan -out=tfplan
```

### 3. Apply the Configuration

```bash
terraform apply tfplan
```

## Configuration Files

The LocalStack deployment uses these modified configuration files:

- `settings-localstack.tf` - LocalStack provider configuration
- `variables-localstack.tf` - LocalStack-specific variables
- `iam-permissions-localstack.tf` - IAM configuration for LocalStack
- `data-localstack.tf` - Mock data sources for LocalStack

## What Gets Deployed

1. **DynamoDB Table**: `Course` table for storing course data
2. **IAM Role**: Lambda execution role with DynamoDB permissions
3. **Lambda Function**: Spring Boot application packaged as Lambda
4. **API Gateway**: REST API with proxy integration
5. **Custom Domain**: Domain mapping (mocked for LocalStack)

## Testing Your API

After deployment, you can test your API using the provided URL:

### Get all courses
```bash
curl -X GET 'http://localhost:4566/restapis/{api-id}/dev/_user_request_/courses'
```

### Create a course
```bash
curl -X POST 'http://localhost:4566/restapis/{api-id}/dev/_user_request_/courses' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Spring Boot with AWS Lambda",
    "description": "Learn to build serverless applications with Spring Boot"
  }'
```

### Health check
```bash
curl -X GET 'http://localhost:4566/restapis/{api-id}/dev/_user_request_/ping'
```

## LocalStack Dashboard

Access the LocalStack dashboard at: http://localhost:4566/_localstack/dashboard

This provides a web interface to:
- View deployed resources
- Monitor logs
- Test API endpoints
- Manage DynamoDB tables

## Troubleshooting

### LocalStack Not Running
```bash
# Check if LocalStack is running
curl http://localhost:4566/_localstack/health
```

### Lambda Package Missing
```bash
# Build the package
mvn clean package
```

### Terraform State Issues
```bash
# Remove existing state and start fresh
rm -rf .terraform terraform.tfstate*
terraform init
```

### API Gateway Issues
- LocalStack API Gateway may have different behavior than AWS
- Use the provided test URLs from the deployment output
- Check LocalStack logs for detailed error messages

## Cleanup

To destroy the LocalStack resources:

```bash
terraform destroy
```

## Differences from AWS Deployment

1. **No S3 Backend**: LocalStack doesn't support S3 backend for Terraform state
2. **Mock Certificates**: ACM certificates are mocked
3. **Fixed Account ID**: Uses `000000000000` as the account ID
4. **Local Endpoints**: All AWS services point to `localhost:4566`
5. **No Real IAM**: IAM policies are simplified for LocalStack

## Next Steps

Once your application is running in LocalStack:
1. Test all API endpoints
2. Verify DynamoDB operations
3. Check Lambda logs
4. Test error scenarios
5. When ready, deploy to AWS using the original Terraform configuration 