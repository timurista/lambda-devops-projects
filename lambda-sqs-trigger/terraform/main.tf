# terraform/main

variable "aws_default_region" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}


provider "aws" {
  region = var.aws_default_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "sqs" {
    source ="./sqs"
}

module "dynamo" {
    source ="./dynamo"
}

module "lambda" {
    source = "./lambda"
    sqs_queue = "${module.sqs.sqs_queue}"
    dynamo_table = "${module.dynamo.message_table}"
}

output "sqs_queue_name" {
  value = module.sqs.sqs_queue.name
}