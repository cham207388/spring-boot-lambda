#!/bin/bash

# Apple Silicon M3 Setup Script for Spring Boot Lambda + LocalStack
set -e

echo "🍎 Setting up Spring Boot Lambda for Apple Silicon M3..."

# Check if we're on Apple Silicon
if [[ $(uname -m) != "arm64" ]]; then
    echo "❌ This script is designed for Apple Silicon (ARM64) machines"
    echo "   Detected architecture: $(uname -m)"
    exit 1
fi

echo "✅ Detected Apple Silicon architecture: $(uname -m)"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop for Mac"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop"
    exit 1
fi

echo "✅ Docker is running"

# Clean up any existing LocalStack containers
echo "🧹 Cleaning up existing LocalStack containers..."
docker-compose down 2>/dev/null || true
docker rm -f spring-boot-lambda-localstack 2>/dev/null || true

# Build the Lambda package for ARM64
echo "🏗️  Building Lambda package for ARM64..."
export DOCKER_DEFAULT_PLATFORM=linux/arm64
mvn clean package -Ddocker.platform=linux/arm64

# Verify the package was created
if [ ! -f "target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip" ]; then
    echo "❌ Lambda package not found after build"
    exit 1
fi

echo "✅ Lambda package created: $(ls -lh target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip | awk '{print $5}')"

# Start LocalStack with ARM64 configuration
echo "🚀 Starting LocalStack with ARM64 configuration..."
docker-compose up -d

# Wait for LocalStack to be ready
echo "⏳ Waiting for LocalStack to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:4566/_localstack/health > /dev/null; then
        echo "✅ LocalStack is ready!"
        break
    fi
    
    echo "⏳ Waiting for LocalStack... (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
    sleep 3
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ LocalStack failed to start within expected time"
    echo "📋 Checking LocalStack logs..."
    docker-compose logs --tail=20 localstack
    exit 1
fi

# Deploy to LocalStack
echo "🚀 Deploying to LocalStack..."
cd terraform
terraform apply -var-file="terraform.tfvars.localstack" -auto-approve
cd ..

echo ""
echo "🎉 Setup complete for Apple Silicon M3!"
echo ""
echo "📊 LocalStack Dashboard: https://app.localstack.cloud/"
echo "🧪 Test your Lambda: make ls-test"
echo "📋 Check status: make ls-check"
echo ""
echo "💡 Tips for Apple Silicon:"
echo "   - Lambda cold starts may take 1-2 minutes"
echo "   - Use 'make ls-logs' to monitor LocalStack"
echo "   - ARM64 architecture provides better performance on M3" 