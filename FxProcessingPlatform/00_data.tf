data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_dynamodb_table" "fx-pauments" {
  name = "fx-payments"
}

variable "subscription_email" {
  type    = string
  default = "amitmahajan.cloud@gmeial.com"
}
