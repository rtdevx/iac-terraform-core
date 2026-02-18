# INFO: ##############################################################################################################
# INFO: Attach "AdministratorAccess" policy to "admin" group.                                                         
# INFO: ##############################################################################################################

resource "aws_iam_group_policy_attachment" "admin_AdministratorAccess" {
  group      = "admin"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}