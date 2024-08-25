locals {
  domains = csvdecode(file(format("./csv/domains.csv")))
}

resource "aws_route53domains_domain" "aws_domains" {
  for_each = { for domain in local.domains : domain.key => domain }

  domain_name = each.value.domain
  auto_renew  = false
  admin_contact {
    first_name     = "SledgeTech"
    last_name      = "Team"
    contact_type   = "COMPANY"
    address_line_1 = "UK"
    city           = "London"
    phone_number   = "+44.1234567890"    # <-- Add this
    email          = "admin@sledgetech.co.uk" # <-- Add this
  }
  registrant_contact {
    first_name     = "SledgeTech"
    last_name      = "Team"
    contact_type   = "COMPANY"
    address_line_1 = "UK"
    city           = "London"
    phone_number   = "+44.1234567890"    # <-- Add this
    email          = "owner@sledgetech.co.uk" # <-- Add this
  }
  tech_contact {
    first_name     = "SledgeTech"
    last_name      = "Team"
    contact_type   = "COMPANY"
    address_line_1 = "UK"
    city           = "London"
    phone_number   = "+44.1234567890"    # <-- Add this
    email          = "tech@sledgetech.co.uk" # <-- Add this
  }
  dynamic "name_server" {
    for_each = split(",", each.value.name_servers)
    content {
      name = trim(name_server.value, " ")
    }
  }
}