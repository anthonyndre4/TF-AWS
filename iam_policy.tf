resource "aws_iam_group_policy" "ro_custom_policy" {
  name  = "readonly-aws-policy"
  group = aws_iam_group.aws-RO.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
        ],
        "Resource" : [
          "arn:aws:s3:::terraformstates-cli",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ReadFromRepository",
          "codeartifact:List*",
          "codeartifact:Get*",
          "codeartifact:Describe*"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_policy" "require_mfa_policy" {
  name        = "RequireMfaPolicy"
  description = "Policy requiring MFA authentication for sensitive actions."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Deny",
        "Action" : [
          "s3:DeleteObject",
          "iam:DeleteUser",
          "iam:PutUserPolicy",
          "iam:DeleteUserPolicy",
          "codeartifact:Delete*",
          "secretsmanager:DeleteSecret",
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "aws:MultiFactorAuthPresent" : "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_mfa_policy" {
  for_each   = { for index, user in aws_iam_user.users : index => user }
  user       = each.value.name
  policy_arn = aws_iam_policy.require_mfa_policy.arn
}