resource "aws_iam_user" "terraform" {
  name = "tf_manager"
  path = "/"
}

resource "aws_iam_user" "readonly_user" {
  name = "ReadOnlyUser"
}

resource "aws_iam_group" "readonly_group" {
  name = "ReadOnlyGroup"
}

resource "aws_iam_user_group_membership" "readonly_membership" {
  user = aws_iam_user.readonly_user.name
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
      Version   = "2012-10-17",
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
      Version   = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = "s3:*",
          Resource = "arn:aws:s3:::*"
        },
        {
          Effect   = "Allow",
          Action   = [
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
          Effect   = "Allow",
          Action   = [
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
      Version   = "2012-10-17",
      Statement = [{
        Effect   = "Deny",
        Action   = [
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
      Version   = "2012-10-17",
      Statement = [
        {
          Effect   = "Deny",
          Action   = [
            "ec2:RunInstances",
            "rds:CreateDBInstance",
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
          Resource = "*",
          Condition = {
            StringNotEquals = {
              "ec2:InstanceType" = [
                "t2.micro",
                "t3.micro",
                "t4g.micro"
              ]
            },
            NumericNotLessThanEquals = {
              "ec2:VolumeSize"       = 15,
              "rds:AllocatedStorage" = 20
            }
          }
        },
        {
          Effect   = "Allow",
          Action   = [
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
