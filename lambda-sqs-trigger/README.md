# Project to create a lambda that puts a message into dynamodb

![AWS SQS Architecture](https://photos.google.com/album/AF1QipO-OOEQMkxk-G8sd7IqsjfRqtBp4fHGyxtJ5nFL/photo/AF1QipO9w-uMWMndYIfYqk2rH1V1qXUA-qSUR_hfJiW5)
## Step 1: Terraform modules
In this first part we will create a terraform file to load the various pieces we will need.
```sh
mkdir -p terraform/modules
touch terraform/main.tf
```

## First make the terraform folder
We will need to initialize the main module with our access keys. To do this we are going to make use of simple env variables passed in when you invoke the function.

save this to a bash script file

.secrets/keys.sh
```sh
export TF_VAR_aws_access_key=""
export TF_VAR_aws_secret_key=""
export TF_VAR_aws_default_region="us-east-1"
```

make sure you .gitignore this file 
```
$ echo  "*/.secrets" >> .gitignore
```


### The tfvars
Make a file aws.tfvars that we will load when we initialize terraform:

```tf
variable "aws_default_region" {
    default = "us-east-1"
}
variable "aws_access_key" {}
variable "aws_secret_key" {}
```

Here's how you would use that file
`terraform apply -var-file="aws.tfvars"`


### main.tf
```tf
provider "aws" {
  region     = "aws_default_region"
  access_key = "aws_access_key"
  secret_key = "aws_secret_key"
}
```

Now go into the directory where you created the main.tf file (I put min in lambda-sqs-trigger/terraform) and run `terraform init`

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

In Part 2 we will tackle the creation of our terraform resources that we plan to utilize