variable "aws_region" {
  description = "Region where resources are deployed"
  type = string
  default = "us-west-2"
}

variable "api_gateway_name" {
  description = "Name of the API built in API Gateway"
  type = string
}

variable "api_gateway_path_part" {
  description = "Path where methods will be created"
  type = string
}

data "aws_caller_identity" "current" {
  
}

variable "function_name" {
  description = "Name of the Lambda function"
  type = string
}