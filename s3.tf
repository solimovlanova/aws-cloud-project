resource "aws_s3_bucket" "terraform" {
  bucket = "state-file-backup-bucket-soli"

  tags = {
    Name        = "terraform"
    Environment = "Dev"
  }
}