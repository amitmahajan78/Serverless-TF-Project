# resource "aws_iam_role" "PaymentCompletedFunctionRole" {
#   name = "payment-completed-lambda"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "PaymentCompletedFunctionPolicy" {
#   role       = aws_iam_role.PaymentCompletedFunctionRole.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# resource "aws_iam_role_policy_attachment" "DynamoDBWritePolicy" {
#   role       = aws_iam_role.PaymentCompletedFunctionRole.name
#   policy_arn = aws_iam_policy.DynamoDBWrite.arn
# }

# resource "aws_lambda_function" "PaymentCompletedFunction" {
#   function_name = "PaymentCompletedFunction"

#   s3_bucket = aws_s3_bucket.fx-processing-bucket.id
#   s3_key    = aws_s3_object.PaymentCompletedFunctionHandler.key

#   runtime = "nodejs14.x"
#   handler = "index.handler"

#   source_code_hash = data.archive_file.PaymentCompletedFunctionHandler.output_base64sha256

#   role = aws_iam_role.PaymentCompletedFunctionRole.arn
# }

# # cloudwatch log group
# resource "aws_cloudwatch_log_group" "PaymentCompletedFunctionRoleLogGroup" {
#   name = "/aws/lambda/${aws_lambda_function.PaymentCompletedFunction.function_name}"
# }

# data "archive_file" "PaymentCompletedFunctionHandler" {
#   type        = "zip"
#   source_dir  = "${path.module}/PaymentCompletedFunction"
#   output_path = "${path.module}/PaymentCompletedFunction.zip"
# }

# resource "aws_s3_object" "PaymentCompletedFunctionHandler" {
#   bucket = aws_s3_bucket.fx-processing-bucket.id
#   key    = "PaymentCompletedFunction.zip"
#   source = data.archive_file.PaymentCompletedFunctionHandler.output_path
#   etag   = filemd5(data.archive_file.PaymentCompletedFunctionHandler.output_path)
# }
