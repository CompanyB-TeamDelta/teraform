provider "aws" {
  region = "us-east-1"
}

import {
  to = aws_lambda_function.terraform_lambda_func
  id = "shceduler"
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/task-scheduler/"
  output_path = "${path.module}/task-scheduler/scheduler.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename         = "${path.module}/task-scheduler/scheduler.zip"
  function_name    = "shceduler"
  role             = "arn:aws:iam::531190140983:role/service-role/testFc-role-l1r1aw1v"
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
}
