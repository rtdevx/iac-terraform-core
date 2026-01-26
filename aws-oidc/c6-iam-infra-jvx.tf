# INFO: ##############################################################################################################
# INFO: IAM GitHub Actions OIDC Permissions for `iac-terraform-aws-infra-jvx` repository.                             
# INFO: It creates roles and is attaching policies that grant permissions for GitHub Actions                          
# INFO: required to execute terraform configuration in that repo.                                                     
# INFO: ##############################################################################################################

# NOTE: Create IAM role
# ? https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role.html
# ? https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws

# NOTE: Local values

locals {
  # NOTE: Declare locals for multi-environment OIDC roles

  oidc_roles_infra_jvx = {

    prod = {
      name    = "iac-aws-oidcRole-infra-jvx-prod"
      subject = "repo:${var.github_org}/${var.github_repo_infra_jvx}:ref:refs/heads/main"
    }

    dev = {
      name    = "iac-aws-oidcRole-infra-jvx-dev"
      subject = "repo:${var.github_org}/${var.github_repo_infra_jvx}:ref:refs/heads/main" # TODO: Head to be changed to dev. Promoting regions in progress.
    }

    stag = {
      name    = "iac-aws-oidcRole-infra-jvx-stag"
      subject = "repo:${var.github_org}/${var.github_repo_infra_jvx}:ref:refs/heads/main" # TODO: Head to be changed to dev. Promoting regions in progress.
    }

  }

}

