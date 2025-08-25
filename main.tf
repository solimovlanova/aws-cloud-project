data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "random_string" "cloudtrail" {
  length  = 16
  upper   = false
  special = false
}