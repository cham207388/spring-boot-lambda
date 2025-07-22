.PHONY: help ls-deploy aws-deploy ls-start ls-stop ls-logs ls-test ls-check build clean ls-cleanup

LAMBDA_DIR = ./lambda
TERRAFORM_DIR = ./terraform

help: ## Show this help message with aligned shortcuts, descriptions, and commands
	@awk 'BEGIN {FS = ":"; printf "\033[1m%-20s %-40s %s\033[0m\n", "Target", "Description", "Command"} \
	/^[a-zA-Z_-]+:/ { \
		target=$$1; \
		desc=""; cmd="(no command)"; \
		if ($$2 ~ /##/) { sub(/^.*## /, "", $$2); desc=$$2; } \
		getline; \
		if ($$0 ~ /^(\t|@)/) { cmd=$$0; sub(/^(\t|@)/, "", cmd); } \
		printf "%-20s %-40s %s\n", target, desc, cmd; \
	}' $(MAKEFILE_LIST)

# Build targets
build: ## Build the Lambda package
	mvn clean package

build-localstack: ## Build Lambda package for LocalStack (correct architecture)
	./scripts/rebuild-for-localstack.sh

setup-m3: ## Complete setup for Apple Silicon M3
	./scripts/setup-apple-silicon.sh

diagnose-m3: ## Diagnose Apple Silicon M3 setup
	./scripts/diagnose-m3.sh

clean: ## Clean build artifacts
	mvn clean
	rm -f scripts/response.json
	rm -f terraform/response.json

# LocalStack management
ls-start: ## Start LocalStack with Docker Compose
	./scripts/localstack-start.sh

ls-stop: ## Stop LocalStack
	./scripts/localstack-stop.sh

ls-logs: ## View LocalStack logs
	./scripts/localstack-logs.sh

ls-check: ## Check LocalStack status and Lambda function
	./scripts/check-localstack.sh

ls-health: ## Check LocalStack health endpoint
	curl http://localhost:4566/_localstack/health

ls-cleanup: ## Clean up LocalStack completely
	./scripts/localstack-cleanup.sh

# Deployment targets
ls-deploy: ## Deploy to LocalStack
	./scripts/deploy-localstack.sh

aws-deploy: ## Deploy to AWS
	./scripts/deploy-aws.sh

# Testing targets
ls-test: ## Test Lambda function with retry logic
	./scripts/test-simple.sh

ls-test-full: ## Run full test suite
	./scripts/test-localstack.sh

# Development workflow
dev-setup: ## Complete development setup (cleanup + build + start + deploy)
	@echo "🚀 Setting up development environment..."
	$(MAKE) ls-cleanup
	$(MAKE) build
	$(MAKE) ls-start
	@echo "⏳ Waiting for LocalStack to be ready..."
	@sleep 15
	$(MAKE) ls-deploy
	@echo "✅ Development environment ready!"
	@echo "🧪 Test with: make ls-test"

dev-cleanup: ## Clean up development environment
	@echo "🧹 Cleaning up development environment..."
	$(MAKE) ls-stop
	$(MAKE) clean
	@echo "✅ Cleanup complete!"

# Quick development commands
dev: ## Quick development cycle (build + deploy + test)
	$(MAKE) build
	$(MAKE) ls-deploy
	$(MAKE) ls-test

# Terraform commands
tf-init: ## Initialize Terraform
	cd terraform && terraform init

tf-plan-ls: ## Plan Terraform for LocalStack
	cd terraform && terraform plan -var-file="terraform.tfvars.localstack"

tf-plan-aws: ## Plan Terraform for AWS
	cd terraform && terraform plan -var-file="terraform.tfvars.aws"

tf-apply-ls: ## Apply Terraform to LocalStack
	cd terraform && terraform apply -var-file="terraform.tfvars.localstack" -auto-approve

tf-apply-aws: ## Apply Terraform to AWS
	cd terraform && terraform apply -var-file="terraform.tfvars.aws" -auto-approve

tf-destroy-ls: ## Destroy LocalStack resources
	cd terraform && terraform destroy -var-file="terraform.tfvars.localstack" -auto-approve

tf-destroy-aws: ## Destroy AWS resources
	cd terraform && terraform destroy -var-file="terraform.tfvars.aws" -auto-approve

# Utility commands
status: ## Show current status
	@echo "📋 Current status:"
	@echo "🔍 LocalStack: $(shell if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then echo "✅ Running"; else echo "❌ Not running"; fi)"
	@echo "📦 Lambda package: $(shell if [ -f target/spring-boot-lambda-1.0-SNAPSHOT-lambda-package.zip ]; then echo "✅ Built"; else echo "❌ Not built"; fi)"
	@echo "🏗️  Terraform state: $(shell if [ -f terraform/.terraform ]; then echo "✅ Initialized"; else echo "❌ Not initialized"; fi)"

logs: ## Show all relevant logs
	@echo "📋 LocalStack logs:"
	@docker-compose logs --tail=20 localstack 2>/dev/null || echo "LocalStack not running"
	@echo ""
	@echo "📋 Lambda function logs (if available):"
	@aws --endpoint-url=http://localhost:4566 logs describe-log-groups --log-group-name-prefix "/aws/lambda/springboot-course-api" 2>/dev/null || echo "No log groups found"