# NOTE: Create IAM Role for OIDC (environment-specific)
resource "aws_iam_role" "oidc_roles_infra_jvx" {
  for_each = local.oidc_roles_infra_jvx

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

resource "aws_iam_role_policy" "oidc_policy_infra_jvx" {
  for_each = local.oidc_roles_infra_jvx

  name = "${each.value.name}-policy"
  role = aws_iam_role.oidc_roles_infra_jvx[each.key].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # NOTE: Scoped S3 permissions for Terraform backend state.
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::rk-backend",
          "arn:aws:s3:::rk-backend/*"
        ]
      },
      {
        # NOTE: Scoped S3 permissions to access artifacts bucket.
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject", # ! In review. Does application need to write to the artifacts bucket?
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::rk-artifact",
          "arn:aws:s3:::rk-artifact/*"
        ]
      },
      {
        # NOTE: The following actions manage/create AWS resources (EC2, ELB, ASG, RDS, Route53, ACM, SNS).
        # Many "Create"/"Delete" actions require Resource = "*"; narrow further if you can supply specific ARNs.
        Effect = "Allow"
        Action = [
          # EC2  
          "ec2:DescribeAvailabilityZones",            # Required to build VPC
          "ec2:CreateVpc",                            # Required to build VPC
          "ec2:CreateTags",                           # Required to build VPC
          "ec2:DescribeVpcs",                         # Required to build VPC
          "ec2:DescribeVpcAttribute",                 # Required to build VPC
          "ec2:DeleteVpc",                            # Required to build VPC
          "ec2:ModifyVpcAttribute",                   # Required to build VPC
          "ec2:CreateSecurityGroup",                  # Required to build VPC
          "ec2:CreateSubnet",                         # Required to build VPC
          "ec2:CreateRouteTable",                     # Required to build VPC
          "ec2:CreateInternetGateway",                # Required to build VPC
          "ec2:DescribeSecurityGroups",               # Required to build VPC
          "ec2:DescribeRouteTables",                  # Required to build VPC
          "ec2:DescribeSecurityGroupRules",           # Required to build VPC
          "ec2:DescribeSubnets",                      # Required to build VPC
          "ec2:DescribeInternetGateways",             # Required to build VPC
          "ec2:DescribeNetworkAcls",                  # Required to build VPC
          "ec2:DescribeAddresses",                    # Required to build VPC
          "ec2:DescribeAddressesAttribute",           # Required to build VPC
          "ec2:DescribeNatGateways",                  # Required to build VPC
          "ec2:AuthorizeSecurityGroupIngress",        # Required to build VPC
          "ec2:AuthorizeSecurityGroupEgress",         # Required to build VPC
          "ec2:AssociateRouteTable",                  # Required to build VPC
          "ec2:AttachInternetGateway",                # Required to build VPC
          "ec2:DeleteNetworkAclEntry",                # Required to build VPC
          "ec2:CreateRoute",                          # Required to build VPC
          "ec2:CreateNatGateway",                     # Required to build VPC
          "ec2:CreateNetworkAclEntry",                # Required to build VPC
          "ec2:DescribeImages",                       # Required for EC2 instance related AWS Data Source
          "ec2:RunInstances",                         # Required to build EC2 instance
          "ec2:DescribeInstances",                    # Required to build EC2 instance
          "ec2:DescribeInstanceTypes",                # Required to build EC2 instance
          "ec2:DescribeTags",                         # Required to build EC2 instance
          "ec2:DescribeInstanceAttribute",            # Required to build EC2 instance
          "ec2:DescribeVolumes",                      # Required to build EC2 instance
          "ec2:DescribeInstanceCreditSpecifications", # Required to build EC2 instance
          "ec2:TerminateInstances",                   # Required to build EC2 instance
          "ec2:AllocateAddress",                      # Required for Elastic IP
          "ec2:AssociateAddress",                     # Required for Elastic IP
          "ec2:ReleaseAddress",                       # Required for Elastic IP
          "ec2:CreateLaunchTemplate",                 # Required to build Launch Template
          "ec2:DescribeLaunchTemplates",              # Required to build Launch Template
          "ec2:DescribeLaunchTemplateVersions",       # Required to build Launch Template
          "ec2:CreateLaunchTemplateVersion",          # Required to build Launch Template
          "ec2:ModifyLaunchTemplate",                 # Required to build Launch Template
          "ec2:RevokeSecurityGroupIngress",           # Required to perform DESTROY
          "ec2:RevokeSecurityGroupEgress",            # Required to perform DESTROY
          "ec2:DeleteLaunchTemplate",                 # Required to perform DESTROY
          "ec2:DisassociateAddress",                  # Required to perform DESTROY
          "ec2:DeleteLaunchTemplate",                 # Required to perform DESTROY
          "ec2:DescribeNetworkInterfaces",            # Required to perform DESTROY
          "ec2:DeleteRoute",                          # Required to perform DESTROY      
          "ec2:DisassociateRouteTable",               # Required to perform DESTROY
          "ec2:DeleteSecurityGroup",                  # Required to perform DESTROY
          "ec2:DeleteNatGateway",                     # Required to perform DESTROY
          "ec2:DeleteRouteTable",                     # Required to perform DESTROY
          "ec2:DeleteSubnet",                         # Required to perform DESTROY
          "ec2:DetachInternetGateway",                # Required to perform DESTROY
          "ec2:DeleteInternetGateway",                # Required to perform DESTROY
          # Route53
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListTagsForResource",
          "route53:ChangeResourceRecordSets",
          "route53:GetChange",
          "route53:ListResourceRecordSets",
          # ELB
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteLoadBalancer", # Required to delete LB
          "elasticloadbalancing:DeleteTargetGroup",  # Required to delete LB
          # ASG
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:AttachLoadBalancerTargetGroups",
          "autoscaling:PutNotificationConfiguration",
          "autoscaling:PutScalingPolicy",
          "autoscaling:PutScheduledUpdateGroupAction",
          "autoscaling:PutScheduledUpdateGroupAction",
          "autoscaling:DescribeNotificationConfigurations",
          "autoscaling:DescribePolicies",
          "autoscaling:DescribeScheduledActions",
          "autoscaling:DescribeScheduledActions",
          "autoscaling:DeleteNotificationConfiguration",
          "autoscaling:DeleteScheduledAction",
          "autoscaling:DeletePolicy",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DetachLoadBalancerTargetGroups",
          "autoscaling:StartInstanceRefresh",
          # ACM
          "acm:RequestCertificate",
          "acm:DescribeCertificate",
          "acm:ListTagsForCertificate",
          "acm:DeleteCertificate",
          # SNS
          "SNS:CreateTopic",
          "SNS:SetTopicAttributes",
          "SNS:GetTopicAttributes",
          "SNS:ListTagsForResource",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:GetSubscriptionAttributes",
          "SNS:Unsubscribe",
          # RDS
          "rds:CreateDBSubnetGroup",
          "rds:AddTagsToResource",
          "rds:DescribeDBSubnetGroups",
          "rds:ListTagsForResource",
          "rds:DeleteDBSubnetGroup"
        ]
        Resource = "*"
      }
    ]
  })
}