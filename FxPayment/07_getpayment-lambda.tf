resource "aws_iam_role" "GetPaymentRole" {
  name = "get-payment-lambda"

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

resource "aws_iam_role_policy_attachment" "GetPaymentRolePolicy" {
  role       = aws_iam_role.GetPaymentRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "GetPaymentRolePolicyDynamoDB" {
  role       = aws_iam_role.GetPaymentRole.name
  policy_arn = aws_iam_policy.DynamoDBGetItem.arn
}


resource "aws_lambda_function" "GetPaymentFunction" {
  function_name = "FxGetPaymentFunction"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.GetPaymentS3Object.key

  runtime = "nodejs14.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.GetPayemntArchiveFile.output_base64sha256

  role = aws_iam_role.GetPaymentRole.arn
}

# cloudwatch log group
resource "aws_cloudwatch_log_group" "GetPaymentLogGroup" {
  name = "/aws/lambda/${aws_lambda_function.GetPaymentFunction.function_name}"
}

data "archive_file" "GetPayemntArchiveFile" {
  type        = "zip"
  source_dir  = "${path.module}/GetPayment"
  output_path = "${path.module}/GetPayment.zip"
}

resource "aws_s3_object" "GetPaymentS3Object" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "GetPayment.zip"
  source = data.archive_file.GetPayemntArchiveFile.output_path
  etag   = filemd5(data.archive_file.GetPayemntArchiveFile.output_path)
}
