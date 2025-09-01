resource "aws_cloudwatch_event_rule" "s3_put" {
  name = "S3AllActionsToSNS"
  event_pattern = jsonencode({
    source = ["aws.s3"],
    "detail-type" = ["AWS API Call via CloudTrail"],
    resources = [aws_s3_bucket.test_eventbridge.id],
    detail = {
      eventSource = ["s3.amazonaws.com"]
      
    }
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.s3_put.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.eventbridge_topic.arn
  role_arn  = aws_iam_role.eventbridge_s3_role.arn
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


resource "aws_iam_role" "eventbridge_s3_role" {
  name = "eventbridge-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_s3_policy" {
  name = "eventbridge-s3-access-policy"
  role = aws_iam_role.eventbridge_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "*" 
        ]
      }
    ]
  })
}
