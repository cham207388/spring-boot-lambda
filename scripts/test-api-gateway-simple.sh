#!/bin/bash

# Simple API Gateway Test Script
# Quick test for basic functionality

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get API URL
if [ -f "terraform/terraform.tfvars.localstack" ]; then
    # LocalStack
    API_ID=$(terraform -chdir=terraform output -raw api_gateway_id 2>/dev/null || echo "")
    API_URL="http://localhost:4566/restapis/${API_ID}/dev/_user_request_"
else
    # AWS
    API_URL=$(terraform -chdir=terraform output -raw api_gateway_invoke_url 2>/dev/null || echo "")
fi

if [ -z "$API_URL" ]; then
    print_error "Could not get API Gateway URL"
    exit 1
fi

print_status "Testing API Gateway at: $API_URL"

# Test health endpoints
echo ""
print_status "Testing health endpoints..."
curl -s "${API_URL}/ping" | jq '.' 2>/dev/null || curl -s "${API_URL}/ping"
echo ""

# Test course creation
echo ""
print_status "Creating a test course..."
COURSE_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"name":"Test Course","price":299.99}' \
    "${API_URL}/api/v1/courses")

echo "$COURSE_RESPONSE" | jq '.' 2>/dev/null || echo "$COURSE_RESPONSE"

# Extract course ID for further testing
COURSE_ID=$(echo "$COURSE_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

if [ -n "$COURSE_ID" ]; then
    echo ""
    print_status "Testing get course by ID: $COURSE_ID"
    curl -s "${API_URL}/api/v1/courses/$COURSE_ID" | jq '.' 2>/dev/null || curl -s "${API_URL}/api/v1/courses/$COURSE_ID"
    
    echo ""
    print_status "Testing get all courses..."
    curl -s "${API_URL}/api/v1/courses" | jq '.' 2>/dev/null || curl -s "${API_URL}/api/v1/courses"
    
    echo ""
    print_status "Testing update course..."
    curl -s -X PUT \
        -H "Content-Type: application/json" \
        -d '{"name":"Updated Test Course","price":349.99}' \
        "${API_URL}/api/v1/courses/$COURSE_ID"
    echo ""
    
    echo ""
    print_status "Testing delete course..."
    curl -s -X DELETE "${API_URL}/api/v1/courses/$COURSE_ID"
    echo ""
    
    print_success "Basic CRUD operations completed successfully!"
else
    print_error "Could not extract course ID from response"
fi 