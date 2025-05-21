variable "aws_region" {
  description = "Region AWS dla zasobów"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Nazwa funkcji Lambda"
  type        = string
  default     = "spp-sensor-processor"
}

variable "sns_topic_name" {
  description = "Nazwa tematu SNS do powiadomień"
  type        = string
  default     = "spp-sensor-notifications"
}

variable "student_email" {
  description = "Twój email do subskrypcji SNS (do testów)"
  type        = string
  default = "263668@student.pwr.edu.pl" 
  
}