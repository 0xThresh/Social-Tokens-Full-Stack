module "api-gateway-integrated-lambda" {
    source = "../modules/lambda-api-gateway"

    api_gateway_name = "reputation-token-api"
    api_gateway_path_part = "send-reputation-token"
    function_name = "test-send-reputation-token"
}

terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = ">= 4.0"
  }
  backend "local" {}
}