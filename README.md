# Spring-boot-lambda serverless API

- [Spring-boot-lambda serverless API](#spring-boot-lambda-serverless-api)
  - [Pre-requisites](#pre-requisites)
  - [Building the project](#building-the-project)
  - [Testing locally with the SAM CLI](#testing-locally-with-the-sam-cli)
  - [Deploying to AWS](#deploying-to-aws)
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

The project folder also includes a `template.yml` file. You can use this [SAM](https://github.com/awslabs/serverless-application-model) file to deploy the project to AWS Lambda and Amazon API Gateway or test in local with the [SAM CLI](https://github.com/awslabs/aws-sam-cli). 

## Pre-requisites
* [AWS CLI](https://aws.amazon.com/cli/)
* [SAM CLI](https://github.com/awslabs/aws-sam-cli)
* [Gradle](https://gradle.org/) or [Maven](https://maven.apache.org/)

## Building the project
You can use the SAM CLI to quickly build the project
```bash
$ mvn archetype:generate -DartifactId=spring-boot-lambda -DarchetypeGroupId=com.amazonaws.serverless.archetypes -DarchetypeArtifactId=aws-serverless-jersey-archetype -DarchetypeVersion=2.1.2 -DgroupId=com.abc -Dversion=1.0-SNAPSHOT -Dinteractive=false
$ cd spring-boot-lambda
$ sam build
Building resource 'SpringBootLambdaFunction'
Running JavaGradleWorkflow:GradleBuild
Running JavaGradleWorkflow:CopyArtifacts

Build Succeeded

Built Artifacts  : .aws-sam/build
Built Template   : .aws-sam/build/template.yaml

Commands you can use next
=========================
[*] Invoke Function: sam local invoke
[*] Deploy: sam deploy --guided
```

## Testing locally with the SAM CLI

From the project root folder - where the `template.yml` file is located - start the API with the SAM CLI.

```bash
$ sam local start-api

...
Mounting com.amazonaws.serverless.archetypes.StreamLambdaHandler::handleRequest (java11) at http://127.0.0.1:3000/{proxy+} [OPTIONS GET HEAD POST PUT DELETE PATCH]
...
```

Using a new shell, you can send a test ping request to your API:

```bash
$ curl -s http://127.0.0.1:3000/ping | python -m json.tool

{
    "pong": "Hello, World!"
}
``` 

## Deploying to AWS
To deploy the application in your AWS account, you can use the SAM CLI's guided deployment process and follow the instructions on the screen

```
$ sam deploy --guided
```

Once the deployment is completed, the SAM CLI will print out the stack's outputs, including the new application URL. You can use `curl` or a web browser to make a call to the URL

```
...
-------------------------------------------------------------------------------------------------------------
OutputKey-Description                        OutputValue
-------------------------------------------------------------------------------------------------------------
SpringBootLambdaApi - URL for application            https://xxxxxxxxxx.execute-api.us-west-2.amazonaws.com/Prod/pets
-------------------------------------------------------------------------------------------------------------
```

Copy the `OutputValue` into a browser or use curl to test your first request:

```bash
$ curl -s https://xxxxxxx.execute-api.us-west-2.amazonaws.com/Prod/ping | python -m json.tool

{
    "pong": "Hello, World!"
}
```

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


