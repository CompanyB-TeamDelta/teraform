provider "aws" {
  region = "us-east-1"
}

module "lambda_python3" {
  source = "${path.module}/../../task-scheduler/"

  function_name = "terraform-aws-lambda-test-python3-from-python3"
  description   = "Test python3 runtime from python3 environment in terraform-aws-lambda"
  handler       = "main.lambda_handler"
  runtime       = "python3.7"
  timeout       = 5

  source_path = "${path.module}/../../task-scheduler/"
}
