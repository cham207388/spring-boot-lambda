#!/bin/bash

# AWS Production Deployment Script
set -e

echo "🚀 Deploying to AWS..."

# Check if Lambda package exists
if [ ! -f "../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip" ]; then
    echo "❌ Lambda package not found. Please run: mvn clean package"
    exit 1
fi

# Deploy using AWS configuration
terraform apply -var-file="terraform.tfvars.aws" -auto-approve

echo "✅ Deployed to AWS successfully!" 