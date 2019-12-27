resource "aws_sqs_queue" "log_message_queue" {
  name                      = "sqs_log_message_queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Environment = "production"
  }
}

output "sqs_queue" {
  value       = aws_sqs_queue.log_message_queue.id
  description = "The name of the sqs queue for logging messages"
}