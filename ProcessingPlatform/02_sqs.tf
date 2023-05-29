resource "aws_sqs_queue" "PaymentQueue" {
  name                      = "NewFxPaymentQueue"
  max_message_size          = 262144
  message_retention_seconds = 86400
  delay_seconds             = 0
}
