output "lambda_function_arn" {
  description = "ARN funkcji Lambda"
  value       = aws_lambda_function.sensor_processor.arn
}

output "lambda_function_name" {
  description = "Nazwa funkcji Lambda"
  value       = aws_lambda_function.sensor_processor.function_name
}

output "sns_topic_arn" {
  description = "ARN tematu SNS"
  value       = aws_sns_topic.notifications.arn
}