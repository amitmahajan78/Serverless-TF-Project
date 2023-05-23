resource "aws_iam_role" "DynamoDBSQSBridgeFunctionRole" {
  name = "dynamodb-sqs-lambda"

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

resource "aws_iam_role_policy_attachment" "DynamoDBSQSBridgeFunctionPolicy" {
  role       = aws_iam_role.DynamoDBSQSBridgeFunctionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "DynamoDBStreamPolicy" {
  role       = aws_iam_role.DynamoDBSQSBridgeFunctionRole.name
  policy_arn = aws_iam_policy.DynamoDBStream.arn
}

resource "aws_iam_role_policy_attachment" "SQSSendPolicy" {
  role       = aws_iam_role.DynamoDBSQSBridgeFunctionRole.name
  policy_arn = aws_iam_policy.SQSSendMessage.arn
}

resource "aws_lambda_function" "DynamoDBSQSBridgeFunction" {
  function_name = "DynamoDBSQSBridgeFunction"

  s3_bucket = aws_s3_bucket.fx-processing-bucket.id
  s3_key    = aws_s3_object.DynamoDBSQSBridgeFunctionHandler.key

  runtime = "nodejs14.x"
  handler = "index.handler"

  source_code_hash = data.archive_file.DynamoDBSQSBridgeFunctionHandler.output_base64sha256

  role = aws_iam_role.DynamoDBSQSBridgeFunctionRole.arn
}

# cloudwatch log group
resource "aws_cloudwatch_log_group" "DynamoDBSQSBridgeFunctionRoleLogGroup" {
  name = "/aws/lambda/${aws_lambda_function.DynamoDBSQSBridgeFunction.function_name}"
}

data "archive_file" "DynamoDBSQSBridgeFunctionHandler" {
  type        = "zip"
  source_dir  = "${path.module}/BridgeFunction"
  output_path = "${path.module}/BridgeFunction.zip"
}

resource "aws_s3_object" "DynamoDBSQSBridgeFunctionHandler" {
  bucket = aws_s3_bucket.fx-processing-bucket.id
  key    = "BridgeFunction.zip"
  source = data.archive_file.DynamoDBSQSBridgeFunctionHandler.output_path
  etag   = filemd5(data.archive_file.DynamoDBSQSBridgeFunctionHandler.output_path)
}
