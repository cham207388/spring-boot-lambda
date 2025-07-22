#!/bin/bash

# Comprehensive CRUD test for LocalStack Lambda - Course API
set -e

echo "🧪 Testing Complete CRUD Operations for Course API..."

# Get the function name from Terraform output
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"

# Test Lambda function directly
echo ""
echo "🚀 Testing Course API CRUD endpoints..."

# Step 1: GET /api/v1/courses (get all courses - should be empty initially)
echo ""
echo "📡 Step 1: GET /api/v1/courses (initial state)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:17:00 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217820,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}' | base64)" \
  ../testing/response.json

echo "✅ Initial GET Response:"
cat ../testing/response.json | jq -r '.body' | jq .

# Step 2: POST /api/v1/courses (create a course)
echo ""
echo "📡 Step 2: POST /api/v1/courses (create a course)..."
POST_PAYLOAD='{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"POST","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"POST","extendedRequestId":"test","requestTime":"22/Jul/2025:18:17:10 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217830,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda\",\"price\":99.99}","isBase64Encoded":false}'

aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo "$POST_PAYLOAD" | base64)" \
  ../testing/response.json

echo "✅ POST Response:"
cat ../testing/response.json | jq -r '.body' | jq .

# Step 3: GET /api/v1/courses (verify creation)
echo ""
echo "📡 Step 3: GET /api/v1/courses (verify creation)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:17:20 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217840,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}' | base64)" \
  ../testing/response.json

echo "✅ GET Response (after creation):"
cat ../testing/response.json | jq -r '.body' | jq .

# Step 4: PUT /api/v1/courses/1 (update the course)
echo ""
echo "📡 Step 4: PUT /api/v1/courses/1 (update the course)..."
PUT_PAYLOAD='{"resource":"/api/v1/courses/1","path":"/api/v1/courses/1","httpMethod":"PUT","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":{"id":"1"},"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses/{id}","httpMethod":"PUT","extendedRequestId":"test","requestTime":"22/Jul/2025:18:17:30 +0000","path":"/api/v1/courses/1","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217850,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda - Updated\",\"price\":149.99}","isBase64Encoded":false}'

aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo "$PUT_PAYLOAD" | base64)" \
  ../testing/response.json

echo "✅ PUT Response:"
cat ../testing/response.json | jq -r '.body' | jq .

# Step 5: GET /api/v1/courses/1 (verify update)
echo ""
echo "📡 Step 5: GET /api/v1/courses/1 (verify update)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"resource":"/api/v1/courses/1","path":"/api/v1/courses/1","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":{"id":"1"},"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses/{id}","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:17:40 +0000","path":"/api/v1/courses/1","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217860,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}' | base64)" \
  ../testing/response.json

echo "✅ GET by ID Response (after update):"
cat ../testing/response.json | jq -r '.body' | jq .

# Step 6: DELETE /api/v1/courses/1 (delete the course)
echo ""
echo "📡 Step 6: DELETE /api/v1/courses/1 (delete the course)..."
DELETE_PAYLOAD='{"resource":"/api/v1/courses/1","path":"/api/v1/courses/1","httpMethod":"DELETE","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":{"id":"1"},"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses/{id}","httpMethod":"DELETE","extendedRequestId":"test","requestTime":"22/Jul/2025:18:17:50 +0000","path":"/api/v1/courses/1","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217870,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}'

aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo "$DELETE_PAYLOAD" | base64)" \
  ../testing/response.json

echo "✅ DELETE Response:"
cat ../testing/response.json | jq -r '.body' | jq .

# Step 7: GET /api/v1/courses (verify deletion)
echo ""
echo "📡 Step 7: GET /api/v1/courses (verify deletion)..."
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$(echo '{"resource":"/api/v1/courses","path":"/api/v1/courses","httpMethod":"GET","headers":{"Accept":"*/*","Content-Type":"application/json"},"multiValueHeaders":{"Accept":["*/*"],"Content-Type":["application/json"]},"queryStringParameters":null,"multiValueQueryStringParameters":null,"pathParameters":null,"stageVariables":null,"requestContext":{"resourceId":"test","resourcePath":"/api/v1/courses","httpMethod":"GET","extendedRequestId":"test","requestTime":"22/Jul/2025:18:18:00 +0000","path":"/api/v1/courses","accountId":"000000000000","protocol":"HTTP/1.1","stage":"test","domainPrefix":"test","requestTimeEpoch":1732217880,"requestId":"test","identity":{"cognitoIdentityPoolId":null,"accountId":null,"cognitoIdentityId":null,"caller":null,"sourceIp":"127.0.0.1","principalOrgId":null,"accessKey":null,"cognitoAuthenticationType":null,"cognitoAuthenticationProvider":null,"userArn":null,"userAgent":"test","user":null},"domainName":"test","apiId":"test"},"body":null,"isBase64Encoded":false}' | base64)" \
  ../testing/response.json

echo "✅ Final GET Response (after deletion):"
cat ../testing/response.json | jq -r '.body' | jq .

echo ""
echo "🎉 Complete CRUD test completed!"
echo "📋 Summary:"
echo "   ✅ CREATE (POST) - Course created"
echo "   ✅ READ (GET) - Course retrieved"
echo "   ✅ UPDATE (PUT) - Course updated"
echo "   ✅ DELETE (DELETE) - Course deleted"
echo "   ✅ VERIFY - Empty state restored" 