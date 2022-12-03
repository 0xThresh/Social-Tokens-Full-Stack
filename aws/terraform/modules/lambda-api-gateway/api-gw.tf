# Needs to create the API gateway and the Lambda function 
resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.api_gateway_name
}

resource "aws_api_gateway_resource" "api_resource" {
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = var.api_gateway_path_part
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_method" "api_method" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_integration" "example" {
  http_method = aws_api_gateway_method.api_method.http_method
  resource_id = aws_api_gateway_resource.api_resource.id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  integration_http_method = "POST"
  type                    = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.smart_contract_executor.arn}/invocations" #aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "api_response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "api_integration_response" {
  # Repeatedly hit a bug with this not deploying on the first TF apply; forcing it to build last with depends_on helped
  depends_on = [aws_api_gateway_stage.api_stage]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method
  status_code = aws_api_gateway_method_response.api_response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/xml" = <<EOF
    #set($inputRoot = $input.path('$'))
    <?xml version="1.0" encoding="UTF-8"?>
    <message>
        $inputRoot.body
    </message>
    EOF
  }
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api_resource.id,
      aws_api_gateway_method.api_method.id,
      aws_api_gateway_integration.example.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "prod"
}