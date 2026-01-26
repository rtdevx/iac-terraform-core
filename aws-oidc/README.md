# OIDC IAM Role for GitHub Actions

I use Terraform to manage IAM Roles for OIDC connectivity to AWS. I use GitHub Actions to ensure this gets deployed nightly to prevent (overwrite!) manual policy changes. 

<font color=#C7EB25>Each infrastructure that is defined in terraform will use GitHub Actions to deploy resources in AWS</font>, using OpenID Connect (OIDC).

In this way, I can automatically control the roles and configurations for Terraform infrastructure pipelines that are deploying infrastructures to AWS.

All policies use **least-privilege** approach.

Note that _GitHub Actions Workflow_ is calling _OIDC Provider_ (`IAM > Access Management > Identity Providers`, defined in `c4-oidc-provider.tf`) both, _GitHub Actions Workflow_ as well as _OIDC Provider_ must be deployed in the same region.

Even though IAM itself is global, the _STS API_ endpoint that _GitHub Actions_ calls to assume the role is regional.

_More info:_ [https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws)

## Code breakdown

1. Ensure OIDC Provider for GitHub is present

📄 _File:_ c4-oidc-provider.tf

2. Create IAM role and IAM Policy to manage OIDC connectivity

Ensures that terraform configuration from `iac-terraform-core` repository can be run using GitHub Actions.

This terraform configuration ensures it can apply OIDC permissions for other infrastructure elements (i.e. 📄 _File:_ c6-iam-app-jvx.tf, 📄 _File:_ c6-iam-infra-jvx.tf).

3. Apply IAM permissions for `iac-terraform-aws-jvx` repository

This terraform configuration ensures it can apply OIDC permissions for `iac-terraform-aws-jvx` so it can be built / destroyed using GitHub Actions.

4. Apply IAM permissions for `app-aws` repository

📄 _File:_ c6-iam-app-jvx.tf

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.oidc_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.oidc_roles_app_aws_jvx_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.oidc_roles_infra_jvx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.oidc_policy_aws_jvx_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.oidc_policy_infra_jvx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.oidc_policy_oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_business_division"></a> [business\_division](#input\_business\_division) | Business Division | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub Organization | `string` | n/a | yes |
| <a name="input_github_repo_artifacts_jvx"></a> [github\_repo\_artifacts\_jvx](#input\_github\_repo\_artifacts\_jvx) | GitHub Repository | `string` | n/a | yes |
| <a name="input_github_repo_core"></a> [github\_repo\_core](#input\_github\_repo\_core) | GitHub Repository | `string` | n/a | yes |
| <a name="input_github_repo_infra_jvx"></a> [github\_repo\_infra\_jvx](#input\_github\_repo\_infra\_jvx) | GitHub Repository | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->