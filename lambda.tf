data "archive_file" "lambda_zip" {
  count       = var.create_event_processor_lambda ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/notification_function/lambda_function.py"
  output_path = "${path.module}/notification_function/lambda_function.zip"
}

resource "aws_lambda_function" "s3_event_processor" {
  count         = var.create_event_processor_lambda ? 1 : 0
  filename      = data.archive_file.lambda_zip[0].output_path
  function_name = "s3_event_processor"
  role          = aws_iam_role.lambda_role[0].arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60

  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256

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
  count             = var.create_event_processor_lambda ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.s3_event_processor[0].function_name}"
  retention_in_days = 14
}