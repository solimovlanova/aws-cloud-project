resource "aws_s3_bucket" "test_eventbridge" {
  bucket = "eventbridge-${random_string.cloudtrail.id}"

  tags = {
    Name        = "terraform"
    Environment = "Dev"
  }
}

