module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"
  name    = local.vpc_name
  cidr    = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  # public_subnets           = local.public_subnets
  # database_subnets         = local.database_subnets
  enable_nat_gateway       = false
  enable_vpn_gateway       = false
  enable_dhcp_options      = true
  dhcp_options_domain_name = local.dhcp_options_domain_name
  dhcp_options_ntp_servers = local.dhcp_options_ntp_servers

  tags = local.tags
}

# resource "aws_eip" "one" {
#   domain = "vpc"
#   tags   = merge({ Name = "${var.project}-${var.region}a" }, local.tags)
# }

# resource "aws_eip" "two" {
#   domain = "vpc"
#   tags   = merge({ Name = "${var.project}-${var.region}b" }, local.tags)
# }
