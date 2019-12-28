# Project to create a lambda that puts a message into dynamodb

![AWS SQS Architecture](https://photos.app.goo.gl/VNTQCYgvp8jJ1pRt8)
## Step 1: Terraform modules
In this first part we will create a terraform file to load the various pieces we will need.
```sh
mkdir -p terraform/modules
touch terraform/main.tf
```

## First make the terraform folder
We will need to initialize the main module with our access keys. To do this we are going to make use of simple env variables passed in when you invoke the function.

save this to a bash script file

### .secrets/keys.sh
```sh
export TF_VAR_aws_access_key=""
export TF_VAR_aws_secret_key=""
export TF_VAR_aws_default_region="us-east-1"
```

make sure you .gitignore this file 
```sh
$ echo  "*/.secrets" >> .gitignore
$ chmod 700 .secrets/keys.sh
```

You could also optionally put the files in a [tfvars file](https://www.terraform.io/docs/configuration/variables.html). That might be an excercise to explore in the future 😉.

### main.tf
Now let's make the main file which will hold our basic configuration. Terraform needs to setup the provider information so you can actually deploy something to aws. First we will export those variables from the above script. If this file was larger it might make sense to move the variables into another folder, but for now we can just reference them inline. The type is optional here.

```main.tf
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
```

Now go into the directory where you created the main.tf file (I put mine in lambda-sqs-trigger/terraform) and run `terraform init`. Terraform init will install the required packages you need and is the first indication that you are on the right track.

## What you should see after initial creation
```sh
* provider.aws: version = "~> 2.43"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

## Step 2: lets add the sqs queue
Since we are going to publish some events to an sqs queue let's set that up with terraform. We can create a simple sqs/main.tf file to hold our queue initialization.

```sqs/main.tf
# sqs/main
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
```

The `aws_sqs_queue` resource lets us set various things which might be nice in the future like a dead letter queue to trap unsendable messages. However, for now we are going with a simple bare-bones sqs queue. We are leaving the default production tag in there as a reference.

## Applying and creating your first resource
Now we can run terraform plany to see the changes that will be applied to our system. And terraform apply should create the desired resources. You can get a sense of what terraform is going to do to your system before you run your changes. This is a nice feature of terraform. Note: that in production it's often recommeneded to save your output plan terraform state to an s3 bucket as this will make it easier to clean up resources and not duplicate or trump on created resources by different users. There's potentially a big gotcha if you work on a team and don't store your state files in a remote repo fyi.

```sh
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.sqs.aws_sqs_queue.log_message_queue will be created
  + resource "aws_sqs_queue" "log_message_queue" {
      + arn                               = (known after apply)
      + content_based_deduplication       = false
      + delay_seconds                     = 90
      + fifo_queue                        = false
      + id                                = (known after apply)
      + kms_data_key_reuse_period_seconds = (known after apply)
      + max_message_size                  = 2048
      + message_retention_seconds         = 86400
      + name                              = "sqs_log_message_queue"
      + policy                            = (known after apply)
      + receive_wait_time_seconds         = 10
      + tags                              = {
          + "Environment" = "production"
        }
      + visibility_timeout_seconds        = 30
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```
Now that we have this saved, lets apply the changes...
You should see something like this:
```sh
module.sqs.aws_sqs_queue.log_message_queue: Creating...
module.sqs.aws_sqs_queue.log_message_queue: Creation complete after 1s [id=https://sqs.us-east-1.amazonaws.com/071782748104/sqs_log_message_queue]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```
And in the aws terminal:
![Added SQS resource](https://photos.app.goo.gl/rSiaB9oRpVy19Ndx6)

🎉 Congrats! 🎉
You've taken your first step towards terraform sqs data stream.

In Part 2 we will tackle the creation of our terraform resources that we plan to utilize