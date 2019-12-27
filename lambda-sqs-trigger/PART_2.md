# Part 2 (Define the terraform resource)

![AWS SQS Architecture](https://photos.app.goo.gl/VNTQCYgvp8jJ1pRt8)

## Step 2: Terraform module sqs
In the second part we create the SQS queue in the sqs/main.tf.
```tf
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
  value       = aws_sqs_queue.terraform_queue.name
  description = "The name of the sqs queue for logging messages"
}
```

## Testing the module
In part 1 we 