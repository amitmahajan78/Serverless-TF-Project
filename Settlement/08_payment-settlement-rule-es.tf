resource "aws_iam_role" "event_stepfunction_role" {
  name = "public-snapshot-events-role"

  inline_policy {
    name   = "event_stepfunction_policy"
    policy = data.aws_iam_policy_document.event_stepfunction_policy.json

  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "event_stepfunction_policy" {
  statement {
    effect    = "Allow"
    actions   = ["states:StartExecution"]
    resources = [aws_sfn_state_machine.settlemnet_state_machine.arn]
  }
}

# resource "aws_lambda_permission" "allowEventBridgeToInvokeLambda" {
#   statement_id  = "AllowExecutionFromEventBridge"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_sfn_state_machine.settlemnet_state_machine.name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.PaymentSettlementRule.arn
# }

resource "aws_cloudwatch_event_rule" "PaymentSettlementRule" {
  name = "payment-settlement-rule"
  event_pattern = jsonencode({
    "detail" : {
      "message" : {
        "$or" : [
          {
            "paymentStatus" : {
              "S" : [
                {
                  "prefix" : "PAYMENT_SENT_FOR_FULFILLMENT"
                }
              ]
            }
          },
          {
            "paymentStatus" : {
              "S" : [
                {
                  "prefix" : "PAYMENT_ERROR"
                }
              ]
            }
          }
        ]
      }
    }
  })
  event_bus_name = var.event_bus_name
  is_enabled     = true
}

resource "aws_cloudwatch_event_target" "PaymentCompletedRuleTarget" {
  rule           = aws_cloudwatch_event_rule.PaymentSettlementRule.name
  arn            = aws_sfn_state_machine.settlemnet_state_machine.arn
  target_id      = "payment-settlement-workflow"
  event_bus_name = var.event_bus_name
  role_arn       = aws_iam_role.event_stepfunction_role.arn
}
