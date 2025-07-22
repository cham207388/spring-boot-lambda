#!/bin/bash

# LocalStack Docker Compose Start Script
set -e

echo "🚀 Starting LocalStack with Docker Compose..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Clean up any existing containers first
echo "🧹 Cleaning up any existing LocalStack containers..."
docker-compose down 2>/dev/null || true
docker rm -f spring-boot-lambda-localstack 2>/dev/null || true

# Clean up the problematic tmp directory
echo "🧹 Cleaning up tmp directory..."
rm -rf /tmp/localstack 2>/dev/null || true
rm -rf ./localstack-data 2>/dev/null || true

# Start LocalStack
echo "🔧 Starting LocalStack..."
docker-compose up -d

# Wait for LocalStack to be ready
echo "⏳ Waiting for LocalStack to be ready..."
MAX_RETRIES=60  # Increased retries
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
        echo "✅ LocalStack is ready!"
        break
    else
        echo "⏳ Waiting for LocalStack... (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
        sleep 3  # Increased sleep time
        RETRY_COUNT=$((RETRY_COUNT + 1))
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ LocalStack failed to start within expected time"
    echo "📋 Checking logs..."
    docker-compose logs localstack
    echo ""
    echo "🔧 Try running cleanup first: ./scripts/localstack-cleanup.sh"
    exit 1
fi

echo ""
echo "🎉 LocalStack is running!"
echo "📡 Endpoint: http://localhost:4566"
echo "🔍 Dashboard: http://localhost:4566/_localstack/dashboard"
echo ""
echo "📋 Next steps:"
echo "1. Deploy your Lambda: ./scripts/deploy-localstack.sh"
echo "2. Test your Lambda: ./scripts/test-simple.sh"
echo "3. View logs: docker-compose logs -f localstack"
echo "4. Stop LocalStack: ./scripts/localstack-stop.sh" 