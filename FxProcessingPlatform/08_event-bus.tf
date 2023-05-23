# data "aws_caller_identity" "eb-current" {}
# data "aws_region" "eb-current" {}

resource "aws_cloudwatch_event_bus" "FxPaymentEventBus" {
  name = "fx-payment-event-bus"

}

data "aws_iam_policy_document" "FxPaymentEventBusPolicyDoc" {
  statement {
    sid    = "AccountAccess"
    effect = "Allow"
    actions = [
      "events:PutEvents",
    ]
    resources = [
      "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/fx-payment-event-bus"
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_cloudwatch_event_bus_policy" "FxPaymentEventBusPolicy" {
  policy         = data.aws_iam_policy_document.FxPaymentEventBusPolicyDoc.json
  event_bus_name = aws_cloudwatch_event_bus.FxPaymentEventBus.name
}

resource "aws_schemas_discoverer" "EventBusDiscovery" {
  source_arn  = aws_cloudwatch_event_bus.FxPaymentEventBus.arn
  description = "Auto discover payment event schemas"
}

