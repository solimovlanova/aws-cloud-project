# =============================================================================
# SNS TOPICS AND RELATED RESOURCES
# =============================================================================

# -----------------------------------------------------------------------------
# EventBridge SNS Topic
# SNS topic for EventBridge notifications from S3 bucket events
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "eventbridge_topic" {
  name = "eventbridge-sns-topic"

  tags = {
    Name    = "EventBridge SNS Topic"
    Purpose = "S3 Event Notifications"
  }
}


resource "aws_sns_topic_subscription" "eventbridge_subscription" {
  topic_arn = aws_sns_topic.eventbridge_topic.arn
  protocol  = "email"
  endpoint  = var.email
}


# IAM policy document for EventBridge SNS topic
resource "aws_sns_topic_policy" "eventbridge_topic" {
  arn    = aws_sns_topic.eventbridge_topic.arn
  policy = data.aws_iam_policy_document.sns_eventbridge_topic_policy.json
}

# IAM policy document for EventBridge SNS topic
data "aws_iam_policy_document" "sns_eventbridge_topic_policy" {
  statement {
    sid    = "AllowEventBridgeToPublish"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = [
      "SNS:Publish"
    ]

    resources = [
      aws_sns_topic.eventbridge_topic.arn
    ]
  }
}

# -----------------------------------------------------------------------------
# Jump Host Monitoring SNS Topic
# SNS topic for CloudWatch alarms from Jump Host EC2 instance
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "jump_host" {
  name = "jump_host_alarm_topic"

  tags = {
    Name    = "Jump Host Alarm Topic"
    Purpose = "CloudWatch Alarms"
  }
}

resource "aws_sns_topic_subscription" "jump_host" {
  topic_arn = aws_sns_topic.jump_host.arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_sns_topic_policy" "jump_host" {
  arn    = aws_sns_topic.jump_host.arn
  policy = data.aws_iam_policy_document.sns_jump_host_topic_policy.json
}

# IAM policy document for Jump Host SNS topic
data "aws_iam_policy_document" "sns_jump_host_topic_policy" {
  statement {
    sid    = "AllowCloudWatchToPublish"
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    
    actions = [
      "SNS:Publish"
    ]
    
    resources = [
      aws_sns_topic.jump_host.arn
    ]
  }
}
