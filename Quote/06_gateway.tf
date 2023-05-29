

resource "aws_api_gateway_rest_api" "Api" {
  name = "fxQuote"
}

resource "aws_api_gateway_resource" "ApiResource" {
  rest_api_id = aws_api_gateway_rest_api.Api.id
  parent_id   = aws_api_gateway_rest_api.Api.root_resource_id
  path_part   = "quotes"
}

resource "aws_api_gateway_method" "ApiMethod" {
  rest_api_id          = aws_api_gateway_rest_api.Api.id
  resource_id          = aws_api_gateway_resource.ApiResource.id
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.ApiFxQuoteRequestValidator.id

  request_models = {
    "application/json" = aws_api_gateway_model.ApiFxQuoteModel.name
  }
}

resource "aws_api_gateway_integration" "ApiIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.Api.id
  resource_id             = aws_api_gateway_resource.ApiResource.id
  http_method             = aws_api_gateway_method.ApiMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.FxQuoteFunction.invoke_arn
}

# Lambda Permission
resource "aws_lambda_permission" "ApiGWLambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.FxQuoteFunction.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.Api.id}/*/${aws_api_gateway_method.ApiMethod.http_method}${aws_api_gateway_resource.ApiResource.path}"
}

resource "aws_api_gateway_deployment" "ApiDeployment" {
  rest_api_id = aws_api_gateway_rest_api.Api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.ApiResource.id,
      aws_api_gateway_method.ApiMethod.id,
      aws_api_gateway_integration.ApiIntegration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "ApiStage" {
  deployment_id = aws_api_gateway_deployment.ApiDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.Api.id
  stage_name    = "stage"
}

resource "aws_api_gateway_model" "ApiFxQuoteModel" {
  rest_api_id  = aws_api_gateway_rest_api.Api.id
  name         = "FxQuote"
  description  = "Fx Quote JSON schema"
  content_type = "application/json"

  // schema       = file("${path.module}/request_schemas/post_example.json")

  schema = jsonencode({
    "$schema" : "https://json-schema.org/draft/2020-12/schema",
    "description" : "Fx Quote request schema",
    "type" : "object",
    "properties" : {
      "destinationCurrency" : {
        "type" : "string",
        "enum" : ["GBP", "EUR"]
      },
      "amount" : {
        "type" : "integer"
      }
    },
    "required" : ["amount", "destinationCurrency"]
  })
}

resource "aws_api_gateway_request_validator" "ApiFxQuoteRequestValidator" {
  rest_api_id           = aws_api_gateway_rest_api.Api.id
  name                  = "FxQuote-Validator"
  validate_request_body = true
}

