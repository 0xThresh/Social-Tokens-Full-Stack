/* 
    Needs to build: 
    - the private key environment variable
        - what if we stored this in AWS SM instead, and retrieved from Lambda? 
   - the CloudWatch log trail and associated IAM role to allow writing logs to it
*/ 

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.smart_contract_executor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.api_method.http_method}${aws_api_gateway_resource.api_resource.path}"
}

resource "aws_lambda_function" "smart_contract_executor" {
  filename = "../../lambda/send_tokens.zip"
  function_name = var.function_name
  role = aws_iam_role.send_tokens_role.arn
  handler = "send_tokens.lambda_handler"
  runtime = "python3.8"
  layers = [aws_lambda_layer_version.web3py_layer.arn]
  #layers = ["arn:aws:lambda:us-west-2:${data.aws_caller_identity.current.account_id}:layer:web3-layer:3"]
  timeout = "150"
}



resource "aws_lambda_layer_version" "web3py_layer" {
  layer_name = "web3py-layer"
  description = "Includes the web3.py packages needed to run the token Lambda function"
  compatible_runtimes = ["python3.8"]
  filename = "${path.module}/web3py-layer.zip"
}