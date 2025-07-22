#!/bin/bash

# LocalStack Lambda Test Script for Course API
set -e

echo "🧪 Testing LocalStack Lambda function for Course API..."

# Get the function name from Terraform output
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Test Lambda function directly
echo ""
echo "🚀 Testing Course API endpoints..."

# Test 1: GET /api/v1/courses (get all courses)
echo ""
echo "📡 Testing GET /api/v1/courses (get all courses)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses","headers":{"Content-Type":"application/json"}}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 2: POST /api/v1/courses (create a course)
echo ""
echo "📡 Testing POST /api/v1/courses (create a course)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"POST","path":"/api/v1/courses","headers":{"Content-Type":"application/json"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda\",\"description\":\"Learn to build serverless applications with Spring Boot\"}"}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 3: POST another course
echo ""
echo "📡 Testing POST /api/v1/courses (create another course)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"POST","path":"/api/v1/courses","headers":{"Content-Type":"application/json"},"body":"{\"id\":\"2\",\"name\":\"Terraform Infrastructure\",\"description\":\"Learn Infrastructure as Code with Terraform\"}"}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 4: GET /api/v1/courses (get all courses again)
echo ""
echo "📡 Testing GET /api/v1/courses (get all courses after creation)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses","headers":{"Content-Type":"application/json"}}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 5: GET /api/v1/courses/{id} (get course by ID)
echo ""
echo "📡 Testing GET /api/v1/courses/1 (get course by ID)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses/1","headers":{"Content-Type":"application/json"}}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 6: GET /api/v1/courses/name/{name} (get course by name)
echo ""
echo "📡 Testing GET /api/v1/courses/name/Spring Boot with AWS Lambda (get course by name)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses/name/Spring Boot with AWS Lambda","headers":{"Content-Type":"application/json"}}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 7: PUT /api/v1/courses/{id} (update course)
echo ""
echo "📡 Testing PUT /api/v1/courses/1 (update course)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"PUT","path":"/api/v1/courses/1","headers":{"Content-Type":"application/json"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda - Updated\",\"description\":\"Updated description for Spring Boot course\"}"}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 8: GET /api/v1/courses/1 (verify update)
echo ""
echo "📡 Testing GET /api/v1/courses/1 (verify update)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses/1","headers":{"Content-Type":"application/json"}}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 9: DELETE /api/v1/courses/{id} (delete course)
echo ""
echo "📡 Testing DELETE /api/v1/courses/2 (delete course)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"DELETE","path":"/api/v1/courses/2","headers":{"Content-Type":"application/json"}}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 10: GET /api/v1/courses (verify deletion)
echo ""
echo "📡 Testing GET /api/v1/courses (verify deletion)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses","headers":{"Content-Type":"application/json"}}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 11: GET /ping (health check)
echo ""
echo "📡 Testing GET /ping (health check)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"httpMethod":"GET","path":"/ping","headers":{"Content-Type":"application/json"}}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Clean up
rm -f response.json

echo ""
echo "🎉 All Course API tests completed!"
echo "🔍 LocalStack Dashboard: http://localhost:4566/_localstack/dashboard"
echo "📊 DynamoDB Table: Course" 