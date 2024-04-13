provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket                  = "terraform-s3-state-hwnaukma2024"
    key                     = "lambda"
    region                  = "us-east-1"
    }
}

variable "mssql_pwd" {
  type      = string
  sensitive = true
}

resource "null_resource" "pip_install" {
  triggers = {
    always_change = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "python3 -m pip install -r ${path.module}/../../task-scheduler/requirements.txt -t ${path.module}/../../task-scheduler/package/python"
  }
}

data "archive_file" "layer" {
  type        = "zip"
  source_dir  = "${path.module}/../../task-scheduler/package"
  output_path = "${path.module}/../../task-scheduler/layer.zip"
  depends_on  = [null_resource.pip_install]
}

resource "aws_lambda_layer_version" "layer" {
  layer_name          = "test-layer"
  filename            = data.archive_file.layer.output_path
  source_code_hash    = data.archive_file.layer.output_base64sha256
  compatible_runtimes = ["python3.9", "python3.8", "python3.7", "python3.6"]
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/../../task-scheduler/"
  output_path = "${path.module}/../../task-scheduler/scheduler.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {

  vpc_config {
    subnet_ids         = ["subnet-073a11bb0b7e99abf"]
    security_group_ids = ["sg-0aa6dd4fa747c9c52"]
  }

  environment {
    variables = {
      DB_HOST     = "database-1.cdueaecew80a.us-east-1.rds.amazonaws.com"
      DB_USER     = "admin"
      DB_PASSWORD = var.mssql_pwd
      DB_NAME     = "telegramDB"
    }
  }

  filename         = "${path.module}/../../task-scheduler/scheduler.zip"
  function_name    = "shceduler"
  role             = "arn:aws:iam::531190140983:role/service-role/testFc-role-l1r1aw1v"
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.zip_the_python_code.output_base64sha256
  layers           = [aws_lambda_layer_version.layer.arn]
}
