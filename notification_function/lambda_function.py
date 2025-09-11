import boto3
import json
import os
import logging

# Setup logging for Lambda environment
def setup_logging():
    log_level = os.environ.get('LOG_LEVEL', 'INFO').upper()
    valid_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']
    if log_level not in valid_levels:
        log_level = 'INFO'
    logger = logging.getLogger()
    if not logger.handlers:
        logger.setLevel(getattr(logging, log_level))
        handler = logging.StreamHandler()
        handler.setLevel(getattr(logging, log_level))
        formatter = logging.Formatter(
            '%(levelname)s - %(name)s - %(funcName)s:%(lineno)d - %(message)s'
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    else:
        logger.setLevel(getattr(logging, log_level))
        for handler in logger.handlers:
            handler.setLevel(getattr(logging, log_level))
    return logger

logger = setup_logging()

def lambda_handler(event, context):
    logger.info('Lambda function started')
    logger.debug('Received event: %s', json.dumps(event, default=str))
    try:
        sns_client = boto3.client('sns')

        sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
        if not sns_topic_arn:
            logger.error('SNS_TOPIC_ARN environment variable is not set')
            raise ValueError('SNS_TOPIC_ARN environment variable missing')

        logger.debug('Using SNS topic ARN: %s', sns_topic_arn)

        # Support both S3 event formats: direct S3 event or EventBridge event
        if 'Records' in event:
            record = event['Records'][0]
            bucket_name = record.get('s3', {}).get('bucket', {}).get('name', 'unknown-bucket')
            object_key = record.get('s3', {}).get('object', {}).get('key', 'unknown-key')
            event_name = record.get('eventName', '').lower()
        else:
            detail = event.get('detail', {})
            bucket_name = detail.get('bucket', {}).get('name', 'unknown-bucket')
            object_key = detail.get('object', {}).get('key', 'unknown-key')
            event_name = detail.get('eventName', '').lower()

        logger.info('Processing S3 event - Bucket: %s, Object: %s, Event: %s',
                    bucket_name, object_key, event_name)

        if 'delete' in event_name:
            action = "deleted"
        elif 'put' in event_name or 'copy' in event_name or 'post' in event_name:
            action = "modified"
        else:
            action = "updated"

        logger.info('Determined action: %s', action)

        recipient_name = os.environ.get('RECIPIENT_NAME', 'User')
        sender_name = os.environ.get('SENDER_NAME', 'AWS Notification System')

        logger.debug('Email will be sent to: %s, from: %s', recipient_name, sender_name)

        # Fixed multi-line message_body with triple-quoted f-string
        message_body = f"""Hi {recipient_name},

I hope this message finds you well.
This is to inform you that the object with the key '{object_key}' in the bucket '{bucket_name}' has been {action}.

Best regards,
Your {sender_name}"""

        subject = f"S3 Object {action.capitalize()} Notification"
        logger.debug('Message subject: %s', subject)
        logger.debug('Message body: %s', message_body)

        logger.info('Publishing message to SNS topic')
        response = sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=message_body,
            Subject=subject
        )

        message_id = response.get('MessageId')
        logger.info('Successfully sent notification - MessageId: %s, Action: %s',
                    message_id, action)

        return {
            'statusCode': 200,
            'messageId': message_id,
            'action': action,
            'bucket': bucket_name,
            'object': object_key
        }

    except Exception as e:
        logger.error('Error in lambda_handler: %s', str(e), exc_info=True)
        return {
            'statusCode': 500,
            'error': str(e)
        }
    finally:
        logger.info('Lambda function completed')
