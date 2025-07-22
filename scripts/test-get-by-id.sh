#!/bin/bash

# Simple GET by ID test for LocalStack Lambda - Get Course by ID
set -e

echo "🧪 Testing GET /api/v1/courses/{id} endpoint..."

# Get the function name from Terraform output
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Course ID to retrieve (default: "1")
COURSE_ID=${1:-"1"}

echo "📋 Course ID to retrieve: $COURSE_ID"

# Create the GET by ID payload
GET_BY_ID_PAYLOAD='{"resource":"/api/v1/courses/'$COURSE_ID'","path":"/api/v1/courses/'$COURSE_ID'","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":{"id":"'$COURSE_ID'"},"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses/{id}","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:19:10 +0000","path":"/api/v1/courses/'$COURSE_ID'","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217950,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}'

# Base64 encode the payload
ENCODED_PAYLOAD=$(echo "$GET_BY_ID_PAYLOAD" | base64)

echo "📡 Executing GET command to retrieve course with ID '$COURSE_ID'..."
echo "Payload length: ${#GET_BY_ID_PAYLOAD} characters"

# Execute the GET by ID command
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$ENCODED_PAYLOAD" \
  ../testing/response.json

echo "✅ GET by ID Response:"
cat ../testing/response.json | jq -r '.body' | jq .

echo ""
echo "🎉 GET by ID test completed!"
echo "💡 Note: GET by ID returns 200 (OK) with course object or 404 (NOT_FOUND)"
echo "💡 Usage: ./scripts/test-get-by-id.sh [course_id]" 