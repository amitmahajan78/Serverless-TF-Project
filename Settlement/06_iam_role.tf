
data "aws_iam_policy_document" "step_function_dynamodb_update_policy" {
  statement {
    actions = [
      "dynamodb:UpdateItem",
    ]
    effect    = "Allow"
    resources = ["arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/*"]
  }
}

data "aws_iam_policy_document" "step_function_lambda_invoke_policy" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    effect    = "Allow"
    resources = ["arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:*"]
  }
}

data "aws_iam_policy_document" "step_function_sns_publish_policy" {
  statement {
    actions = [
      "sns:Publish",
    ]
    effect    = "Allow"
    resources = ["arn:aws:sns:*:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_role" "settlement_step_function_role" {
  name               = "step_function_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "step_function_dynaomdb_policy" {
  name   = "step_function_dynaomdb_policy"
  policy = data.aws_iam_policy_document.step_function_dynamodb_update_policy.json
}

resource "aws_iam_policy" "step_function_lambda_policy" {
  name   = "step_function_lambda_policy"
  policy = data.aws_iam_policy_document.step_function_lambda_invoke_policy.json
}
resource "aws_iam_policy" "step_function_sns_policy" {
  name   = "step_function_sns_policy"
  policy = data.aws_iam_policy_document.step_function_sns_publish_policy.json
}

resource "aws_iam_role_policy_attachment" "step_function_dynamodb_attachement" {
  policy_arn = aws_iam_policy.step_function_dynaomdb_policy.arn
  role       = aws_iam_role.settlement_step_function_role.name
}

resource "aws_iam_role_policy_attachment" "step_function_lambda_attachement" {
  policy_arn = aws_iam_policy.step_function_lambda_policy.arn
  role       = aws_iam_role.settlement_step_function_role.name
}

resource "aws_iam_role_policy_attachment" "step_function_sns_attachement" {
  policy_arn = aws_iam_policy.step_function_sns_policy.arn
  role       = aws_iam_role.settlement_step_function_role.name
}
