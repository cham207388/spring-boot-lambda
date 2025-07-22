#!/bin/bash

# LocalStack Status Check Script
set -e

echo "🔍 Checking LocalStack status and Lambda function..."

# Check if LocalStack is running
echo "📋 Checking LocalStack health..."
if ! curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo "❌ LocalStack is not running. Please start LocalStack first."
    exit 1
fi

echo "✅ LocalStack is running!"

# Check LocalStack services
echo ""
echo "📋 Checking LocalStack services..."
curl -s http://localhost:4566/_localstack/health | jq .

# Check if Lambda function exists
echo ""
echo "📋 Checking Lambda function status..."
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "🔍 Function name: $FUNCTION_NAME"

# Try to get function details
if aws --endpoint-url=http://localhost:4566 lambda get-function --function-name "$FUNCTION_NAME" 2>/dev/null; then
    echo "✅ Lambda function exists"
else
    echo "❌ Lambda function not found. Please deploy first with: ./scripts/deploy-localstack.sh"
    exit 1
fi

# Check DynamoDB table
echo ""
echo "📋 Checking DynamoDB table..."
if aws --endpoint-url=http://localhost:4566 dynamodb describe-table --table-name "Course" 2>/dev/null; then
    echo "✅ DynamoDB table 'Course' exists"
else
    echo "❌ DynamoDB table 'Course' not found"
fi

echo ""
echo "🔧 Troubleshooting Lambda timeout issues:"
echo ""
echo "1. Increase LocalStack resources:"
echo "   docker run --rm -it -p 4566:4566 -p 4510-4559:4510-4559 \\"
echo "     -e LAMBDA_EXECUTOR=docker \\"
echo "     -e LAMBDA_REMOTE_DOCKER=false \\"
echo "     -e LAMBDA_DOCKER_FLAGS='-p 8080:8080' \\"
echo "     -e DOCKER_HOST=unix:///var/run/docker.sock \\"
echo "     localstack/localstack"
echo ""
echo "2. Check LocalStack logs:"
echo "   docker logs <localstack-container-id>"
echo ""
echo "3. Try a simple test first:"
echo "   aws --endpoint-url=http://localhost:4566 lambda invoke \\"
echo "     --function-name \"$FUNCTION_NAME\" \\"
echo "     --payload \"\$(echo '{\"httpMethod\":\"GET\",\"path\":\"/ping\",\"headers\":{}}' | base64)\" \\"
echo "     response.json"
echo ""
echo "4. LocalStack Dashboard: http://localhost:4566/_localstack/dashboard" 