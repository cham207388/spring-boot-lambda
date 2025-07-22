#!/bin/bash

# Simple POST test for LocalStack Lambda
set -e

echo "🧪 Testing POST /api/v1/courses endpoint..."

# Get the function name from Terraform output
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Create the POST payload
POST_PAYLOAD='{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"POST","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"POST","extendedRequestId":"test","requestTime":"22/Jul/2025:18:15:10 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217710,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda\",\"price\":99.99}","isBase64Encoded":false}'

# Base64 encode the payload
ENCODED_PAYLOAD=$(echo "$POST_PAYLOAD" | base64)

echo "📡 Executing POST command..."
echo "Payload length: ${#POST_PAYLOAD} characters"

# Execute the POST command
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$ENCODED_PAYLOAD" \
  ../testing/response.json

echo "✅ POST Response:"
cat ../testing/response.json | jq -r '.body' | jq .

echo ""
echo "🎉 POST test completed!" 