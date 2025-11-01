# =============================================================================
# SNS TOPICS AND RELATED RESOURCES
# =============================================================================

# -----------------------------------------------------------------------------
# EventBridge SNS Topic
# SNS topic for EventBridge notifications from S3 bucket events
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "eventbridge_topic" {
  count = var.create_sns_topics && var.create_event_processor_lambda ? 1 : 0
  
  name = "eventbridge-sns-topic"

  tags = {
    Name    = "EventBridge SNS Topic"
    Purpose = "S3 Event Notifications"
  }
}


resource "aws_sns_topic_subscription" "eventbridge_subscription" {
  count     = var.create_sns_topics && var.create_event_processor_lambda ? 1 : 0
  topic_arn = aws_sns_topic.eventbridge_topic[0].arn
  protocol  = "email"
  endpoint  = var.email
}


# IAM policy document for EventBridge SNS topic
resource "aws_sns_topic_policy" "eventbridge_topic" {
  count  = var.create_sns_topics && var.create_event_processor_lambda ? 1 : 0
  arn    = aws_sns_topic.eventbridge_topic[0].arn
  policy = data.aws_iam_policy_document.sns_eventbridge_topic_policy[0].json
}

# IAM policy document for EventBridge SNS topic
data "aws_iam_policy_document" "sns_eventbridge_topic_policy" {
  count = var.create_sns_topics && var.create_event_processor_lambda ? 1 : 0
  
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
      aws_sns_topic.eventbridge_topic[0].arn
    ]
  }
}

# -----------------------------------------------------------------------------
# Jump Host Monitoring SNS Topic
# SNS topic for CloudWatch alarms from Jump Host EC2 instance
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "jump_host" {
  count = var.create_sns_topics && var.create_jump_host && var.create_cloudwatch_alarms ? 1 : 0
  name  = "jump_host_alarm_topic"

  tags = {
    Name    = "Jump Host Alarm Topic"
    Purpose = "CloudWatch Alarms"
  }
}

resource "aws_sns_topic_subscription" "jump_host" {
  count     = var.create_sns_topics && var.create_jump_host && var.create_cloudwatch_alarms ? 1 : 0
  topic_arn = aws_sns_topic.jump_host[0].arn
  protocol  = "email"
  endpoint  = var.email
}

resource "aws_sns_topic_policy" "jump_host" {
  count  = var.create_sns_topics && var.create_jump_host && var.create_cloudwatch_alarms ? 1 : 0
  arn    = aws_sns_topic.jump_host[0].arn
  policy = data.aws_iam_policy_document.sns_jump_host_topic_policy[0].json
}

# IAM policy document for Jump Host SNS topic
data "aws_iam_policy_document" "sns_jump_host_topic_policy" {
  count = var.create_sns_topics && var.create_jump_host && var.create_cloudwatch_alarms ? 1 : 0
  
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
      aws_sns_topic.jump_host[0].arn
    ]
  }
}
