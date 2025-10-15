resource "aws_cloudwatch_metric_alarm" "jump_host_cpu" {
  count = var.create_jump_host ? 1 : 0
  alarm_name          = "jump_host_cpu_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120 # seconds 
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors ec2 cpu utilization"
  ok_actions          = [aws_sns_topic.jump_host.arn]
  alarm_actions       = [aws_sns_topic.jump_host.arn]
  
  dimensions = {
  
    InstanceId = aws_instance.jump_host[0].id
  }
}

