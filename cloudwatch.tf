resource "aws_cloudwatch_metric_alarm" "jump_host_cpu" {
  alarm_name                = "jump_host_cpu_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 5
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120 #seconds 
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  ok_actions = [aws_sns_topic.jump_host.arn]
  alarm_actions = [aws_sns_topic.jump_host.arn]
  
  dimensions = {
    InstanceId = aws_instance.jump_host.id
  }

}

resource "aws_sns_topic" "jump_host" {
  name = "jump_host_alarm_topic"
}

resource "aws_sns_topic_subscription" "jump_host" {
  topic_arn  = aws_sns_topic.jump_host.arn
  protocol   = "email"
  endpoint   = var.email
}


resource "aws_sns_topic_policy" "jump_host" {
  arn    = aws_sns_topic.jump_host.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.jump_host.arn
      }
    ]
  })
}

