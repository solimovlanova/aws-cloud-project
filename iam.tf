

resource "aws_iam_user" "terraform" {
  name = "tf_manager"
}

resource "aws_iam_group" "readonly_group" {
  name = "ReadOnlyGroup"
}

resource "aws_iam_user_group_membership" "readonly_membership" {
  user = aws_iam_user.terraform.name
  groups = [
    aws_iam_group.readonly_group.name
  ]
}

resource "aws_iam_group_policy_attachment" "readonly_access" {
  group      = aws_iam_group.readonly_group.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

locals {
  policies = {
    Compute-Limited-FreeTier-Policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = "ec2:RunInstances",
        Resource = "*",
        Condition = {
          StringEquals = {
            "ec2:InstanceType" = [
              "t2.micro",
              "t3.micro",
              "t4g.micro"
            ]
          }
        }
      }]
    })

    Storage-Limited-FreeTier-Policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = "s3:*",
          Resource = "arn:aws:s3:::*"
        },
        {
          Effect = "Allow",
          Action = [
            "ec2:CreateVolume",
            "ec2:AttachVolume",
            "ec2:ModifyVolume",
            "ec2:DeleteVolume"
          ],
          Resource = "*",
          Condition = {
            NumericLessThanEquals = {
              "ec2:VolumeSize" = 15
            }
          }
        },
        {
          Effect = "Allow",
          Action = [
            "rds:CreateDBInstance",
            "rds:ModifyDBInstance",
            "rds:DeleteDBInstance"
          ],
          Resource = "*",
          Condition = {
            NumericLessThanEquals = {
              "rds:AllocatedStorage" = 20
            }
          }
        }
      ]
    })

    DynamoDB-Limited-FreeTier-Policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect = "Deny",
        Action = [
          "dynamodb:CreateGlobalTable",
          "dynamodb:UpdateGlobalTable",
          "dynamodb:CreateTableReplica",
          "dynamodb:UpdateTableReplica",
          "dynamodb:CreateBackup",
          "dynamodb:UpdateTable",
          "dynamodb:DeleteTable",
          "dynamodb:CreateTable",
          "dynamodb:UpdateContinuousBackups",
          "dynamodb:RestoreTableFromBackup",
          "dynamodb:RestoreTableToPointInTime"
        ],
        Resource = "*"
      }]
    })

    Non-FreeTier-Deny-Policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Sid      = "DenyNonFreeTierEC2",
          Effect   = "Deny",
          Action   = "ec2:RunInstances",
          Resource = "*",
          Condition = {
            StringNotEquals = {
              "ec2:InstanceType" = [
                "t2.micro",
                "t3.micro",
                "t4g.micro"
              ]
            },
            NumericGreaterThan = {
              "ec2:VolumeSize" = 15
            }
          }
        },
        {
          Sid      = "DenyNonFreeTierRDS",
          Effect   = "Deny",
          Action   = "rds:CreateDBInstance",
          Resource = "*",
          Condition = {
            NumericGreaterThan = {
              "rds:AllocatedStorage" = 20
            }
          }
        },
        {
          Sid    = "DenyNonFreeTierDynamoDB",
          Effect = "Deny",
          Action = [
            "dynamodb:CreateTable",
            "dynamodb:CreateGlobalTable",
            "dynamodb:CreateTableReplica",
            "dynamodb:UpdateTable",
            "dynamodb:DeleteTable",
            "dynamodb:UpdateTableReplica",
            "dynamodb:UpdateContinuousBackups",
            "dynamodb:RestoreTableFromBackup",
            "dynamodb:RestoreTableToPointInTime"
          ],
          Resource = "*"
        },
        {
          Sid    = "AllowDescriptiveActions",
          Effect = "Allow",
          Action = [
            "ec2:DescribeInstances",
            "rds:DescribeDBInstances",
            "dynamodb:DescribeTable",
            "dynamodb:ListTables"
          ],
          Resource = "*"
        }
      ]
    })

  }
}

resource "aws_iam_group_policy" "custom_policies" {
  for_each = local.policies

  name   = each.key
  group  = aws_iam_group.readonly_group.name
  policy = each.value
}

resource "aws_iam_account_alias" "alias" {
  account_alias = "solimovlanova"
}

# -----------------------------------------------------------------------------
# Lambda execution role
# -----------------------------------------------------------------------------
# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "s3-event-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# SNS publish policy for Lambda
resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "s3-event-processor-sns-policy"
  path        = "/"
  description = "IAM policy for SNS publishing from Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:GetTopicAttributes"
        ]
        Resource = aws_sns_topic.eventbridge_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

# -----------------------------------------------------------------------------
# EventBridge Service Role
# -----------------------------------------------------------------------------
resource "aws_iam_role" "eventbridge_s3_role" {
  name = "eventbridge-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_s3_policy" {
  name = "eventbridge-s3-access-policy"
  role = aws_iam_role.eventbridge_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "*" 
        ]
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# AWS Backup Service Role
# -----------------------------------------------------------------------------
resource "aws_iam_role" "backup_role" {
  count = var.create_backup ? 1 : 0
  name  = "AWSBackupDefaultServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_service_policy" {
  count      = var.create_backup ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role[0].name
}

resource "aws_iam_role_policy_attachment" "backup_restore_policy" {
  count      = var.create_backup ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup_role[0].name
}
