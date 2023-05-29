resource "aws_lambda_event_source_mapping" "SQSEventLambdaMap" {
  event_source_arn = aws_sqs_queue.PaymentQueue.arn
  function_name    = aws_lambda_function.PaymentProcessingFunction.arn
  batch_size       = 1
}
