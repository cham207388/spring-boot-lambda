#!/bin/bash

set -e

LAMBDA_NAME="springboot-course-api"
API_NAME="springboot-api"
STAGE_NAME="dev"
REGION="us-east-1"
ACCOUNT_ID="000000000000"

echo "🚀 Creating REST API: $API_NAME..."
API_ID=$(awslocal apigateway create-rest-api \
  --name "$API_NAME" \
  --query 'id' \
  --output text)
echo "✅ API ID: $API_ID"

echo "🔍 Fetching Root Resource ID..."
ROOT_ID=$(awslocal apigateway get-resources \
  --rest-api-id "$API_ID" \
  --query 'items[?path==`/`].id' \
  --output text)
echo "✅ Root Resource ID: $ROOT_ID"

echo "🔧 Creating '{proxy+}' resource..."
RESOURCE_ID=$(awslocal apigateway create-resource \
  --rest-api-id "$API_ID" \
  --parent-id "$ROOT_ID" \
  --path-part '{proxy+}' \
  --query 'id' \
  --output text)
echo "✅ Proxy Resource ID: $RESOURCE_ID"

echo "🔁 Setting up ANY method..."
awslocal apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$RESOURCE_ID" \
  --http-method ANY \
  --authorization-type "NONE"

echo "🔗 Linking API Gateway to Lambda: $LAMBDA_NAME..."
awslocal apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$RESOURCE_ID" \
  --http-method ANY \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:${LAMBDA_NAME}/invocations"

echo "🔐 Adding invoke permission to Lambda..."
awslocal lambda add-permission \
  --function-name "$LAMBDA_NAME" \
  --statement-id "apigateway-access" \
  --action "lambda:InvokeFunction" \
  --principal "apigateway.amazonaws.com" \
  --source-arn "arn:aws:execute-api:${REGION}:${ACCOUNT_ID}:${API_ID}/*/*/*"

echo "🚀 Deploying API to stage: $STAGE_NAME..."
awslocal apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name "$STAGE_NAME"

echo "🌐 API is live!"

echo ""
echo "✅ Test it with:"
echo "curl http://localhost:4566/restapis/$API_ID/$STAGE_NAME/_user_request_/api/v1/courses"
echo "or"
echo "curl http://$API_ID.execute-api.localhost.localstack.cloud:4566/$STAGE_NAME/api/v1/courses"