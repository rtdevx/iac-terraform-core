# NOTE: Bucket to store Terraform State S3 Backends

module "s3_backends" {
  source     = "./modules/aws-s3"
  aws_region = var.aws_region
  //bucket_name = "${var.bucket_name_prefix}-${var.environment}"
  bucket_name = var.bucket_name_s3backend

  # Set allowed principals for GitHub Actions to access S3 Backends
  allowed_principals = [
    "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-oidc",
    "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-infra-jvx-dev",
    "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-infra-jvx-stag",
    "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-infra-jvx-prod"
  ]

  tags = local.common_tags

}

# NOTE: Bucket to store Artifacts

module "s3_artifacts" {
  source     = "./modules/aws-s3"
  aws_region = var.aws_region
  //bucket_name = "${var.bucket_name_prefix}-${var.environment}"
  bucket_name = var.bucket_name_s3artifacts

  # Set allowed principals for jvx application's GitHub Actions to access S3 Artifacts (dev/stag/prod)
  allowed_principals = [
    # INFO: app-aws can access S3 artifacts
    "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-app-jvx-artifacts",
    # INFO: Infrastructure can access S3 artifacts
    "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-infra-jvx-dev",
    "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-infra-jvx-stag",
    "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-infra-jvx-prod"
  ]

  tags = local.common_tags

}