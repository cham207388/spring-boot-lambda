#!/bin/bash

# Simple PUT test for LocalStack Lambda - Update Course
set -e

echo "🧪 Testing PUT /api/v1/courses/{id} endpoint..."

# Get the function name from Terraform output
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Create the PUT payload for updating course with ID "1"
PUT_PAYLOAD='{"resource":"/api/v1/courses/1","path":"/api/v1/courses/1","httpMethod":"PUT","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":{"id":"1"},"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses/{id}","httpMethod":"PUT","extendedRequestId":"test","requestTime":"22/Jul/2025:18:16:00 +0000","path":"/api/v1/courses/1","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217760,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda - Updated\",\"price\":149.99}","isBase64Encoded":false}'

# Base64 encode the payload
ENCODED_PAYLOAD=$(echo "$PUT_PAYLOAD" | base64)

echo "📡 Executing PUT command to update course with ID '1'..."
echo "Payload length: ${#PUT_PAYLOAD} characters"

# Execute the PUT command
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$ENCODED_PAYLOAD" \
  ../testing/response.json

echo "✅ PUT Response:"
cat ../testing/response.json | jq -r '.body' | jq .

echo ""
echo "🎉 PUT test completed!"
echo "💡 Note: PUT returns 204 (NO_CONTENT) on success, so body will be empty" 