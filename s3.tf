resource "aws_s3_bucket" "test_eventbridge" {
  count  = var.create_event_processor_lambda ? 1 : 0
  bucket = "eventbridge-${random_string.cloudtrail.id}"

  tags = {
    Name        = "terraform"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count       = var.create_event_processor_lambda ? 1 : 0
  bucket      = aws_s3_bucket.test_eventbridge[0].id
  eventbridge = true
}

