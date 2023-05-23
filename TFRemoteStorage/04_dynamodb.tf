resource "aws_dynamodb_table" "dynamodb_tf-state-lock" {
  name           = var.remote_state_dynamodb_table
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = var.remote_state_dynamodb_table_key

  attribute {
    name = var.remote_state_dynamodb_table_key
    type = "S"
  }
}
