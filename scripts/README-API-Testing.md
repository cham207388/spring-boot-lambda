# API Gateway Testing Scripts

This directory contains scripts to test the Spring Boot Lambda application via API Gateway.

## Available Scripts

### 1. `test-api-gateway.sh` - Comprehensive Test Suite
A full-featured test script that covers:
- Health endpoint testing (`/ping`, `/checking`)
- Complete CRUD operations for courses
- Error handling and validation testing
- Performance testing (10 requests to `/ping`)
- Automatic cleanup of test data

**Features:**
- Colored output for better readability
- Dependency checking (curl, jq)
- Automatic API URL detection (LocalStack vs AWS)
- Response time measurement
- JSON formatting (if jq is available)
- Comprehensive error scenarios

### 2. `test-api-gateway-simple.sh` - Quick Test
A simplified version for quick testing of basic functionality:
- Health check
- Create a single course
- Get course by ID
- Get all courses
- Update course
- Delete course

## Prerequisites

1. **curl** - Required for HTTP requests
2. **jq** - Optional, for JSON formatting
3. **bc** - Optional, for performance calculations
4. **Terraform** - For retrieving API Gateway URLs

## Usage

### For LocalStack Testing

1. Ensure LocalStack is running:
   ```bash
   ./scripts/localstack-start.sh
   ```

2. Deploy to LocalStack:
   ```bash
   ./scripts/deploy-localstack.sh
   ```

3. Run the comprehensive test:
   ```bash
   ./scripts/test-api-gateway.sh
   ```

4. Or run the simple test:
   ```bash
   ./scripts/test-api-gateway-simple.sh
   ```

### For AWS Testing

1. Deploy to AWS:
   ```bash
   ./scripts/deploy-aws.sh
   ```

2. Run the comprehensive test:
   ```bash
   ./scripts/test-api-gateway.sh
   ```

3. Or run the simple test:
   ```bash
   ./scripts/test-api-gateway-simple.sh
   ```

## Course Model Structure

The test scripts are configured for the following Course model:

```json
{
  "id": "auto-generated-uuid",
  "name": "Course Name (required, not blank)",
  "price": 299.99 (required, must be > 0)
}
```

## API Endpoints Tested

### Health Endpoints
- `GET /ping` - Returns pong message
- `GET /checking` - Returns health status with timestamp

### Course Endpoints
- `POST /api/v1/courses` - Create a new course
- `GET /api/v1/courses` - Get all courses
- `GET /api/v1/courses/{id}` - Get course by ID
- `GET /api/v1/courses/name/{name}` - Get course by name
- `PUT /api/v1/courses/{id}` - Update course
- `DELETE /api/v1/courses/{id}` - Delete course

## Error Scenarios Tested

- Invalid JSON payload
- Missing required fields (name, price)
- Invalid price values (0, negative)
- Non-existent course IDs
- Unsupported HTTP methods
- Invalid endpoints

## Output Format

The scripts provide colored output:
- 🔵 **Blue** - Information messages
- 🟢 **Green** - Success messages
- 🔴 **Red** - Error messages
- 🟡 **Yellow** - Warning messages

Each request shows:
- HTTP method and endpoint
- Expected vs actual status code
- Response time
- Formatted JSON response (if jq is available)

## Troubleshooting

### Common Issues

1. **"Could not get API Gateway URL"**
   - Ensure Terraform has been applied
   - Check if LocalStack is running (for local testing)
   - Verify AWS credentials (for AWS testing)

2. **"curl: command not found"**
   - Install curl: `brew install curl` (macOS) or `apt-get install curl` (Ubuntu)

3. **"jq: command not found"**
   - Install jq: `brew install jq` (macOS) or `apt-get install jq` (Ubuntu)
   - Script will work without jq, but JSON won't be formatted

4. **Connection refused**
   - Check if LocalStack is running: `./scripts/localstack-logs.sh`
   - Verify API Gateway deployment: `./scripts/deploy-localstack.sh`

### Debug Mode

To see more detailed output, you can modify the scripts to remove the `-s` flag from curl commands:

```bash
# Change this line in the scripts:
curl -s -X GET "${API_URL}/ping"

# To this:
curl -X GET "${API_URL}/ping"
```

## Performance Testing

The comprehensive script includes a performance test that:
- Makes 10 requests to `/ping`
- Measures response times
- Calculates average response time
- Reports success rate

This helps identify performance issues and cold start delays in Lambda functions. 