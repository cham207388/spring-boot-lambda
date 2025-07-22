#!/bin/bash

# LocalStack Terraform Deployment Script
set -e

echo "🚀 Starting LocalStack Terraform deployment..."

# Check if LocalStack is running
echo "📋 Checking LocalStack status..."
if ! curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo "❌ LocalStack is not running. Please start LocalStack first."
    echo "   You can start it with: docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 localstack/localstack"
    exit 1
fi

echo "✅ LocalStack is running!"

# Check if the Lambda package exists
LAMBDA_PACKAGE="../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip"
if [ ! -f "$LAMBDA_PACKAGE" ]; then
    echo "❌ Lambda package not found: $LAMBDA_PACKAGE"
    echo "   Please build the project first with: mvn clean package"
    exit 1
fi

echo "✅ Lambda package found!"

# Initialize Terraform with LocalStack configuration
echo "🔧 Initializing Terraform..."
terraform init

# Plan the deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Apply the deployment
echo "🚀 Applying deployment..."
terraform apply tfplan

echo "✅ Deployment completed successfully!"

# Get the API Gateway URL
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "http://localhost:4566/restapis/$(terraform output -raw api_gateway_id)/dev/_user_request_/")

echo ""
echo "🎉 Your Spring Boot Lambda API is now deployed to LocalStack!"
echo "📡 API Gateway URL: $API_URL"
echo ""
echo "🧪 Test your API:"
echo "   curl -X GET '$API_URL/courses'"
echo "   curl -X POST '$API_URL/courses' -H 'Content-Type: application/json' -d '{\"name\":\"Test Course\",\"description\":\"Test Description\"}'"
echo ""
echo "🔍 LocalStack Dashboard: http://localhost:4566/_localstack/dashboard"
echo "📊 CloudWatch Logs: http://localhost:4566/_localstack/cloudwatch" 