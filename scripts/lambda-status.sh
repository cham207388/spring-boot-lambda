#!/bin/bash

# Lambda Status Check Script
set -e

echo "🔍 Checking Lambda function status..."

# Get function name
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Check if function exists
echo ""
echo "📋 Function details:"
if aws --endpoint-url=http://localhost:4566 lambda get-function --function-name "$FUNCTION_NAME" 2>/dev/null; then
    echo "✅ Lambda function exists and is deployed"
else
    echo "❌ Lambda function not found or not deployed"
    exit 1
fi

# Check function configuration
echo ""
echo "📋 Function configuration:"
aws --endpoint-url=http://localhost:4566 lambda get-function-configuration --function-name "$FUNCTION_NAME" 2>/dev/null | jq '.'

# Check if function is ready (quick test)
echo ""
echo "🧪 Quick readiness test..."
if aws --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload "$(echo '{"httpMethod":"GET","path":"/ping","headers":{}}' | base64)" \
    response.json 2>/dev/null; then
    
    echo "✅ Lambda function is ready and responding!"
    echo "📡 Response:"
    cat response.json | jq -r '.body' | jq .
    rm -f response.json
else
    echo "⏳ Lambda function exists but not ready yet (cold start in progress)"
    echo "💡 This is normal for Spring Boot Lambda functions"
    echo "⏰ Wait 1-2 minutes for cold start to complete"
fi

echo ""
echo "🔍 LocalStack Dashboard: http://localhost:4566/_localstack/dashboard" 