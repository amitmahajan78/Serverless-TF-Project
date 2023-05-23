data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_dynamodb_table" "fx-pauments" {
  name = "fx-payments"
}
