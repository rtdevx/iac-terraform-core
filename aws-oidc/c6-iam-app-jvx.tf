# INFO: ################################################################################################
# INFO: IAM GitHub Actions OIDC Permissions for `app-aws` repository.
# INFO: Allows and controls permissions / how GitHub Actions are executing Terraform against AWS infrastructure.
# INFO: ################################################################################################

# NOTE: Create IAM role
# ? https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role.html
# ? https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws

# NOTE: Local values

locals {
  # NOTE: Declare locals for OIDC roles

  oidc_roles_app_aws_jvx = {

    # NOTE: OIDC
    main = {
      name    = "iac-aws-oidcRole-app-jvx"
      subject = "repo:${var.github_org}/${var.github_repo_artifacts_jvx}:ref:refs/heads/main"
    }

  }
}

# NOTE: Create IAM Role for OIDC (environment-specific)
resource "aws_iam_role" "oidc_roles_app_aws_jvx" {
  for_each = local.oidc_roles_app_aws_jvx

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

resource "aws_iam_role_policy" "oidc_policy_aws_jvx" {
  for_each = local.oidc_roles_app_aws_jvx

  name = "${each.value.name}-policy"
  role = aws_iam_role.oidc_roles_app_aws_jvx[each.key].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        # NOTE: Least-privilege policy for GitHub Actions OIDC role.
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",  # Required by `app-aws` GH Actions to clear artifacts bucket
        ]

        Resource = [
          # S3 backend bucket and objects (state)
          "arn:aws:s3:::rk-artifact",
          "arn:aws:s3:::rk-artifact/*",
        ]
      },
      # NOTE: Allow GitHub Actions to ssm:PutParameter in app-aws repository
      {
        Effect = "Allow",
        Action = [
          "ssm:PutParameter"
        ]

        Resource = "arn:aws:ssm:eu-west-2:${var.aws_account_id}:parameter/jvx/version"
      },
      # NOTE: Allow GitHub Actions to autoscaling:StartInstanceRefresh in app-aws repository
      {
        Effect = "Allow",
        Action = [
          "autoscaling:StartInstanceRefresh"
        ]

        Resource = [
          "arn:aws:autoscaling:eu-west-2:${var.aws_account_id}:autoScalingGroup:*:autoScalingGroupName/operations-dev-jvx-asg",
          "arn:aws:autoscaling:eu-west-2:${var.aws_account_id}:autoScalingGroup:*:autoScalingGroupName/operations-stag-jvx-asg",
          "arn:aws:autoscaling:eu-west-2:${var.aws_account_id}:autoScalingGroup:*:autoScalingGroupName/operations-prod-jvx-asg"
          ]
      }

    ]
  })
}