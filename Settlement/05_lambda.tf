resource "aws_iam_role" "PaymentOptionsRole" {
  name = "payment-options-role"

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

resource "aws_iam_role_policy_attachment" "PaymentOptionsPolicy" {
  role       = aws_iam_role.PaymentOptionsRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "PaymentOptionsFunction" {
  function_name = "PaymentOptionsFunction"

  s3_bucket = aws_s3_bucket.settlement_bucket.id
  s3_key    = aws_s3_object.PaymentOptionsHandler.key

  runtime = "nodejs14.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.PaymentOptionsHandler.output_base64sha256

  role = aws_iam_role.PaymentOptionsRole.arn
}

# cloudwatch log group
resource "aws_cloudwatch_log_group" "PaymentOptionsCWG" {
  name = "/aws/lambda/${aws_lambda_function.PaymentOptionsFunction.function_name}"
}

data "archive_file" "PaymentOptionsHandler" {
  type        = "zip"
  source_dir  = "${path.module}/PaymentOptions"
  output_path = "${path.module}/PaymentOptions.zip"
}

resource "aws_s3_object" "PaymentOptionsHandler" {
  bucket = aws_s3_bucket.settlement_bucket.id
  key    = "PaymentOptions.zip"
  source = data.archive_file.PaymentOptionsHandler.output_path
  etag   = filemd5(data.archive_file.PaymentOptionsHandler.output_path)
}
