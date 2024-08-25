# terraform {
#   backend "s3" {
#     bucket = "terraformstates-cli"
#     key    = "terraform/awsinfra.tfstate"
#     region = "eu-west-2"
#   }
# }

provider "aws" {}
