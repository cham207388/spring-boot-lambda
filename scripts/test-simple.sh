#!/bin/bash

# Simple Lambda Test Script with Retry Logic
set -e

echo "🧪 Simple Lambda test with retry logic..."

# Get function name
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

echo "📋 Function name: $FUNCTION_NAME"
echo "⏰ Note: Spring Boot Lambda cold start can take 1-2 minutes..."

# Wait for function to be ready (retry logic)
echo "⏳ Waiting for Lambda function to be ready..."
MAX_RETRIES=12  # Increased from 5 to 12 (2 minutes total)
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "🔄 Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES..."
    
    # Try to invoke the function with proper AwsProxyRequest format
    if aws --endpoint-url=http://localhost:4566 lambda invoke \
        --function-name "$FUNCTION_NAME" \
        --payload "$(echo '{
          "resource": "/ping",
          "path": "/ping",
          "httpMethod": "GET",
          "headers": {
            "Accept": "*/*",
            "Content-Type": "application/json"
          },
          "multiValueHeaders": {
            "Accept": ["*/*"],
            "Content-Type": ["application/json"]
          },
          "queryStringParameters": null,
          "multiValueQueryStringParameters": null,
          "pathParameters": null,
          "stageVariables": null,
          "requestContext": {
            "resourceId": "test",
            "resourcePath": "/ping",
            "httpMethod": "GET",
            "extendedRequestId": "test",
            "requestTime": "22/Jul/2025:18:14:16 +0000",
            "path": "/ping",
            "accountId": "000000000000",
            "protocol": "HTTP/1.1",
            "stage": "test",
            "domainPrefix": "test",
            "requestTimeEpoch": 1732217656,
            "requestId": "test",
            "identity": {
              "cognitoIdentityPoolId": null,
              "accountId": null,
              "cognitoIdentityId": null,
              "caller": null,
              "sourceIp": "127.0.0.1",
              "principalOrgId": null,
              "accessKey": null,
              "cognitoAuthenticationType": null,
              "cognitoAuthenticationProvider": null,
              "userArn": null,
              "userAgent": "test",
              "user": null
            },
            "domainName": "test",
            "apiId": "test"
          },
          "body": null,
          "isBase64Encoded": false
        }' | base64)" \
        ../testing/response.json 2>/dev/null; then
        
        echo "✅ Lambda function is ready!"
        echo "📡 Response:"
        cat ../testing/response.json | jq -r '.body' | jq .
rm -f ../testing/response.json
        exit 0
    else
        echo "⏳ Lambda function not ready yet, waiting 10 seconds..."
        echo "   (Spring Boot cold start in progress...)"
        sleep 10
        RETRY_COUNT=$((RETRY_COUNT + 1))
    fi
done

echo "❌ Lambda function failed to start after $MAX_RETRIES attempts (2 minutes)"
echo ""
echo "🔧 Troubleshooting suggestions:"
echo "1. Check LocalStack logs: make ls-logs"
echo "2. Check Lambda function status: make ls-check"
echo "3. Restart LocalStack: make ls-stop && make ls-start"
echo "4. Visit LocalStack Dashboard: https://app.localstack.cloud/"
echo "5. Try manual invocation: aws --endpoint-url=http://localhost:4566 lambda get-function --function-name $FUNCTION_NAME"
exit 1 