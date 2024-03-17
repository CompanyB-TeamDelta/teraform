provider "aws" {
  region = "us-east-1"
}

import {
  to = aws_lambda_function.terraform_lambda_func
  id = "shceduler"
}

resource "aws_lambda_function" "terraform_lambda_func" {

  vpc_config {
    subnet_ids         = ["subnet-073a11bb0b7e99abf"]
    security_group_ids = ["sg-0aa6dd4fa747c9c52"]
  }

  environment {
    variables = {
      DB_HOST = "bar"
    }
  }

  function_name    = "shceduler"
  role             = "arn:aws:iam::531190140983:role/service-role/testFc-role-l1r1aw1v"
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  source_path      = "${path.module}/../../task-scheduler/"
}
