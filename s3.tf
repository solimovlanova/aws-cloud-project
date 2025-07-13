resource "aws_s3_bucket" "terraform" {
  bucket = "state-file-backup-bucket-soli"

  tags = {
    Name        = "terraform"
    Environment = "Dev"
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-rds-export-cross-region-33329"
  
}