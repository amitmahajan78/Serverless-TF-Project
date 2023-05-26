resource "aws_sns_topic" "FxPaymentNotification" {
  name = "FxPaymentNotification"
}

resource "aws_sns_topic_subscription" "EmailSubscription" {

  topic_arn = aws_sns_topic.FxPaymentNotification.arn
  protocol  = "email"
  endpoint  = var.subscription_email
}
