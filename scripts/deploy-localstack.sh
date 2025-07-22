#!/bin/bash

# Deploy to LocalStack Script
set -e

echo "🚀 Deploying to LocalStack..."

# Build the Lambda package first
echo "🏗️  Building Lambda package..."
mvn clean package

# Verify the Lambda package was created
if [ ! -f "target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip" ]; then
    echo "❌ Lambda package not found after build. Build may have failed."
    exit 1
fi

echo "✅ Lambda package built successfully"

# Wait for LocalStack to be ready with better retry logic
echo "⏳ Waiting for LocalStack to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
        echo "✅ LocalStack is ready!"
        break
    fi
    
    echo "⏳ Waiting for LocalStack... (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
    sleep 5
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ LocalStack failed to start within expected time"
    echo "📋 Checking LocalStack logs..."
    docker-compose logs --tail=20 localstack
    exit 1
fi

# Deploy using LocalStack configuration
cd terraform
terraform apply -var-file="terraform.tfvars.localstack" -auto-approve
cd ..

echo "✅ Deployed to LocalStack successfully!"
echo "📊 Dashboard: https://app.localstack.cloud/" 