# Manual Testing Guide for LocalStack Lambda

This guide shows how to manually test your Spring Boot Lambda function deployed to LocalStack.

## Prerequisites

1. LocalStack running on port 4566
2. Lambda function deployed via Terraform
3. AWS CLI configured for LocalStack

## Get Function Name

First, get your Lambda function name:

```bash
cd terraform
terraform output lambda_function_name
```

## Test Commands

### 1. Health Check
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "springboot-course-api" \
  --payload "$(echo '{"httpMethod":"GET","path":"/ping","headers":{}}' | base64)" \
  ../testing/response.json && cat ../testing/response.json | jq -r '.body' | jq .
```

### 2. Get All Courses
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "springboot-course-api" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses","headers":{"Content-Type":"application/json"}}' | base64)" \
  ../testing/response.json && cat ../testing/response.json | jq -r '.body' | jq .
```

### 3. Create a Course
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "springboot-course-api" \
  --payload "$(echo '{"httpMethod":"POST","path":"/api/v1/courses","headers":{"Content-Type":"application/json"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda\",\"price\":99.99}"}' | base64)" \
  ../testing/response.json && cat ../testing/response.json | jq -r '.body' | jq .
```

### 4. Get Course by ID
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "springboot-course-api" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses/1","headers":{"Content-Type":"application/json"}}' | base64)" \
  ../testing/response.json && cat ../testing/response.json | jq -r '.body' | jq .
```

### 5. Get Course by Name
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "springboot-course-api" \
  --payload "$(echo '{"httpMethod":"GET","path":"/api/v1/courses/name/Spring Boot with AWS Lambda","headers":{"Content-Type":"application/json"}}' | base64)" \
  ../testing/response.json && cat ../testing/response.json | jq -r '.body' | jq .
```

### 6. Update Course
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "springboot-course-api" \
  --payload "$(echo '{"httpMethod":"PUT","path":"/api/v1/courses/1","headers":{"Content-Type":"application/json"},"body":"{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda - Updated\",\"price\":149.99}"}' | base64)" \
  ../testing/response.json && cat ../testing/response.json | jq -r '.body' | jq .
```

### 7. Delete Course
```bash
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name "springboot-course-api" \
  --payload "$(echo '{"httpMethod":"DELETE","path":"/api/v1/courses/1","headers":{"Content-Type":"application/json"}}' | base64)" \
  ../testing/response.json && cat ../testing/response.json | jq -r '.body' | jq .
```

## Expected Responses

### Successful GET /api/v1/courses
```json
{
  "statusCode": 200,
  "body": "[]",
  "headers": {
    "Content-Type": "application/json"
  }
}
```

### Successful POST /api/v1/courses
```json
{
  "statusCode": 201,
  "body": "{\"id\":\"1\",\"name\":\"Spring Boot with AWS Lambda\",\"price\":99.99}",
  "headers": {
    "Content-Type": "application/json"
  }
}
```

### Successful GET /ping
```json
{
  "statusCode": 200,
  "body": "\"pong\"",
  "headers": {
    "Content-Type": "application/json"
  }
}
```

## Troubleshooting

### Check Lambda Function Status
```bash
aws --endpoint-url=http://localhost:4566 lambda get-function --function-name "springboot-course-api"
```

### Check DynamoDB Table
```bash
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name "Course"
```

### View LocalStack Logs
```bash
# Check LocalStack container logs
docker logs <localstack-container-id>
```

### LocalStack Dashboard
Visit: http://localhost:4566/_localstack/dashboard

## Clean Up
```bash
rm -f ../testing/response.json
``` 