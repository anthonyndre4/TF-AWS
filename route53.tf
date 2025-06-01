locals {
  domains = csvdecode(file(format("./csv/domains.csv")))
}

resource "aws_route53domains_registered_domain" "aws_domains" {
  for_each = { for domain in local.domains : domain.key => domain }

  domain_name = each.value.domain

  dynamic "name_server" {
    for_each = split(",", each.value.name_servers)
    content {
      name = trim(name_server.value, " ")
    }
  }


}