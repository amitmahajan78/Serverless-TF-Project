resource "aws_lambda_event_source_mapping" "DynamoDbStreamLambdaMap" {
  event_source_arn  = data.aws_dynamodb_table.fx-pauments.stream_arn
  function_name     = aws_lambda_function.DynamoDBSQSBridgeFunction.arn
  starting_position = "LATEST"
}

