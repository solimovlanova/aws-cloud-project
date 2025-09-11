data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/notification_function/lambda_function.py"
  output_path = "${path.module}/notification_function/lambda_function.zip"
}

resource "aws_lambda_function" "s3_event_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "s3_event_processor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.11"
  timeout         = 60
  
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  environment {
    variables = {
      LOG_LEVEL      = "INFO"
      RECIPIENT_NAME = "Soli"
      SENDER_NAME    = "AWS Notification System"
      SNS_TOPIC_ARN  = aws_sns_topic.eventbridge_topic.arn
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.s3_event_processor.function_name}"
  retention_in_days = 14
}