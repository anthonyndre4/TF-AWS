resource "aws_iam_virtual_mfa_device" "users-mfa" {
  for_each                = { for index, user in aws_iam_user.users : index => user }
  virtual_mfa_device_name = "user-${each.value.name}-mfa"
  path                    = each.value.path
}