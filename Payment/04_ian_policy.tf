resource "aws_iam_policy" "DynamoDBPutItem" {
  name = "dynamodb_putitem"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "dynamodb:PutItem"
        Resource = aws_dynamodb_table.FxPaymentsTable.arn
      },
    ]
  })
}

resource "aws_iam_policy" "DynamoDBGetItem" {
  name = "dynamodb_getitem"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "dynamodb:GetItem"
        Resource = aws_dynamodb_table.FxPaymentsTable.arn
      },
    ]
  })
}
