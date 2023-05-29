# cloudwatch log group
resource "aws_cloudwatch_log_group" "PaymentEvents" {
  name = "/aws/event/fx-payments-event-logs-group"
}

data "aws_iam_policy_document" "LogPolicy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream"
    ]

    resources = [
      "${aws_cloudwatch_log_group.PaymentEvents.arn}:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.PaymentEvents.arn}:*:*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }

    condition {
      test     = "ArnEquals"
      values   = [aws_cloudwatch_event_rule.CloudWatchRule.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "LogResourcePolicy" {
  policy_document = data.aws_iam_policy_document.LogPolicy.json
  policy_name     = "guardduty-log-publishing-policy"
}

resource "aws_cloudwatch_event_rule" "CloudWatchRule" {
  name = "send-all-event-to-cw"
  event_pattern = jsonencode({
    "account" : ["${data.aws_caller_identity.current.account_id}"]
  })
  event_bus_name = aws_cloudwatch_event_bus.FxPaymentEventBus.name
  is_enabled     = true
}

resource "aws_cloudwatch_event_target" "CloudWatchTarget" {
  rule           = aws_cloudwatch_event_rule.CloudWatchRule.name
  arn            = aws_cloudwatch_log_group.PaymentEvents.arn
  target_id      = "cloud_watch"
  event_bus_name = aws_cloudwatch_event_bus.FxPaymentEventBus.name
}
