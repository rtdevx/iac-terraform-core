# INFO: IAM Roles

# NOTE: OrganizationAccountAccessRole required to Switch roles. Atached to "AdministratorAccess" policy.

resource "aws_iam_role" "OrganizationAccountAccessRole" {
  assume_role_policy = jsonencode(
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::390157243794:role/OrganizationAccountAccessRole", # NOTE: Root/Management account
                    "arn:aws:iam::293694139465:role/OrganizationAccountAccessRole", # NOTE: core-OU/aws-core-aggregator
                    "arn:aws:iam::639177726268:role/OrganizationAccountAccessRole", # NOTE: core-OU/aws-core-cloudtrail
                    "arn:aws:iam::643681787576:role/OrganizationAccountAccessRole"  # NOTE: core-OU/aws-core-mgmt
                ]
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
  )
  description           = "OrganizationAccountAccessRole"
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "OrganizationAccountAccessRole"
  name_prefix           = null
  path                  = "/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}
}

# INFO: IAM Roles Attach

resource "aws_iam_role_policy_attachment" "OrganizationAccountAccessRole_AdministratorAccess" {
  role       = aws_iam_role.OrganizationAccountAccessRole.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}