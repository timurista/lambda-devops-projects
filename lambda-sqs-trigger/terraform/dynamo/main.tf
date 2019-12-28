# dynamodb

resource "aws_dynamodb_table" "message_dynamodb_table" {
  name           = "Message"
  billing_mode   = "PAY_PER_REQUEST"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "MessageId"

  attribute {
    name = "MessageId"
    type = "S"
  }

  tags = {
    Name        = "message_dynamodb_table"
    Environment = "production"
  }
}

output "message_table" {
  value       = aws_dynamodb_table.message_dynamodb_table
  description = "The name of the dynamo db table"
}
