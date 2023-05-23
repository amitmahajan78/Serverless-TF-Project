resource "aws_iam_role" "PaymentProcessingFunctionRole" {
  name = "payment-processing-lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "PaymentProcessingFunctionPolicy" {
  role       = aws_iam_role.PaymentProcessingFunctionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "DynamoDBPolicy" {
  role       = aws_iam_role.PaymentProcessingFunctionRole.name
  policy_arn = aws_iam_policy.DynamoDBWrite.arn
}

resource "aws_iam_role_policy_attachment" "SQSListPolicy" {
  role       = aws_iam_role.PaymentProcessingFunctionRole.name
  policy_arn = aws_iam_policy.SQSListenMessage.arn
}

resource "aws_iam_role_policy_attachment" "EventBusPutPolicy" {
  role       = aws_iam_role.PaymentProcessingFunctionRole.name
  policy_arn = aws_iam_policy.EventBusPut.arn
}

resource "aws_lambda_function" "PaymentProcessingFunction" {
  function_name = "PaymentProcessingFunction"

  s3_bucket = aws_s3_bucket.fx-processing-bucket.id
  s3_key    = aws_s3_object.PaymentProcessingFunctionHandler.key

  runtime = "nodejs14.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.PaymentProcessingFunctionHandler.output_base64sha256

  role = aws_iam_role.PaymentProcessingFunctionRole.arn
}

# cloudwatch log group
resource "aws_cloudwatch_log_group" "PaymentProcessingFunctionRoleLogGroup" {
  name = "/aws/lambda/${aws_lambda_function.PaymentProcessingFunction.function_name}"
}

data "archive_file" "PaymentProcessingFunctionHandler" {
  type        = "zip"
  source_dir  = "${path.module}/PaymentProcessingFunction"
  output_path = "${path.module}/PaymentProcessingFunction.zip"
}

resource "aws_s3_object" "PaymentProcessingFunctionHandler" {
  bucket = aws_s3_bucket.fx-processing-bucket.id
  key    = "PaymentProcessingFunction.zip"
  source = data.archive_file.PaymentProcessingFunctionHandler.output_path
  etag   = filemd5(data.archive_file.PaymentProcessingFunctionHandler.output_path)
}
