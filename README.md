# Spring-boot-lambda serverless API

- [Spring-boot-lambda serverless API](#spring-boot-lambda-serverless-api)
  - [Pre-requisites](#pre-requisites)
  - [Creating the project](#creating-the-project)
  - [Building the project](#building-the-project)
  - [Testing locally with LocalStack](#testing-locally-with-localstack)
  - [Deploying to AWS with Terraform](#deploying-to-aws-with-terraform)
  - [Manual Deploy](#manual-deploy)
    - [Testing on AWS Lambda Console](#testing-on-aws-lambda-console)
  - [Manually create API Gateway frontend](#manually-create-api-gateway-frontend)
  - [Automate](#automate)
    - [create ACM certificate](#create-acm-certificate)
  - [Resources](#resources)
  - [Playground](#playground)
    - [Fixing swagger issue behind api-gateway](#fixing-swagger-issue-behind-api-gateway)


The spring-boot-lambda project, created with [`aws-serverless-java-container`](https://github.com/aws/serverless-java-container).

The starter project defines a simple `/ping` resource that can accept `GET` requests with its tests.
I added Course Resource

This project uses Java 21 and Terraform for infrastructure as code to deploy to AWS Lambda and Amazon API Gateway.

## Pre-requisites
* [Java 21](https://adoptium.net/) (JDK 21)
* [AWS CLI](https://aws.amazon.com/cli/)
* [Terraform](https://www.terraform.io/)
* [Maven](https://maven.apache.org/)
* [Docker](https://www.docker.com/) (for LocalStack testing)

## Creating the project

To scaffold a new Spring Boot Lambda project from scratch:

```bash
mvn archetype:generate \
  -DartifactId=your-artifact-id \
  -DarchetypeGroupId=com.amazonaws.serverless.archetypes \
  -DarchetypeArtifactId=aws-serverless-jersey-archetype \
  -DarchetypeVersion=2.1.2 \
  -DgroupId=your.group.id \
  -Dversion=1.0-SNAPSHOT \
  -Dinteractive=false
```

```bash
cd your-artifact-id
```

This will create a basic Spring Boot Lambda project with:
- Maven project structure
- Basic Jersey REST endpoints
- Lambda handler configuration
- Sample `/ping` endpoint

## Building the project
You can build the project using Maven:

```bash
$ mvn clean package
```

This will create a JAR file in the `target` directory that can be deployed to AWS Lambda.

## Testing locally with LocalStack

You can test the application locally using LocalStack, which provides a local AWS cloud stack:

### Start LocalStack

```bash
$ make ls-start
```

### Build and deploy to LocalStack

```bash
$ make ls-deploy
```

### Test the API

```bash
$ make ls-test
```

### POST with default course name ("Spring Boot with AWS Lambda")

```bash
$ make ls-test-post
```

### POST with custom course name

```bash
$ make ls-test-post NAME="Advanced Java Programming"
```

### GET all courses

```bash
$ make ls-test-get
```

### GET a course by id (default: id=1)

```bash
$ make ls-test-get-id
```

### GET a course by specific id

```bash
$ make ls-test-get-id ID=123
```

### GET a course by name (default: "Spring Boot with AWS Lambda")

```bash
$ make ls-test-get-name
```

### GET a course by specific name

```bash
$ make ls-test-get-name NAME="Advanced Java Programming"
```

### PUT a course

```bash
$ make ls-test-put
```

### DELETE a course

```bash
$ make ls-test-delete
```

## Deploying to AWS with Terraform

To deploy the application to AWS using Terraform:

1. Navigate to the terraform directory:
```bash
$ cd terraform
```

2. Initialize Terraform:
```bash
$ terraform init
```

3. Review the plan:
```bash
$ terraform plan -var-file="terraform.tfvars.aws"
```

4. Deploy the infrastructure:
```bash
$ terraform apply -var-file="terraform.tfvars.aws"
```

The deployment will create:
- Lambda function
- API Gateway
- DynamoDB table
- IAM roles and policies
- Route53 records (if configured)

Once deployed, you can access your API at the provided URL.

## Manual Deploy

- create lambda
- name, java21, x86_64
  - edit handler com.abc.StreamLambdaHandler::handleRequest

### Testing on AWS Lambda Console

- test
- api-gateway-proxy
- change the path and httpMethod

## Manually create API Gateway frontend

- create
- Rest api
- / {proxy+}

## Automate

I use terraform to create a lambda function and api gateway frontend

- build the project
- use the .zip file to upload to lambda
- let api gateway points to this function

### create ACM certificate

- use the url you want: dev.your-domain.com or *.your-domain.com
- wait for the certificate to be issued
- then api-gateway will create this A alias record: dev.your-domain.com (or what matches the wildcard) in router53
- note the acm arn once it's issued. I save my in gh secrets. There was an error retrieving it using tf data block
- configure tf api gateway and route53
- deploy
- access your base url dev.alhagiebaicham.com/

## Resources

- [medium 1](https://medium.com/@javatechie/deploying-spring-boot-applications-to-aws-lambda-with-api-gateway-ae5c810008e5)
- [aws-serverless](https://github.com/aws/serverless-java-container)

## Playground

### Fixing swagger issue behind api-gateway

error

```text
Uncaught SyntaxError: Invalid or unexpected token in swagger-ui-bundle.js
swagger-initializer.js:5 Uncaught ReferenceError: SwaggerUIBundle is not defined
```

- update api gateway tf config for binary media types
- create StaticResourceConfig
