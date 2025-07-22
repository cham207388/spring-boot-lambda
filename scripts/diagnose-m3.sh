#!/bin/bash

# Apple Silicon M3 Diagnostic Script
set -e

echo "🍎 Apple Silicon M3 Diagnostic Report"
echo "======================================"

# System Information
echo ""
echo "📋 System Information:"
echo "   Architecture: $(uname -m)"
echo "   OS: $(uname -s)"
echo "   Kernel: $(uname -r)"
echo "   Processor: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")"

# Docker Information
echo ""
echo "🐳 Docker Information:"
if command -v docker &> /dev/null; then
    echo "   Docker Version: $(docker --version)"
    echo "   Docker Platform: $(docker version --format '{{.Server.Os}}/{{.Server.Arch}}')"
    
    if docker info &> /dev/null; then
        echo "   Docker Status: ✅ Running"
        echo "   Docker Root Dir: $(docker info --format '{{.DockerRootDir}}')"
    else
        echo "   Docker Status: ❌ Not running"
    fi
else
    echo "   Docker: ❌ Not installed"
fi

# LocalStack Status
echo ""
echo "🏗️  LocalStack Status:"
if docker ps | grep -q localstack; then
    echo "   Status: ✅ Running"
    echo "   Container: $(docker ps --filter "name=localstack" --format "{{.Names}}")"
    echo "   Platform: $(docker inspect spring-boot-lambda-localstack --format '{{.Architecture}}' 2>/dev/null || echo "Unknown")"
else
    echo "   Status: ❌ Not running"
fi

# Lambda Package Information
echo ""
echo "📦 Lambda Package Information:"
if [ -f "target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip" ]; then
    echo "   Package: ✅ Exists"
    echo "   Size: $(ls -lh target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip | awk '{print $5}')"
    echo "   Created: $(ls -l target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip | awk '{print $6, $7, $8}')"
    
    # Check if package contains ARM64 binaries
    if unzip -l target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip | grep -q "bootstrap"; then
        echo "   Bootstrap: ✅ Found"
    else
        echo "   Bootstrap: ❌ Not found"
    fi
else
    echo "   Package: ❌ Not found"
fi

# LocalStack Health Check
echo ""
echo "🏥 LocalStack Health Check:"
if curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo "   Health: ✅ Responding"
    echo "   Services:"
    curl -s http://localhost:4566/_localstack/health | jq -r '.services | to_entries[] | "     \(.key): \(.value)"' 2>/dev/null || echo "     Unable to parse services"
else
    echo "   Health: ❌ Not responding"
fi

# Lambda Function Status
echo ""
echo "⚡ Lambda Function Status:"
cd terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "springboot-course-api")

if aws --endpoint-url=http://localhost:4566 lambda get-function --function-name "$FUNCTION_NAME" 2>/dev/null; then
    echo "   Function: ✅ Exists"
    echo "   Name: $FUNCTION_NAME"
    
    # Get function configuration
    CONFIG=$(aws --endpoint-url=http://localhost:4566 lambda get-function-configuration --function-name "$FUNCTION_NAME" 2>/dev/null)
    echo "   Runtime: $(echo "$CONFIG" | jq -r '.Runtime')"
    echo "   Handler: $(echo "$CONFIG" | jq -r '.Handler')"
    echo "   Timeout: $(echo "$CONFIG" | jq -r '.Timeout')"
    echo "   Memory: $(echo "$CONFIG" | jq -r '.MemorySize') MB"
else
    echo "   Function: ❌ Not found"
fi
cd ..

# Architecture Compatibility Check
echo ""
echo "🔍 Architecture Compatibility:"
if [[ $(uname -m) == "arm64" ]]; then
    echo "   Host Architecture: ✅ ARM64 (Apple Silicon)"
    echo "   Docker Platform: $(docker version --format '{{.Server.Arch}}')"
    
    if [[ $(docker version --format '{{.Server.Arch}}') == "arm64" ]]; then
        echo "   Compatibility: ✅ Native ARM64"
    else
        echo "   Compatibility: ⚠️  Running under Rosetta"
    fi
else
    echo "   Host Architecture: ❌ Not ARM64"
fi

echo ""
echo "💡 Recommendations for Apple Silicon M3:"
echo "   1. Ensure Docker Desktop is configured for ARM64"
echo "   2. Use 'make setup-m3' for complete setup"
echo "   3. Lambda cold starts may take 1-2 minutes"
echo "   4. Monitor with 'make ls-logs' for detailed logs" 