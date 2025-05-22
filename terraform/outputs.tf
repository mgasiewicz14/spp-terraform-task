output "lambda_function_arn" {
  description = "ARN of lambda function"
  value       = aws_lambda_function.sensor_processor.arn
}

output "lambda_function_name" {
  description = "Lamdba function name"
  value       = aws_lambda_function.sensor_processor.function_name
}

output "sns_topic_arn" {
  description = "ARN of SNS subject"
  value       = aws_sns_topic.notifications.arn
}