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
  --payload "$(echo '{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:15:00 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217700,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 2: POST /api/v1/courses (create a course)
echo ""
echo "📡 Testing POST /api/v1/courses (create a course)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"POST","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"POST","extendedRequestId":"test","requestTime":"22/Jul/2025:18:15:10 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217710,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda\",\"description\":\"Learn to build serverless applications with Spring Boot\"}","isBase64Encoded":false}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

# Test 3: GET /api/v1/courses (get all courses again)
echo ""
echo "📡 Testing GET /api/v1/courses (get all courses after creation)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:15:20 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217720,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}' | base64)" \
  response.json

echo "✅ Response:"
cat response.json | jq -r '.body' | jq .

echo ""
echo "🎉 Course API tests completed!" 