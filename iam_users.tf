locals {
  iam_users  = csvdecode(file(format("./csv/users.csv")))
  for_each   = { for index, user in aws_iam_user.users : index => user }
  users      = [each.value.name]
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_user" "users" {
  for_each = { for user in local.iam_users : user.key => user }

  name = each.value.name

  tags = {
    "groups" = each.value.group
  }
}

resource "aws_iam_access_key" "lb" {
  for_each = {
    for user in local.iam_users : user.key => user
  }
  user       = each.value.name
  depends_on = [aws_iam_user.users]
}