resource "aws_iam_role" "FxQuoteRole" {
  name = "fx-quote-role"

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

resource "aws_iam_role_policy_attachment" "FxQuotePolicy" {
  role       = aws_iam_role.FxQuoteRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "FxQuoteFunction" {
  function_name = "FxQuoteFunction"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.handler.key

  runtime = "nodejs14.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.FxQuoteHandler.output_base64sha256

  role = aws_iam_role.FxQuoteRole.arn
}

# cloudwatch log group
resource "aws_cloudwatch_log_group" "FxQuoteCWG" {
  name = "/aws/lambda/${aws_lambda_function.FxQuoteFunction.function_name}"
}

data "archive_file" "FxQuoteHandler" {
  type        = "zip"
  source_dir  = "${path.module}/FxQuote"
  output_path = "${path.module}/FxQuote.zip"
}

resource "aws_s3_object" "handler" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "FxQuote.zip"
  source = data.archive_file.FxQuoteHandler.output_path
  etag   = filemd5(data.archive_file.FxQuoteHandler.output_path)
}
