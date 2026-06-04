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
      subject = "repo:${var.github_org}/${var.github_repo_infra_jvx}:ref:refs/heads/main" 
    }

    stag = {
      name    = "iac-aws-oidcRole-infra-jvx-stag"
      subject = "repo:${var.github_org}/${var.github_repo_infra_jvx}:ref:refs/heads/main" 
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
      # NOTE: Scoped S3 permissions for Terraform backend state.
      {
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
      # NOTE: Scoped S3 permissions to access artifacts bucket.
      {
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
      # NOTE: The following actions manage/create AWS resources (EC2, ELB, ASG, RDS, Route53, ACM, SNS).
      # NOTE: EC2
      {
        Effect   = "Allow"
        Action   = [
          "ec2:Describe*"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ec2:DisassociateAddress" 
        ]
        Resource = "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:*/*" # NOTE: Required to destroy EIP
      },
      { # NOTE: Required For ASG to create / access Launch Template
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:AttachNetworkInterface",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",                            # Required to build VPC
          "ec2:CreateTags",                           # Required to build VPC
          "ec2:DeleteVpc",                            # Required to build VPC
          "ec2:ModifyVpcAttribute",                   # Required to build VPC
          "ec2:CreateSecurityGroup",                  # Required to build VPC
          "ec2:CreateSubnet",                         # Required to build VPC
          "ec2:CreateRouteTable",                     # Required to build VPC
          "ec2:CreateInternetGateway",                # Required to build VPC
          "ec2:AuthorizeSecurityGroupIngress",        # Required to build VPC
          "ec2:AuthorizeSecurityGroupEgress",         # Required to build VPC
          "ec2:AssociateRouteTable",                  # Required to build VPC
          "ec2:AttachInternetGateway",                # Required to build VPC
          "ec2:DeleteNetworkAclEntry",                # Required to build VPC
          "ec2:CreateRoute",                          # Required to build VPC
          "ec2:CreateNatGateway",                     # Required to build VPC
          "ec2:CreateNetworkAclEntry",                # Required to build VPC
          "ec2:RunInstances",                         # Required to build EC2 instance
          "ec2:TerminateInstances",                   # Required to build EC2 instance
          "ec2:AllocateAddress",                      # Required for Elastic IP
          "ec2:AssociateAddress",                     # Required for Elastic IP
          "ec2:ReleaseAddress",                       # Required for Elastic IP
          "ec2:CreateLaunchTemplate",                 # Required to build Launch Template
          "ec2:CreateLaunchTemplateVersion",          # Required to build Launch Template
          "ec2:ModifyLaunchTemplate",                 # Required to build Launch Template
          "ec2:RevokeSecurityGroupIngress",           # Required to perform DESTROY
          "ec2:RevokeSecurityGroupEgress",            # Required to perform DESTROY
          "ec2:DeleteLaunchTemplate",                 # Required to perform DESTROY
          "ec2:DeleteLaunchTemplate",                 # Required to perform DESTROY
          "ec2:DeleteRoute",                          # Required to perform DESTROY
          "ec2:DisassociateRouteTable",               # Required to perform DESTROY
          "ec2:DeleteSecurityGroup",                  # Required to perform DESTROY
          "ec2:DeleteNatGateway",                     # Required to perform DESTROY
          "ec2:DeleteRouteTable",                     # Required to perform DESTROY
          "ec2:DeleteSubnet",                         # Required to perform DESTROY
          "ec2:DetachInternetGateway",                # Required to perform DESTROY
          "ec2:DeleteInternetGateway"                 # Required to perform DESTROY
        ]
        Resource = [
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:vpc/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:security-group/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:security-group-rule/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:subnet/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:route-table/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:internet-gateway/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:network-acl/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:elastic-ip/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:launch-template/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:natgateway/*"
        ]
      },
      # NOTE: Route53
      {
        Effect   = "Allow"
        Action   = [
          "route53:ListHostedZones"
        ]
        Resource = "*"
      },      
      {
        Effect = "Allow"
        Action = [          
          "route53:GetHostedZone",
          "route53:ListTagsForResource",
          "route53:ChangeResourceRecordSets",
          "route53:GetChange",
          "route53:ListResourceRecordSets"
        ]
        Resource = [
          #"arn:aws:route53:::hostedzone/Z0009000UNGSZYNHE9BD"
          "arn:aws:route53:::hostedzone/*",
          "arn:aws:route53:::change/*"
        ]
      },
      # NOTE: ELB
      {
        Effect   = "Allow"
        Action   = [
          "elasticloadbalancing:Describe*"
        ]
        Resource = "*"
      },        
      {
        Effect = "Allow"
        Action = [             
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteLoadBalancer", # Required to delete LB
          "elasticloadbalancing:DeleteTargetGroup",  # Required to delete LB
          "elasticloadbalancing:ModifyTargetGroup",  # Required to Modify Target Group only. TO BE COMMENTED OUT.
          "elasticloadbalancing:ModifyListener",     # Required to Modify Target Group only. TO BE COMMENTED OUT.
          "elasticloadbalancing:ModifyRule"          # Required to Modify Target Group only. TO BE COMMENTED OUT.
        ]
        Resource = [
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:loadbalancer/app/*/*",
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:listener-rule/app/*/*/*/*",
          "arn:aws:elasticloadbalancing:${var.aws_region}:${var.aws_account_id}:targetgroup/*/*"
        ]
      },
      # NOTE: ASG
      {
        Effect   = "Allow"
        Action   = [
          "autoscaling:Describe*"
        ]
        Resource = "*"
      },
      { # NOTE: Required by ASG to manage Launch Templates
        Effect = "Allow"
        Action = [
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:RunInstances"
        ]
        Resource = "*"
      },             
      {
        Effect = "Allow"
        Action = [              
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:AttachLoadBalancerTargetGroups",
          "autoscaling:PutNotificationConfiguration",
          "autoscaling:PutScalingPolicy",
          "autoscaling:PutScheduledUpdateGroupAction",
          "autoscaling:PutScheduledUpdateGroupAction",
          "autoscaling:DeleteNotificationConfiguration",
          "autoscaling:DeleteScheduledAction",
          "autoscaling:DeletePolicy",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DetachLoadBalancerTargetGroups",
          "autoscaling:StartInstanceRefresh" 
        ]
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
          "arn:aws:autoscaling:${var.aws_region}:${var.aws_account_id}:autoScalingGroup:*:autoScalingGroupName/*",
          "arn:aws:autoscaling:${var.aws_region}:${var.aws_account_id}:scalingPolicy:*:autoScalingGroupName/*:policyName/*",
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:launch-template/*" # NOTE: ASG (autoscaling:CreateAutoScalingGroup) requires access to Launch Template
        ]
      },
      # NOTE: IAM
      {
        Effect = "Allow"
        Action = [             
          "iam:CreateRole",                # Required to create IAM roles for SSM access 
          "iam:GetRole",                   # Required to create IAM roles for SSM access
          "iam:ListRolePolicies",          # Required to create IAM roles for SSM access
          "iam:ListAttachedRolePolicies",  # Required to create IAM roles for SSM access
          "iam:CreatePolicy",              # Required to create IAM roles for SSM access
          "iam:GetPolicy",                 # Required to create IAM roles for SSM access
          "iam:GetPolicyVersion",          # Required to create IAM roles for SSM access 
          "iam:ListPolicyVersions",        # Required to create IAM roles for SSM access
          "iam:DeletePolicy",              # Required to create IAM roles for SSM access       
          "iam:AttachGroupPolicy",         # Required to create IAM roles for SSM access
          "iam:ListAttachedGroupPolicies", # Required to create IAM roles for SSM access
          "iam:DetachGroupPolicy",         # Required to create IAM roles for SSM access
          "iam:AttachRolePolicy",          # Required to create IAM roles for SSM access
          "iam:CreateInstanceProfile",     # Required to create IAM roles for SSM access 
          "iam:PutRolePolicy",             # Required to create IAM roles for SSM access
          "iam:PutRolePolicy",             # Required to create IAM roles for SSM access 
          "iam:PutRolePolicy",             # Required to create IAM roles for SSM access
          "iam:GetInstanceProfile",        # Required to create IAM roles for SSM access   
          "iam:GetRolePolicy",             # Required to create IAM roles for SSM access
          "iam:DeleteRolePolicy",          # Required to create IAM roles for SSM access 
          "iam:AddRoleToInstanceProfile",  # Required to create IAM roles for SSM access   
          "iam:PassRole",                  # Required to create IAM roles for SSM access
          "iam:DetachRolePolicy",          # Required to delete IAM roles for SSM access
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:ListInstanceProfilesForRole",
          "iam:DeleteRole"
        ]
        Resource = [
          "*"
        ]
      },
      # NOTE: ACM
      {
        Effect   = "Allow"
        Action   = [
          "acm:DescribeCertificate"
        ]
        Resource = "*"
      },  
      
      {
        Effect = "Allow"
        Action = [             
          "acm:RequestCertificate",
          "acm:ListTagsForCertificate",
          "acm:DeleteCertificate"
        ]
        Resource = [
          "arn:aws:acm:${var.aws_region}:${var.aws_account_id}:certificate/*"
        ]
      },
      # NOTE: SNS
      {
        Effect = "Allow"
        Action = [             
          "SNS:CreateTopic",
          "SNS:SetTopicAttributes",
          "SNS:GetTopicAttributes",
          "SNS:ListTagsForResource",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:GetSubscriptionAttributes",
          "SNS:Unsubscribe"
        ]
        Resource = [
          "arn:aws:sns:${var.aws_region}:${var.aws_account_id}:*"
        ]
      },
      # NOTE: RDS
      {
        Effect   = "Allow"
        Action   = [
          "rds:DescribeDBSubnetGroups",
          "rds:DescribeDBParameterGroups",
          "rds:DescribeDBParameters",
          "rds:DescribeDBInstances"          
        ]
        Resource = "*"
      },      
      {
        Effect = "Allow"
        Action = [             
          "rds:CreateDBSubnetGroup",
          "rds:AddTagsToResource",
          "rds:ListTagsForResource",
          "rds:DeleteDBSubnetGroup",
          "rds:CreateDBParameterGroup",
          "rds:ModifyDBParameterGroup",
          "rds:DeleteDBParameterGroup",
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance" # ! Delete Instance
        ]
        Resource = [
          "arn:aws:rds:${var.aws_region}:${var.aws_account_id}:db:*",
          "arn:aws:rds:${var.aws_region}:${var.aws_account_id}:pg:*", # NOTE: Parameter Group
          "arn:aws:rds:${var.aws_region}:${var.aws_account_id}:subgrp:*" # NOTE: Subnet Group
        ]
      },
      # NOTE: KMS for DB
      {
        Effect   = "Allow"
        Action   = [
          "kms:DescribeKey"
        ]
        Resource = "*"
      },      
      {
        Effect = "Allow"
        Action = [             
          "kms:CreateGrant"
        ]
        Resource = [
          "arn:aws:kms:${var.aws_region}:${var.aws_account_id}:key/*"
        ]
      },
      # NOTE: SSM Secrets manager for DB (db secret for applications) AND EC2 Launch Template (jvx_TLS_Keystore) for internal TLS.
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:CreateSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:*"
      },  

      {
        Effect = "Allow"
        Action = [             
          "secretsmanager:GetSecretValue",
          "secretsmanager:DeleteSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:RotateSecret",
          "secretsmanager:ReplicateSecretToRegions",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "secretsmanager:UpdateSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:PutSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:rds!db-*",
          "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:*" # NOTE: Required for "secretsmanager:GetResourcePolicy"
        ]
      }
    ]
  })
}