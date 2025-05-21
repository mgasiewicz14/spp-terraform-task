provider "aws" {
  region = var.aws_region
  // Zakładamy, że AWS CLI jest skonfigurowane do używania LabRole
  // lub ma odpowiednie uprawnienia.
  // Jeśli LabRole jest w innym koncie, potrzebna będzie konfiguracja assume_role.
  // Dla prostoty, zakładamy, że działamy w kontekście LabRole.
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Pobranie danych o roli LabRole
# WAŻNE: Nazwa 'LabRole' musi być dokładna. Jeśli rola jest w path, np. /iam/roles/LabRole,
# to musisz podać pełną ścieżkę w name lub użyć aws_iam_role data source z path_prefix.
# Najprościej, jeśli rola nie ma ścieżki, wystarczy 'LabRole'.
# Sprawdź w konsoli IAM, jak dokładnie nazywa się rola.
data "aws_iam_role" "lab_role" {
  name = "LabRole" # Upewnij się, że to poprawna nazwa roli!
}

# Pakowanie kodu Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../src/" # Ścieżka do katalogu z kodem lambda_function.py
  output_path = "${path.module}/lambda_function.zip"
}

# Temat SNS
resource "aws_sns_topic" "notifications" {
  name = var.sns_topic_name
}

# Subskrypcja email do tematu SNS (do testów)
resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.student_email # Upewnij się, że podałeś email
}

# Funkcja Lambda
resource "aws_lambda_function" "sensor_processor" {
  function_name = var.lambda_function_name
  handler       = "lambda_function.lambda_handler" # Nazwa pliku . nazwa funkcji
  runtime       = "python3.9"
  role          = data.aws_iam_role.lab_role.arn # Użycie istniejącej LabRole

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.notifications.arn
      # DYNAMODB_TABLE_NAME = aws_dynamodb_table.sensor_status.name # Dodamy później
      # S3_BUCKET_NAME      = aws_s3_bucket.sensor_data.bucket # Dodamy później
    }
  }

  timeout     = 30 # sekundy
  memory_size = 128 # MB

  # Upewnij się, że LabRole ma uprawnienia 'lambda:InvokeFunction'
  # oraz do CloudWatch Logs ('logs:CreateLogGroup', 'logs:CreateLogStream', 'logs:PutLogEvents')
  # oraz 'sns:Publish' do tego konkretnego tematu SNS.
}

# CloudWatch Log Group dla Lambdy
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.sensor_processor.function_name}"
  retention_in_days = 7 # Opcjonalnie, jak długo przechowywać logi
}