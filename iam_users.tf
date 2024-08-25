locals {
  iam_users = csvdecode(file(format("./csv/users.csv")))
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