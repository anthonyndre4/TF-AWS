resource "aws_iam_group" "developers" {
  name = "developers-rw"
  path = "/groups/"
}


resource "aws_iam_group" "aws-RO" {
  name = "aws-RO"
  path = "/groups/"
}

resource "aws_iam_group_membership" "readonly_membership" {
  for_each = { for index, user in aws_iam_user.users : index => user }

  group      = aws_iam_group.aws-RO.name
  name       = each.value.name
  users      = [each.value.name]
  depends_on = [aws_iam_user.users]
}