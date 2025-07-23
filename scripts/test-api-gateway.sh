#!/bin/bash

# API Gateway Test Script
# This script tests the Spring Boot Lambda application via API Gateway

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_warning "jq is not installed. JSON responses will not be formatted."
        JQ_AVAILABLE=false
    else
        JQ_AVAILABLE=true
    fi
    
    print_success "Dependencies check completed"
}

# Function to get API Gateway URL
get_api_url() {
    if [ -f "terraform/terraform.tfvars.localstack" ]; then
        # LocalStack environment
        API_BASE_URL="http://localhost:4566/restapis"
        API_ID=$(terraform -chdir=terraform output -raw api_gateway_id 2>/dev/null || echo "")
        STAGE_NAME="dev"
        
        if [ -n "$API_ID" ]; then
            API_URL="${API_BASE_URL}/${API_ID}/${STAGE_NAME}/_user_request_"
        else
            print_error "Could not retrieve API Gateway ID from Terraform output"
            print_status "Please ensure LocalStack is running and Terraform has been applied"
            exit 1
        fi
    else
        # AWS environment
        API_URL=$(terraform -chdir=terraform output -raw api_gateway_invoke_url 2>/dev/null || echo "")
        
        if [ -z "$API_URL" ]; then
            print_error "Could not retrieve API Gateway URL from Terraform output"
            print_status "Please ensure Terraform has been applied to AWS"
            exit 1
        fi
    fi
    
    print_status "Using API Gateway URL: $API_URL"
}

# Function to make HTTP requests
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    
    local url="${API_URL}${endpoint}"
    local curl_opts="-s -w '\nHTTP_STATUS:%{http_code}\nTIME:%{time_total}s'"
    
    if [ -n "$data" ]; then
        curl_opts="$curl_opts -H 'Content-Type: application/json' -d '$data'"
    fi
    
    print_status "Testing $method $endpoint"
    
    local response=$(curl -X $method $curl_opts "$url" 2>/dev/null)
    local http_status=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
    local time_taken=$(echo "$response" | grep "TIME:" | cut -d: -f2)
    local body=$(echo "$response" | sed '/HTTP_STATUS:/d' | sed '/TIME:/d')
    
    if [ "$http_status" = "$expected_status" ]; then
        print_success "$method $endpoint - Status: $http_status (${time_taken}s)"
        if [ "$JQ_AVAILABLE" = true ] && [ -n "$body" ]; then
            echo "$body" | jq '.' 2>/dev/null || echo "$body"
        else
            echo "$body"
        fi
    else
        print_error "$method $endpoint - Expected: $expected_status, Got: $http_status (${time_taken}s)"
        echo "$body"
    fi
    
    echo ""
}

# Function to test health endpoints
test_health_endpoints() {
    print_status "Testing health endpoints..."
    
    make_request "GET" "/ping" "" "200"
    make_request "GET" "/checking" "" "200"
}

# Function to test course endpoints
test_course_endpoints() {
    print_status "Testing course endpoints..."
    
    # Test data
    local course1='{"name":"Introduction to Computer Science","price":299.99}'
    local course2='{"name":"Advanced Mathematics","price":399.99}'
    local updated_course='{"name":"Introduction to Computer Science - Updated","price":349.99}'
    
    # Create courses
    print_status "Creating test courses..."
    make_request "POST" "/api/v1/courses" "$course1" "201"
    make_request "POST" "/api/v1/courses" "$course2" "201"
    
    # Get all courses
    print_status "Retrieving all courses..."
    make_request "GET" "/api/v1/courses" "" "200"
    
    # Get course by ID (we'll need to extract the ID from the response)
    print_status "Retrieving course by ID..."
    local course_response=$(curl -s "${API_URL}/api/v1/courses" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$course_response" ]; then
        make_request "GET" "/api/v1/courses/$course_response" "" "200"
        make_request "GET" "/api/v1/courses/NONEXISTENT" "" "404"
        
        # Get course by name
        print_status "Retrieving course by name..."
        make_request "GET" "/api/v1/courses/name/Introduction%20to%20Computer%20Science" "" "200"
        make_request "GET" "/api/v1/courses/name/NONEXISTENT" "" "404"
        
        # Update course
        print_status "Updating course..."
        make_request "PUT" "/api/v1/courses/$course_response" "$updated_course" "204"
        make_request "PUT" "/api/v1/courses/NONEXISTENT" "$updated_course" "404"
        
        # Verify update
        print_status "Verifying course update..."
        make_request "GET" "/api/v1/courses/$course_response" "" "200"
        
        # Delete course
        print_status "Deleting course..."
        make_request "DELETE" "/api/v1/courses/$course_response" "" "204"
        make_request "DELETE" "/api/v1/courses/NONEXISTENT" "" "404"
        
        # Verify deletion
        print_status "Verifying course deletion..."
        make_request "GET" "/api/v1/courses/$course_response" "" "404"
    else
        print_warning "Could not extract course ID for testing individual operations"
    fi
    
    # Clean up remaining courses
    print_status "Cleaning up remaining courses..."
    local remaining_courses=$(curl -s "${API_URL}/api/v1/courses" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    for course_id in $remaining_courses; do
        make_request "DELETE" "/api/v1/courses/$course_id" "" "204"
    done
}

# Function to test error handling
test_error_handling() {
    print_status "Testing error handling..."
    
    # Test invalid JSON
    make_request "POST" "/api/v1/courses" '{"invalid": json}' "400"
    
    # Test missing required fields
    make_request "POST" "/api/v1/courses" '{"name":"Test Course"}' "400"  # Missing price
    make_request "POST" "/api/v1/courses" '{"price":299.99}' "400"        # Missing name
    
    # Test invalid price (must be greater than 0)
    make_request "POST" "/api/v1/courses" '{"name":"Test Course","price":0}' "400"
    make_request "POST" "/api/v1/courses" '{"name":"Test Course","price":-10}' "400"
    
    # Test unsupported method
    make_request "PATCH" "/api/v1/courses" "" "404"
    
    # Test invalid endpoint
    make_request "GET" "/api/v1/invalid" "" "404"
}

# Function to run performance test
run_performance_test() {
    print_status "Running performance test (10 requests to /ping)..."
    
    local total_time=0
    local success_count=0
    
    for i in {1..10}; do
        local start_time=$(date +%s.%N)
        local response=$(curl -s -w "%{http_code}" -o /dev/null "${API_URL}/ping")
        local end_time=$(date +%s.%N)
        
        local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0")
        total_time=$(echo "$total_time + $duration" | bc -l 2>/dev/null || echo "0")
        
        if [ "$response" = "200" ]; then
            success_count=$((success_count + 1))
        fi
        
        echo -n "."
    done
    
    echo ""
    local avg_time=$(echo "$total_time / 10" | bc -l 2>/dev/null || echo "0")
    print_success "Performance test completed: $success_count/10 successful requests"
    print_status "Average response time: ${avg_time}s"
}

# Main execution
main() {
    echo "=========================================="
    echo "API Gateway Test Script"
    echo "=========================================="
    echo ""
    
    check_dependencies
    get_api_url
    
    echo "Starting API Gateway tests..."
    echo ""
    
    # Test health endpoints
    test_health_endpoints
    
    # Test course endpoints
    test_course_endpoints
    
    # Test error handling
    test_error_handling
    
    # Run performance test
    run_performance_test
    
    echo "=========================================="
    print_success "All tests completed!"
    echo "=========================================="
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 