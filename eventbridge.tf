resource "aws_cloudwatch_event_rule" "s3_put" {
  name = "S3ObjectCreatedToSNS"
  event_pattern = jsonencode({
    source = ["aws.s3"],
    "detail-type" = ["AWS API Call via CloudTrail"],
    resources = [aws_s3_bucket.test_eventbridge.id], 
    detail = {
      eventSource = ["s3.amazonaws.com"],
      eventName   = ["PutObject"]
    }
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.s3_put.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.eventbridge_topic.arn
}

resource "aws_sns_topic" "eventbridge_topic" {
  name = "eventbridge-sns-topic"
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.eventbridge_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.eventbridge_topic.arn]
  }
}
