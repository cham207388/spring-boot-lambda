#!/bin/bash

# Simple DELETE test for LocalStack Lambda - Delete Course
set -e

echo "🧪 Testing DELETE /api/v1/courses/{id} endpoint..."

# Get the function name from Terraform output
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Create the DELETE payload for deleting course with ID "1"
DELETE_PAYLOAD='{"resource":"/api/v1/courses/1","path":"/api/v1/courses/1","httpMethod":"DELETE","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":{"id":"1"},"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses/{id}","httpMethod":"DELETE","extendedRequestId":"test","requestTime":"22/Jul/2025:18:16:10 +0000","path":"/api/v1/courses/1","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217770,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}'

# Base64 encode the payload
ENCODED_PAYLOAD=$(echo "$DELETE_PAYLOAD" | base64)

echo "📡 Executing DELETE command to delete course with ID '1'..."
echo "Payload length: ${#DELETE_PAYLOAD} characters"

# Execute the DELETE command
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$ENCODED_PAYLOAD" \
  ../testing/response.json

echo "✅ DELETE Response:"
cat ../testing/response.json | jq -r '.body' | jq .

echo ""
echo "🎉 DELETE test completed!"
echo "💡 Note: DELETE returns 204 (NO_CONTENT) on success, so body will be empty" 