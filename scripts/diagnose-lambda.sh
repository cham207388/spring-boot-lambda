#!/bin/bash

# Lambda Function Diagnostic Script
set -e

echo "🔍 Diagnosing Lambda function issues..."

# Get function name
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# 1. Check LocalStack health
echo ""
echo "1️⃣ Checking LocalStack health..."
if curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo "✅ LocalStack is running"
else
    echo "❌ LocalStack is not responding"
    exit 1
fi

# 2. Check if function exists
echo ""
echo "2️⃣ Checking if Lambda function exists..."
if aws --endpoint-url=http://localhost:4566 lambda get-function --function-name "$FUNCTION_NAME" 2>/dev/null; then
    echo "✅ Lambda function exists"
else
    echo "❌ Lambda function not found"
    exit 1
fi

# 3. Check function configuration
echo ""
echo "3️⃣ Checking function configuration..."
FUNCTION_CONFIG=$(aws --endpoint-url=http://localhost:4566 lambda get-function-configuration --function-name "$FUNCTION_NAME" 2>/dev/null)
echo "Runtime: $(echo "$FUNCTION_CONFIG" | jq -r '.Runtime')"
echo "Handler: $(echo "$FUNCTION_CONFIG" | jq -r '.Handler')"
echo "Timeout: $(echo "$FUNCTION_CONFIG" | jq -r '.Timeout')"
echo "Memory: $(echo "$FUNCTION_CONFIG" | jq -r '.MemorySize')"

# 4. Check if Lambda package exists
echo ""
echo "4️⃣ Checking Lambda package..."
if [ -f "../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip" ]; then
    echo "✅ Lambda package exists"
    echo "Size: $(ls -lh ../target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip | awk '{print $5}')"
else
    echo "❌ Lambda package not found"
    echo "💡 Run: make build"
    exit 1
fi

# 5. Check LocalStack logs
echo ""
echo "5️⃣ Checking LocalStack logs (last 20 lines)..."
docker-compose logs --tail=20 localstack 2>/dev/null || echo "No logs available"

# 6. Try a simple invoke with verbose output
echo ""
echo "6️⃣ Trying Lambda invoke with verbose output..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload "$(echo '{"httpMethod":"GET","path":"/ping","headers":{}}' | base64)" \
    response.json \
    --log-type Tail \
    --query 'LogResult' \
    --output text 2>&1 | base64 -d || echo "Invoke failed"

# 7. Check DynamoDB table
echo ""
echo "7️⃣ Checking DynamoDB table..."
if aws --endpoint-url=http://localhost:4566 dynamodb describe-table --table-name "Course" 2>/dev/null; then
    echo "✅ DynamoDB table exists"
else
    echo "❌ DynamoDB table not found"
fi

# 8. Check IAM role
echo ""
echo "8️⃣ Checking IAM role..."
if aws --endpoint-url=http://localhost:4566 iam get-role --role-name "lambda_exec_role" 2>/dev/null; then
    echo "✅ IAM role exists"
else
    echo "❌ IAM role not found"
fi

echo ""
echo "🔧 Troubleshooting suggestions:"
echo "1. Check if Java 17 runtime is supported in LocalStack"
echo "2. Verify the Lambda package is valid"
echo "3. Check LocalStack version compatibility"
echo "4. Try restarting LocalStack: make ls-stop && make ls-start"
echo "5. Check Docker resources (CPU/Memory)"
echo ""
echo "📊 LocalStack Dashboard: http://localhost:4566/_localstack/dashboard" 