
data "aws_iam_policy_document" "EventbridgeSNSPolicyDoc" {
  statement {
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = [
      "${aws_sns_topic.FxPaymentNotification.arn}"
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }

    condition {
      test     = "ArnEquals"
      values   = [aws_cloudwatch_event_rule.NotificationRule.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sns_topic_policy" "SNSTopicPolicy" {
  arn    = aws_sns_topic.FxPaymentNotification.arn
  policy = data.aws_iam_policy_document.EventbridgeSNSPolicyDoc.json

}

resource "aws_cloudwatch_event_rule" "NotificationRule" {
  name = "send-sns-notification"
  event_pattern = jsonencode({
    "detail" : {
      "message" : {
        "paymentStatus" : {
          "S" : [
            {
              "prefix" : "PAYMENT_SENT_FOR_FULFILLMENT"
            }
          ]
        }
      }
    }
  })
  event_bus_name = aws_cloudwatch_event_bus.FxPaymentEventBus.name
  is_enabled     = true
}


resource "aws_cloudwatch_event_target" "EmailNotification" {

  arn  = aws_sns_topic.FxPaymentNotification.arn
  rule = aws_cloudwatch_event_rule.NotificationRule.name
  input_transformer {
    input_paths = {
      "payeeName" : "$.detail.message.payeeName.S",
      "amount" : "$.detail.message.amount.N",
      "paymentId" : "$.detail.message.paymentId.S",
      "beneficiaryName" : "$.detail.message.beneficiaryName.S",
      "destinationCurrency" : "$.detail.message.destinationCurrency.S"
    }
    input_template = "\"Hi <payeeName>, We are processing payment of <amount> in <destinationCurrency> for <beneficiaryName>. You can check the details about your transaction by calling following API [GET] /fx-payments?paymentId=<paymentId>. Thank You!\""
  }
  event_bus_name = aws_cloudwatch_event_bus.FxPaymentEventBus.name
}
