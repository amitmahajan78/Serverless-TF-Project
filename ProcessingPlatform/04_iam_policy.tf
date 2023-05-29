resource "aws_iam_policy" "DynamoDBStream" {
  name = "dynamodb_stream"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action : [
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "SQSSendMessage" {
  name = "sqs-send-message"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action : "sqs:SendMessage",
        Resource : "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:NewFxPaymentQueue"
      },
    ]
  })
}

resource "aws_iam_policy" "SQSListenMessage" {
  name = "sqs-list-message"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action : ["sqs:ListQueues", "sqs:DeleteMessage",
          "sqs:ReceiveMessage",
        "sqs:GetQueueAttributes"],
        Resource : "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:NewFxPaymentQueue"
      },
    ]
  })
}

resource "aws_iam_policy" "DynamoDBWrite" {
  name = "dynamodb-write-message"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action : "dynamodb:*",
        Resource : "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/fx-payments"
      },
    ]
  })
}

resource "aws_iam_policy" "EventBusPut" {
  name = "eventbus-put-message"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action : "events:PutEvents",
        Resource : "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/fx-payment-event-bus"
      },
    ]
  })
}
