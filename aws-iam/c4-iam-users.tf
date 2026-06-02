# INFO: Create IAM admin users.

# NOTE: Users are defined in `c2-iam-users-variables.tf`

resource "aws_iam_user" "admins" {
  for_each = var.user_admins
  name     = each.value
  path     = "/users/admins/"
}

/*

# INFO: Generate IAM Access Key for admins

# ! Although IAM access keys can be created automatically, they will be stored in terraform state. I will create access keys manually for each user for that reason. Other solutions (i.e. AWS Tower?) to be investigated.

resource "aws_iam_access_key" "admins" {
  for_each = var.user_admins
  user = each.value
}

*/

# TODO: Add MFA to "robk" user and enable console access