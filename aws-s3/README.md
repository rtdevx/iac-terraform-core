# S3 Backend for my Terraform project's .tfstate file

## Output values

Below values (s3 bucket) will be served as a backend for .tfstate file for any future projects.

- bucket_arn = "arn:aws:s3:::rk-backend"
- bucket_domain_name = "rk-backend.s3.amazonaws.com"
- bucket_id = "rk-backend"
- bucket_region = "eu-west-2"
- bucket_regional_domain_name = "rk-backend.s3.eu-west-2.amazonaws.com"

## Terraform Backend

### Naming convention for terraform backends

Enabling S3 backend for Terraform remote state:

```shell
    bucket = "backend-bucket-name"
    key    = "github-repository/your-folder/terraform.tfstate"
```

### Example:

_File:_ `MY_PROJECT/c1-versions.tf`

```shell
# INFO: Terraform Block
# INFO: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#example-usage

# INFO: Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default" # NOTE: AWS Credentials Profile (profile = "default") configured on your local desktop terminal ($HOME/.aws/credentials)
}

terraform {
  required_version = "~> 1.14.0" # NOTE: Greater than 1.14.0. Only the most upright version number (.0) can change.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # NOTE: Greater than 6.0. Only the most upright version number (.0) can change.
    }
  }

  # INFO: S3 Backend Block
  backend "s3" {
    bucket = "rk-backend"
    key    = "terraform-core/aws-codepipelines/terraform.tfstate"
    region = "eu-west-2"
    //dynamodb_table = "prod-a1s3backend-lock" # NOTE: Uncomment to enable state locking with DynamoDB. Table must be created in `c1-dynamodb-lock.tf`.
    encrypt = true
  }

}
```
### ℹ️ If required, terraform backend can be reinitialized with `terraform init --migrate-state` command.

### Bucket Versioning

Bucket versioning is currently NOT REQUIRED, therefore it is disabled at the module level.

If versioning has to be enabled, adjust below file:

 _File:_ `a1-s3-backend/modules/aws-s3-backend/main`

```shell
# INFO: Enable S3 bucket versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Disabled" # Currently not required.
  }
}
```
## State Locking

### Create DynamoDB Table

```shell
# INFO: Create a basic DynamoDB table

resource "aws_dynamodb_table" "statelock" {
  name         = "prod-a1s3backend-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # NOTE: S = String, N = Number, B = Binary
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = local.common_tags

}
```

### Enable DynamoDB statelock

Modify `MY_PROJECT/c1-versions.tf` (see [Bucket Versioning](#bucket-versioning)) file and enable `//dynamodb_table = "prod-a1s3backend-lock"` line with the DynamoDB Table details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_artifacts"></a> [s3\_artifacts](#module\_s3\_artifacts) | ./modules/aws-s3 | n/a |
| <a name="module_s3_backends"></a> [s3\_backends](#module\_s3\_backends) | ./modules/aws-s3 | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID used to construct role ARNs | `string` | `"390157243794"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_bucket_name_artifacts"></a> [bucket\_name\_artifacts](#input\_bucket\_name\_artifacts) | Name prefix of the S3 bucket. | `string` | n/a | yes |
| <a name="input_bucket_name_s3backend"></a> [bucket\_name\_s3backend](#input\_bucket\_name\_s3backend) | Name prefix of the S3 backend bucket. | `string` | n/a | yes |
| <a name="input_business_division"></a> [business\_division](#input\_business\_division) | Business Division | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tages to set on the bucket | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn_artifacts"></a> [bucket\_arn\_artifacts](#output\_bucket\_arn\_artifacts) | ARN of the S3 Bucket |
| <a name="output_bucket_arn_backend"></a> [bucket\_arn\_backend](#output\_bucket\_arn\_backend) | ARN of the S3 Bucket |
| <a name="output_bucket_domain_name_artifacts"></a> [bucket\_domain\_name\_artifacts](#output\_bucket\_domain\_name\_artifacts) | Bucket Domain Name of the S3 Bucket |
| <a name="output_bucket_domain_name_backend"></a> [bucket\_domain\_name\_backend](#output\_bucket\_domain\_name\_backend) | Bucket Domain Name of the S3 Bucket |
| <a name="output_bucket_id_artifacts"></a> [bucket\_id\_artifacts](#output\_bucket\_id\_artifacts) | Name (id) of the bucket |
| <a name="output_bucket_id_backend"></a> [bucket\_id\_backend](#output\_bucket\_id\_backend) | Name (id) of the bucket |
| <a name="output_bucket_region_artifacts"></a> [bucket\_region\_artifacts](#output\_bucket\_region\_artifacts) | S3 Bucket Region |
| <a name="output_bucket_region_backend"></a> [bucket\_region\_backend](#output\_bucket\_region\_backend) | S3 Bucket Region |
| <a name="output_bucket_regional_domain_name_artifacts"></a> [bucket\_regional\_domain\_name\_artifacts](#output\_bucket\_regional\_domain\_name\_artifacts) | Regional Domain Name of the S3 Bucket |
| <a name="output_bucket_regional_domain_name_backend"></a> [bucket\_regional\_domain\_name\_backend](#output\_bucket\_regional\_domain\_name\_backend) | Regional Domain Name of the S3 Bucket |
<!-- END_TF_DOCS -->