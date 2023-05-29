resource "aws_dynamodb_table" "FxPaymentsTable" {
  name         = "fx-payments"
  hash_key     = "paymentId"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "paymentId"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}
