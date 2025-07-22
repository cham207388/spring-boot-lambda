#!/bin/bash

# Simple GET test for LocalStack Lambda - Get All Courses
set -e

echo "🧪 Testing GET /api/v1/courses endpoint..."

# Get the function name from Terraform output
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Create the GET payload for retrieving all courses
GET_PAYLOAD='{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:19:00 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217940,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}'

# Base64 encode the payload
ENCODED_PAYLOAD=$(echo "$GET_PAYLOAD" | base64)

echo "📡 Executing GET command to retrieve all courses..."
echo "Payload length: ${#GET_PAYLOAD} characters"

# Execute the GET command
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$ENCODED_PAYLOAD" \
  ../testing/response.json

echo "✅ GET Response:"
cat ../testing/response.json | jq -r '.body' | jq .

echo ""
echo "🎉 GET test completed!"
echo "💡 Note: GET returns 200 (OK) with array of courses" 