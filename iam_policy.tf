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
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:CreateHostedZone",
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones",
          "route53:GetChange",
          "route53domains:GetDomainDetail",
          "route53domains:ListDomains",
          "route53domains:CheckDomainAvailability",
          "route53domains:ListTagsForDomain"
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

resource "aws_iam_role" "discord_bot_ec2_role" {
  name = "discord-bot-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.discord_bot_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecr_poweruser" {
  role       = aws_iam_role.discord_bot_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "discord_bot_profile" {
  name = "discord-bot-instance-profile"
  role = aws_iam_role.discord_bot_ec2_role.name
}


resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:anthonyndre4/TF-AWS:*"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "github_actions_custom" {
  name        = "github-actions-custom-policy"
  description = "Allow S3, ECR, EC2, IAM groups/users, and MFA actions for GitHub Actions role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:GetGroup",
          "iam:ListGroups",
          "iam:GetUser",
          "iam:ListUsers",
          "iam:ListMFADevices",
          "iam:EnableMFADevice",
          "iam:DeactivateMFADevice",
          "iam:ResyncMFADevice",
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:ListVirtualMFADevices",
          "iam:ListAttachedUserPolicies",
          "iam:ListUserPolicies",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRole",
          "iam:ListAccessKeys",
          "iam:GetOpenIDConnectProvider",
          "iam:GetGroupPolicy",
          "iam:ListRolePolicies",
          "iam:ListGroupPolicies",
          "iam:ListPolicyVersions",
          "iam:ListMFADeviceTags",
          "iam:ListAttachedRolePolicies",
          "iam:GetInstanceProfile",
          "iam:DeletePolicyVersion"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_custom" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_custom.arn
}