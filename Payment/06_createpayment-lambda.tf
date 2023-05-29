resource "aws_iam_role" "CreatePaymentRole" {
  name = "create-payment-lambda"

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

resource "aws_iam_role_policy_attachment" "CreatePaymentRolePolicy" {
  role       = aws_iam_role.CreatePaymentRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "CreatePaymentRolePolicyDynamoDB" {
  role       = aws_iam_role.CreatePaymentRole.name
  policy_arn = aws_iam_policy.DynamoDBPutItem.arn
}


resource "aws_lambda_function" "CreatePaymentFunction" {
  function_name = "FxCreatePaymentFunction"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.CreatePaymentS3Object.key

  runtime = "nodejs14.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.CreatePayemntArchiveFile.output_base64sha256

  role = aws_iam_role.CreatePaymentRole.arn
}

# cloudwatch log group
resource "aws_cloudwatch_log_group" "CreatePaymentLogGroup" {
  name = "/aws/lambda/${aws_lambda_function.CreatePaymentFunction.function_name}"
}

data "archive_file" "CreatePayemntArchiveFile" {
  type        = "zip"
  source_dir  = "${path.module}/CreatePayment"
  output_path = "${path.module}/CreatePayment.zip"
}

resource "aws_s3_object" "CreatePaymentS3Object" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "CreatePayment.zip"
  source = data.archive_file.CreatePayemntArchiveFile.output_path
  etag   = filemd5(data.archive_file.CreatePayemntArchiveFile.output_path)
}
