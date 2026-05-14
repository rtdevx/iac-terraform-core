# INFO: ################################################################################################
# INFO: IAM GitHub Actions OIDC Permissions for `rtdevx-aws-apps/ecs-demo-1` repository.
# INFO: Allows and controls permissions / how GitHub Actions are executing Terraform against AWS infrastructure.
# INFO: ################################################################################################

# NOTE: Create IAM role
# ? https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role.html
# ? https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws

# NOTE: Local values

locals {
  # NOTE: Declare locals for OIDC roles

  oidc_roles_app_ecs_demo_1 = {

    # NOTE: OIDC
    main = { # ! MAIN TO BE REMOVED
      name    = "iac-aws-oidcRole-app-ecs-demo-1"
      subject = "repo:${var.github_org_aws_apps}/${var.github_repo_ecs_demo_1}:ref:refs/heads/main"
    }

    prod = {
      name    = "iac-aws-oidcRole-app-ecs-demo-1-prod"
      subject = "repo:${var.github_org_aws_apps}/${var.github_repo_ecs_demo_1}:environment:prod:ref:refs/heads/main"
    }

#    stag = {
#      name    = "iac-aws-oidcRole-app-ecs-demo-1-stag"
#      subject = "repo:${var.github_org_aws_apps}/${var.github_repo_ecs_demo_1}#:environment:stag:ref:refs/heads/main"
#    }        

    stag = {
      name    = "iac-aws-oidcRole-app-ecs-demo-1-stag"
      subject = "repo:${var.github_org_aws_apps}/${var.github_repo_ecs_demo_1}:*:ref:refs/heads/main"
    }    

  }
}

# NOTE: Create IAM Role for OIDC (environment-specific)
resource "aws_iam_role" "oidc_roles_app_ecs_demo_1" {
  for_each = local.oidc_roles_app_ecs_demo_1

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

resource "aws_iam_role_policy" "oidc_policy_ecs_demo_1" {
  for_each = local.oidc_roles_app_ecs_demo_1

  name = "${each.value.name}-policy"
  role = aws_iam_role.oidc_roles_app_ecs_demo_1[each.key].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # NOTE: Allow GitHub Actions permissions to edploy to ECS.
      {
        Effect = "Allow",
        Action = [
          # Required to update Task Definition on task-definition resource 
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",          
          # Required to update the Service in the cluster
          "ecs:UpdateService", 
          "ecs:DescribeServices"
        ]

        Resource = [
          # Scoped to a single Task Definition at the moment for the demo purposes
          "arn:aws:ecs:eu-central-1:${var.aws_account_id}:task-definition/ecs-nginx-app1-cicd:*",
          "arn:aws:ecs:eu-central-1:${var.aws_account_id}:service/ecs-fargate/ecs-nginx-app1-cicd-svc-*"
        ]
      },
      # NOTE: Allow iam:passrole to ecsTaskExecutionRole
      /**
      A task execution IAM role is used by the container agent to make AWS API requests on your behalf.

      "ecsTaskExecutionRole" is defined in IAM and is part of the ECS Task Definition:

      Infrastructure requirements -> Task roles - conditional -> Task execution role
      **/          
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole" 
        ]

        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/ecsTaskExecutionRole"
        ]
      },      
      # NOTE: Allow GitHub Actions permissions to push the image to ECR.
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = [
          "arn:aws:ecr:eu-central-1:${var.aws_account_id}:repository/aws-ecr-nginx"
        ]
      },
      # NOTE: Allow GitHub Actions to get "ecr:GetAuthorizationToken".
      /**
      "ecr:GetAuthorizationToken" is a global ECR action and cannot be scoped to a repository ARN.

      This prevents "GitHubActions is not authorized to perform: ecr:GetAuthorizationToken on resource: * because no identity-based policy allows the ecr:GetAuthorizationToken action" ERROR. 
      
      # ! "ecr:GetAuthorizationToken" is required to be scoped on "*" resource. Can it be scoped to "ecr:*" and "ecs:*"?
      **/      
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = [
          "*"
        ]
      }      

    ]
  })
}