variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "terraform-spp"
}

variable "sns_topic_name" {
  description = "SNS subject name"
  type        = string
  default     = "terraform-spp-sns"
}

variable "student_email" {
  description = "Subscription email"
  type        = string
  default = "263668@student.pwr.edu.pl" 
  
}