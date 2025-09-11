resource "aws_s3_bucket" "test_eventbridge" {
  bucket = "eventbridge-${random_string.cloudtrail.id}"

  tags = {
    Name        = "terraform"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.test_eventbridge.id
  eventbridge = true
}

