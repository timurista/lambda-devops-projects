# lambda/main

variable "sqs_queue" {}
variable "dynamo_table" {}
variable "max_batch_size" {
  default = 10
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
 
resource "aws_iam_policy" "policy_for_lambda" {
  name = "policy_for_lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Action": [
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "${var.dynamo_table.arn}"
    },
    {
      "Action": [
        "sqs:Describe*",
        "sqs:Get*",
        "sqs:List*",
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage"
      ],
      "Effect": "Allow",
      "Resource": "${var.sqs_queue.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.policy_for_lambda.arn}"
}

resource "random_id" "uuid" {
  byte_length = 4
}

resource "aws_lambda_function" "lambda_fn" {
  function_name = "lambda_fn_${random_id.uuid.hex}"
  filename      = "lambda_function.zip"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "lambda_handler.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${base64sha256("lambda_function.zip")}"

  runtime = "python3.7"

  environment {
    variables = {
      QUEUE_NAME = var.sqs_queue.name
      MAX_QUEUE_MESSAGES = var.max_batch_size
      DYNAMODB_TABLE = var.dynamo_table.name
    }
  }
}

# lambda triggers
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = var.max_batch_size
  event_source_arn  = var.sqs_queue.arn
  enabled           = true
  function_name     = aws_lambda_function.lambda_fn.arn
}

output "lambda_fn" {
  value       = aws_lambda_function.lambda_fn
  description = "The lambda function"
}