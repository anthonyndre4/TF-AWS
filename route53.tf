locals {
  domains = csvdecode(file(format("./csv/domains.csv")))
}

resource "aws_route53domains_domain" "aws_domains" {
  for_each = { for domain in local.domains : domain.key => domain }

  domain_name = each.value.domain
  auto_renew  = false
  admin_contact {
    first_name        = "SledgeTech"
    last_name         = "Team"
    contact_type      = "COMPANY"
    organization_name = "SledgeTech Ltd"
    address_line_1    = "123 Example Road"
    city              = "London"
    state             = "ABC"
    zip_code          = "EC1A 1AA"
    country_code      = "GB"
    phone_number      = "+44.1234567890"
    fax               = "+44.2030000000"
    email             = "admin@sledgetech.co.uk"
    extra_param {
      name  = "UK_CONTACT_TYPE"
      value = "OTHER"
    }
  }
  registrant_contact {
    first_name        = "SledgeTech"
    last_name         = "Team"
    contact_type      = "COMPANY"
    organization_name = "SledgeTech Ltd"
    address_line_1    = "123 Example Road"
    city              = "London"
    state             = "ABC"
    zip_code          = "EC1A 1AA"
    country_code      = "GB"
    phone_number      = "+44.1234567890"
    fax               = "+44.2030000000"
    email             = "owner@sledgetech.co.uk"
    extra_param {
      name  = "UK_CONTACT_TYPE"
      value = "OTHER"
    }
  }
  tech_contact {
    first_name        = "SledgeTech"
    last_name         = "Team"
    contact_type      = "COMPANY"
    organization_name = "SledgeTech Ltd"
    address_line_1    = "123 Example Road"
    city              = "London"
    state             = "ABC"
    zip_code          = "EC1A 1AA"
    country_code      = "GB"
    phone_number      = "+44.1234567890"
    fax               = "+44.2030000000"
    email             = "tech@sledgetech.co.uk"
    extra_param {
      name  = "UK_CONTACT_TYPE"
      value = "OTHER"
    }
  }
  dynamic "name_server" {
    for_each = split(",", each.value.name_servers)
    content {
      name = trim(name_server.value, " ")
    }
  }
}