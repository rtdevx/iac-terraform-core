# INFO: ##############################################################################################################
# INFO: IAM GitHub Actions OIDC Permissions for `iac-terraform-core` repository.                                      
# INFO: This configuration file allows GitHub Actions execute `iac-terraform-core\aws-oidc` terraform configuration.  
# INFO: GitHub Actions jobs: `02-00-core-aws-oidc.yml`                                                                
# INFO: ##############################################################################################################

# NOTE: Create IAM role
# ? https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role.html
# ? https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws

# NOTE: Local values

locals {
  # NOTE: Declare locals for OIDC roles

  oidc_roles = {

    # NOTE: OIDC
    main = {
      name    = "iac-aws-oidcRole-oidc"
      subject = "repo:${var.github_org}/${var.github_repo_core}:ref:refs/heads/main"
    }

  }
}

# NOTE: Create IAM Role for OIDC (environment-specific)
resource "aws_iam_role" "oidc_roles" {
  for_each = local.oidc_roles

  name = each.value.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com" }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike   = { "token.actions.githubusercontent.com:sub" = each.value.subject }
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
      }
    }]
  })

  tags = local.common_tags

}

# NOTE: Attach IAM policy to IAM role

resource "aws_iam_role_policy" "oidc_policy_oidc" {
  for_each = local.oidc_roles

  name = "${each.value.name}-policy"
  role = aws_iam_role.oidc_roles[each.key].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      # NOTE: Least-privilege policy for GitHub Actions OIDC role.
      # - S3: limited to the known backend bucket used for Terraform state.
      # - IAM: read/list permissions scoped to TF-related roles in this account (wildcard for `iac-aws-oidcRole--*`).
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetBucketPolicy",                  # Required specifically by GitHub Actions
        "s3:GetBucketAcl",                     # Required specifically by GitHub Actions
        "s3:GetBucketCORS",                    # Required specifically by GitHub Actions
        "s3:GetBucketWebsite",                 # Required specifically by GitHub Actions
        "s3:GetBucketVersioning",              # Required specifically by GitHub Actions
        "s3:GetAccelerateConfiguration",       # Required specifically by GitHub Actions
        "s3:GetBucketRequestPayment",          # Required specifically by GitHub Actions
        "s3:GetBucketLogging",                 # Required specifically by GitHub Actions
        "s3:GetLifecycleConfiguration",        # Required specifically by GitHub Actions
        "s3:GetReplicationConfiguration",      # Required specifically by GitHub Actions
        "s3:GetEncryptionConfiguration",       # Required specifically by GitHub Actions
        "s3:GetBucketObjectLockConfiguration", # Required specifically by GitHub Actions
        "s3:GetBucketTagging",                 # Required specifically by GitHub Actions
        "s3:GetBucketOwnershipControls",       # Required specifically by GitHub Actions
        "s3:CreateBucket",                     # Required by GitHub Actions to create Bucket
        "s3:PutBucketTagging",                 # Required by GitHub Actions to create Bucket
        "s3:DeleteBucket",                     # Required by GitHub Actions to create Bucket
        "s3:PutBucketOwnershipControls",       # Required by GitHub Actions to create Bucket
        "s3:PutBucketPolicy",                  # Required by GitHub Actions to create Bucket
        "iam:GetRole",
        "iam:GetOpenIDConnectProvider",
        "iam:ListRolePolicies",
        "iam:GetRolePolicy",
        "iam:ListAttachedRolePolicies",
        #"iam:ListAttachedGroupPolicies",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:CreateRole",
        "iam:TagRole",
        "iam:CreatePolicy",
        "iam:ListInstanceProfilesForRole", # Required by GitHub Actions to delete role
        "iam:DeleteRole",                  # Required by GitHub Actions to delete role
        "iam:UpdateAssumeRolePolicy"
      ]

      Resource = [
        # S3 backend bucket and objects (state)
        "arn:aws:s3:::rk-backend",
        "arn:aws:s3:::rk-backend/*",
        "arn:aws:s3:::rk-artifact",
        "arn:aws:s3:::rk-artifact/*",

        # Allow read access to IAM roles/policies that match iac-aws-oidcRole-* in this account
        "arn:aws:iam::${var.aws_account_id}:role/iac-aws-oidcRole-*",
        #"arn:aws:iam::${var.aws_account_id}:group/admin",
        "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com" # Required by iam:GetOpenIDConnectProvider
      ]

    }]
  })
}