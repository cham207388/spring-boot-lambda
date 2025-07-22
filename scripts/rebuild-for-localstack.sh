#!/bin/bash

# Rebuild Lambda package for LocalStack compatibility (Apple Silicon M3)
set -e

echo "🔧 Rebuilding Lambda package for LocalStack compatibility (Apple Silicon M3)..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
mvn clean

# Build with ARM64 platform settings for Apple Silicon
echo "🏗️  Building Lambda package for ARM64..."
export DOCKER_DEFAULT_PLATFORM=linux/arm64
mvn clean package -Ddocker.platform=linux/arm64

# Verify the package was created
if [ -f "target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip" ]; then
    echo "✅ Lambda package created successfully"
    echo "📦 Package size: $(ls -lh target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip | awk '{print $5}')"
    echo "🏗️  Architecture: ARM64 (Apple Silicon compatible)"
else
    echo "❌ Lambda package not found"
    exit 1
fi

echo ""
echo "🚀 Next steps:"
echo "1. Restart LocalStack: make ls-stop && make ls-start"
echo "2. Redeploy: make ls-deploy"
echo "3. Test: make ls-test" 