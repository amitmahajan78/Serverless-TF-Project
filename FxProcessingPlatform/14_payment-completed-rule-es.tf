# data "aws_iam_policy_document" "EventbridgeLambdaInvokePolicyDoc" {

#   statement {
#     effect  = "Allow"
#     actions = ["lambda:InvokeFunction"]
#     resources = [
#       "${aws_lambda_function.PaymentCompletedFunction.arn}"
#     ]


#     condition {
#       test     = "ArnEquals"
#       values   = [aws_cloudwatch_event_rule.PaymentCompletedRule.arn]
#       variable = "aws:SourceArn"
#     }
#   }
# }

# resource "aws_iam_policy" "EventbridgeLambdaInvokePolicy" {
#   name   = "eventbridge-lambda-policy"
#   policy = data.aws_iam_policy_document.EventbridgeLambdaInvokePolicyDoc.json
# }

# resource "aws_iam_policy_attachment" "EventbridgeLambdaPolicyAtt" {
#   name       = "eventbridge-lambda-policy-attachedment"
#   roles      = [aws_iam_role.PaymentCompletedFunctionRole.name]
#   policy_arn = aws_iam_policy.EventbridgeLambdaInvokePolicy.arn
# }

resource "aws_lambda_permission" "allowEventbridgeToInvokeLambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.PaymentCompletedFunction.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.PaymentCompletedRule.arn
}

resource "aws_cloudwatch_event_rule" "PaymentCompletedRule" {
  name = "payment-completed"
  event_pattern = jsonencode({
    "detail" : {
      "message" : {
        "$or" : [
          {
            "paymentStatus" : {
              "S" : [
                {
                  "prefix" : "FxPayment sent for fulfilment"
                }
              ]
            }
          },
          {
            "paymentStatus" : {
              "S" : [
                {
                  "prefix" : "Error"
                }
              ]
            }
          }
        ]
      }
    }
  })
  event_bus_name = aws_cloudwatch_event_bus.FxPaymentEventBus.name
  is_enabled     = true
}

resource "aws_cloudwatch_event_target" "PaymentCompletedRuleTarget" {
  rule           = aws_cloudwatch_event_rule.PaymentCompletedRule.name
  arn            = aws_lambda_function.PaymentCompletedFunction.arn
  target_id      = "payment-completed-function"
  event_bus_name = aws_cloudwatch_event_bus.FxPaymentEventBus.name
}
