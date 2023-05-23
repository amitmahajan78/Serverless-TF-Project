

resource "aws_api_gateway_rest_api" "Api" {
  name = "fxPayment"
}

resource "aws_api_gateway_resource" "ApiResource" {
  rest_api_id = aws_api_gateway_rest_api.Api.id
  parent_id   = aws_api_gateway_rest_api.Api.root_resource_id
  path_part   = "payments"
}

resource "aws_api_gateway_method" "ApiMethodCreatePayment" {
  rest_api_id          = aws_api_gateway_rest_api.Api.id
  resource_id          = aws_api_gateway_resource.ApiResource.id
  http_method          = "POST"
  authorization        = "CUSTOM"
  authorizer_id        = aws_api_gateway_authorizer.PaymentAuthorizer.id
  request_validator_id = aws_api_gateway_request_validator.ApiCreatePaymentRequestValidator.id

  request_models = {
    "application/json" = aws_api_gateway_model.ApiFxPaymentModel.name
  }
}

resource "aws_api_gateway_method" "ApiMethodGetPayment" {
  rest_api_id          = aws_api_gateway_rest_api.Api.id
  resource_id          = aws_api_gateway_resource.ApiResource.id
  http_method          = "GET"
  authorization        = "CUSTOM"
  authorizer_id        = aws_api_gateway_authorizer.PaymentAuthorizer.id
  request_validator_id = aws_api_gateway_request_validator.ApiGetPaymentRequestValidator.id
  request_parameters = {
    "method.request.querystring.paymentId" = true
  }

}

resource "aws_api_gateway_integration" "ApiIntegrationCreatePayment" {
  rest_api_id             = aws_api_gateway_rest_api.Api.id
  resource_id             = aws_api_gateway_resource.ApiResource.id
  http_method             = aws_api_gateway_method.ApiMethodCreatePayment.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.CreatePaymentFunction.invoke_arn
}

resource "aws_api_gateway_integration" "ApiIntegrationGetPayment" {
  rest_api_id             = aws_api_gateway_rest_api.Api.id
  resource_id             = aws_api_gateway_resource.ApiResource.id
  http_method             = aws_api_gateway_method.ApiMethodGetPayment.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.GetPaymentFunction.invoke_arn
}

# Lambda Permission
resource "aws_lambda_permission" "ApiGWLambdaCreatePayment" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.CreatePaymentFunction.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.Api.id}/*/${aws_api_gateway_method.ApiMethodCreatePayment.http_method}${aws_api_gateway_resource.ApiResource.path}"
}

# Lambda Permission
resource "aws_lambda_permission" "ApiGWLambdaGetPayment" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.GetPaymentFunction.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.Api.id}/*/${aws_api_gateway_method.ApiMethodGetPayment.http_method}${aws_api_gateway_resource.ApiResource.path}"
}

resource "aws_api_gateway_deployment" "ApiDeployment" {
  rest_api_id = aws_api_gateway_rest_api.Api.id
  #   stage_name  = "stage"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.ApiResource.id,
      aws_api_gateway_method.ApiMethodCreatePayment.id,
      aws_api_gateway_integration.ApiIntegrationCreatePayment.id,
      aws_api_gateway_method.ApiMethodGetPayment.id,
      aws_api_gateway_integration.ApiIntegrationGetPayment.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "ApiStage" {
  deployment_id        = aws_api_gateway_deployment.ApiDeployment.id
  rest_api_id          = aws_api_gateway_rest_api.Api.id
  stage_name           = "stage"
  xray_tracing_enabled = true
}

resource "aws_api_gateway_model" "ApiFxPaymentModel" {
  rest_api_id  = aws_api_gateway_rest_api.Api.id
  name         = "FxPayment"
  description  = "Fx Payment JSON schema"
  content_type = "application/json"

  // schema       = file("${path.module}/request_schemas/post_example.json")

  schema = jsonencode({
    "$schema" : "https://json-schema.org/draft/2020-12/schema",
    "description" : "Fx Payment request schema",
    "type" : "object",
    "properties" : {
      "destinationCurrency" : {
        "type" : "string",
        "enum" : ["GBP", "EUR"]
      },
      "amount" : {
        "type" : "integer"
      },
      "payeeName" : {
        "type" : "string"
      },
      "beneficiaryName" : {
        "type" : "string"
      },
      "beneficiaryBankName" : {
        "type" : "string"
      },
      "beneficiaryAccountNo" : {
        "type" : "string"
      },
      "quoteId" : {
        "type" : "string",
        "enum" : ["1001", "1002"]
      }
    },
    "required" : [
      "amount",
      "destinationCurrency",
      "payeeName",
      "beneficiaryName",
      "beneficiaryBankName",
      "beneficiaryAccountNo",
      "quoteId"
    ]
  })
}

resource "aws_api_gateway_request_validator" "ApiCreatePaymentRequestValidator" {
  rest_api_id           = aws_api_gateway_rest_api.Api.id
  name                  = "CreatePayment-Validator"
  validate_request_body = true

}

resource "aws_api_gateway_request_validator" "ApiGetPaymentRequestValidator" {
  rest_api_id                 = aws_api_gateway_rest_api.Api.id
  name                        = "GetPayment-Validator"
  validate_request_parameters = true

}

