provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_role" "lab_role" {
  name = "LabRole" 
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../src/" 
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_sns_topic" "notifications" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.student_email 
}

resource "aws_lambda_function" "sensor_processor" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler" 
  runtime       = "python3.9"
  role          = data.aws_iam_role.lab_role.arn 

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.notifications.arn
      # DYNAMODB_TABLE_NAME = aws_dynamodb_table.sensor_status.name 
      # S3_BUCKET_NAME      = aws_s3_bucket.sensor_data.bucket 
    }
  }

  timeout     = 30 
  memory_size = 128 
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.sensor_processor.function_name}"
  retention_in_days = 7 
}