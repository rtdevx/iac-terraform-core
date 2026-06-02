# INFO: Create IAM admin group

resource "aws_iam_group" "admin" {
  name = "admin"
  path = "/"
}

# INFO: Attach users to admin group

resource "aws_iam_group_membership" "admin" {
  name  = "admin-group-membership"
  users = [for user in aws_iam_user.admins : user.name]
  group = aws_iam_group.admin.name
}