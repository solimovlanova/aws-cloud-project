resource "aws_backup_vault" "main" {
  name        = "main-backup-vault-custom"
}

resource "aws_backup_plan" "main" {
  name = "main-backup-plan"

rule {
  rule_name         = "main-backup-rule"
  target_vault_name = aws_backup_vault.main.name
  schedule          = "cron(0 12 * * 0 *)"
  start_window      = 60    # minutes
  completion_window = 300   # minutes
  
  lifecycle {
    delete_after       = 7
  }
}

}

resource "aws_backup_selection" "main_backup" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "backup_selection"
  plan_id      = aws_backup_plan.main.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "true"
  }
}

# Create IAM role for AWS Backup service
resource "aws_iam_role" "backup_role" {
  name = "AWSBackupDefaultServiceRole"
  
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

  tags = {
    Name = "AWS Backup Service Role"
    Purpose = "Backup Operations"
  }
}

# Attach AWS managed policy for backup operations
resource "aws_iam_role_policy_attachment" "backup_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

# Attach AWS managed policy for restore operations
resource "aws_iam_role_policy_attachment" "backup_restore_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.backup_role.name
}
