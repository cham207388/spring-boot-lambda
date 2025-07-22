#!/bin/bash

# LocalStack Cleanup Script
set -e

echo "🧹 Cleaning up LocalStack completely..."

# Stop any running LocalStack containers
echo "🛑 Stopping LocalStack containers..."
docker-compose down 2>/dev/null || true

# Remove any LocalStack containers (force if needed)
echo "🗑️  Removing LocalStack containers..."
docker rm -f spring-boot-lambda-localstack 2>/dev/null || true
docker rm -f $(docker ps -a -q --filter "name=localstack") 2>/dev/null || true

# Remove LocalStack volumes
echo "🗑️  Removing LocalStack volumes..."
docker volume rm spring-boot-lambda_localstack-data 2>/dev/null || true
docker volume rm $(docker volume ls -q --filter "name=localstack") 2>/dev/null || true

# Clean up local directories
echo "🗑️  Cleaning up local directories..."
rm -rf ./localstack-data 2>/dev/null || true
rm -rf /tmp/localstack 2>/dev/null || true

# Remove any dangling Lambda containers
echo "🗑️  Removing Lambda containers..."
docker rm -f $(docker ps -a -q --filter "name=lambda") 2>/dev/null || true

# Clean up Docker system
echo "🧹 Cleaning up Docker system..."
docker system prune -f

echo "✅ Cleanup complete!"
echo ""
echo "🚀 You can now start LocalStack fresh with: make ls-start" 