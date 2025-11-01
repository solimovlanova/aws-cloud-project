# EventBridge rule for S3 events
resource "aws_cloudwatch_event_rule" "s3_events" {
  count       = var.create_event_processor_lambda ? 1 : 0
  name        = "s3-object-events"
  description = "Trigger Lambda on S3 object put/delete events"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created", "Object Deleted"]
    detail = {
      bucket = {
        name = [aws_s3_bucket.test_eventbridge[0].bucket]
      }
    }
  })
}

# EventBridge target - Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = var.create_event_processor_lambda ? 1 : 0
  rule      = aws_cloudwatch_event_rule.s3_events[0].name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.s3_event_processor[0].arn
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  count         = var.create_event_processor_lambda ? 1 : 0
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_processor[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_events[0].arn
}
