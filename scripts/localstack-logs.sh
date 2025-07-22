#!/bin/bash

# LocalStack Logs Script
set -e

echo "📋 Showing LocalStack logs..."

# Check if LocalStack is running
if ! docker-compose ps | grep -q "localstack.*Up"; then
    echo "❌ LocalStack is not running. Start it first with: ./scripts/localstack-start.sh"
    exit 1
fi

# Show logs with follow option
echo "🔍 Press Ctrl+C to stop following logs"
docker-compose logs -f localstack 