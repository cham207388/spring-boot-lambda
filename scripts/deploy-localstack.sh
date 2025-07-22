#!/bin/bash

# LocalStack Deployment Script
set -e

echo "🚀 Deploying to LocalStack..."

# Check if LocalStack is running
if ! curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo "❌ LocalStack is not running. Please start LocalStack first."
    exit 1
fi

# Check if Lambda package exists
if [ ! -f "target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip" ]; then
    echo "❌ Lambda package not found. Please run: mvn clean package"
    exit 1
fi

# Deploy using LocalStack configuration
cd terraform
terraform init -upgrade
terraform apply -var-file="terraform.tfvars.localstack" -auto-approve

echo "✅ Deployed to LocalStack successfully!"
echo "🔍 Dashboard: http://localhost:4566/_localstack/dashboard" 