# locals {
#   bots_config = yamldecode(file("${path.module}/bots.yaml"))
#   bot_names   = local.bots_config.bots
# }

# resource "aws_ecr_repository" "bot" {
#   for_each = toset(local.bot_names)
#   name     = each.key
# }