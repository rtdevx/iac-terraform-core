# Input variable definitions
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "business_division" {
  description = "Business Division"
  type        = string
}

# NOTE: IAM role-specific

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "github_org" {
  description = "GitHub Organization"
  type        = string
}

variable "github_org_aws_apps" {
  description = "GitHub Organization - rtdevx-aws-apps"
  type        = string
}

# NOTE: Repos

variable "github_repo_core" {
  description = "GitHub Repository"
  type        = string
}

variable "github_repo_infra_jvx" {
  description = "GitHub Repository"
  type        = string
}

variable "github_repo_artifacts_jvx" {
  description = "GitHub Repository"
  type        = string
}

variable "github_repo_ecs_demo_1" {
  description = "GitHub Repository - rtdevx-aws-apps/ecs-demo-1"
  type        = string
}