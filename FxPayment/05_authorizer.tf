# resource "aws_api_gateway_authorizer" "PaymentAuthorizer" {
#   name                             = "payment-authorizer"
#   rest_api_id                      = aws_api_gateway_rest_api.Api.id
#   authorizer_uri                   = aws_lambda_function.AuthFunction.invoke_arn
#   identity_source                  = "method.request.header.Authorization"
#   type                             = "TOKEN"
#   authorizer_result_ttl_in_seconds = 300
# }


resource "aws_api_gateway_authorizer" "PaymentAuthorizer" {
  name                             = "payment-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.Api.id
  authorizer_uri                   = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials           = aws_iam_role.invocation_role.arn
  authorizer_result_ttl_in_seconds = 0
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "invocation_role" {
  name               = "api_gateway_auth_invocation"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "invocation_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.authorizer.arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  name   = "default"
  role   = aws_iam_role.invocation_role.id
  policy = data.aws_iam_policy_document.invocation_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AuthRole" {
  name               = "AuthRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_lambda_function" "authorizer" {

  function_name = "FxAuthFunction"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.AuthS3Object.key

  runtime = "nodejs14.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.AuthArchiveFile.output_base64sha256

  role = aws_iam_role.AuthRole.arn

  environment {
    variables = {
      ENV_SECRET_TOKEN = "secrettoken"
    }
  }
}

# cloudwatch log group
resource "aws_cloudwatch_log_group" "AuthorizerLogGroup" {
  name = "/aws/lambda/${aws_lambda_function.authorizer.function_name}"
}



data "archive_file" "AuthArchiveFile" {
  type        = "zip"
  source_dir  = "${path.module}/Auth"
  output_path = "${path.module}/Auth.zip"
}

resource "aws_s3_object" "AuthS3Object" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "Auth.zip"
  source = data.archive_file.AuthArchiveFile.output_path
  etag   = filemd5(data.archive_file.AuthArchiveFile.output_path)
}
