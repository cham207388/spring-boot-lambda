#!/bin/bash

# LocalStack Docker Compose Stop Script
set -e

echo "🛑 Stopping LocalStack..."

# Stop LocalStack
docker-compose down

echo "✅ LocalStack stopped!"

# Optional: Clean up volumes (uncomment if needed)
# echo "🧹 Cleaning up volumes..."
# docker-compose down -v

echo ""
echo "📋 To start LocalStack again: ./scripts/localstack-start.sh" 