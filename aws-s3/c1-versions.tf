# INFO: Terraform Block
# INFO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#example-usage

terraform {
  required_version = "~> 1.13.0" # NOTE: Greater than 1.13.2. Only the most upright version number (.0) can change.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # NOTE: Greater than 6.0. Only the most upright version number (.0) can change.
    }
  }

  # INFO: S3 Backend Block
  backend "s3" {
    bucket = "rk-backend"
    key    = "iac-terraform-aws/core/aws-s3/terraform.tfstate"
    region = "eu-west-2"
    //dynamodb_table = "prod-a1s3backend-lock" # NOTE: Uncomment to enable state locking with DynamoDB. Table must be created in `c1-dynamodb-lock.tf`.
    encrypt = true
  }

}

# INFO: Provider Block
provider "aws" {
  region = var.aws_region
}