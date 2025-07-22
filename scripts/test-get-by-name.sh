#!/bin/bash

# Simple GET by Name test for LocalStack Lambda - Get Course by Name
set -e

echo "🧪 Testing GET /api/v1/courses/name/{name} endpoint..."

# Get the function name from Terraform output
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Course name to retrieve (default: "Spring Boot with AWS Lambda")
COURSE_NAME=${1:-"Spring Boot with AWS Lambda"}

echo "📋 Course name to retrieve: $COURSE_NAME"

# Create the GET by name payload
GET_BY_NAME_PAYLOAD='{"resource":"/api/v1/courses/name/'$COURSE_NAME'","path":"/api/v1/courses/name/'$COURSE_NAME'","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":{"name":"'$COURSE_NAME'"},"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses/name/{name}","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:19:20 +0000","path":"/api/v1/courses/name/'$COURSE_NAME'","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217960,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}'

# Base64 encode the payload
ENCODED_PAYLOAD=$(echo "$GET_BY_NAME_PAYLOAD" | base64)

echo "📡 Executing GET command to retrieve course with name '$COURSE_NAME'..."
echo "Payload length: ${#GET_BY_NAME_PAYLOAD} characters"

# Execute the GET by name command
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$ENCODED_PAYLOAD" \
  ../testing/response.json

echo "✅ GET by Name Response:"
cat ../testing/response.json | jq -r '.body' | jq .

echo ""
echo "🎉 GET by Name test completed!"
echo "💡 Note: GET by Name returns 200 (OK) with course object or 404 (NOT_FOUND)"
echo "💡 Usage: ./scripts/test-get-by-name.sh [course_name]" 