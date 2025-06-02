locals {
  bot_dirs = [for dir in fileset("${path.module}/bots", "*") : dir if can(fileexists("${path.module}/bots/${dir}/pyproject.toml"))]
}

resource "aws_ecr_repository" "bot" {
  for_each = toset(local.bot_dirs)
  name     = each.key
}