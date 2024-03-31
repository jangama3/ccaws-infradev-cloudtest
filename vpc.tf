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


resource "aws_ec2_transit_gateway_vpc_attachment" "main_tgw_attach" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = local.main_tgw_id
  vpc_id             = module.vpc.vpc_id

  tags = merge({ Name = "${local.vpc_name}-main-tgw-attach" }, local.tags)
}

resource "aws_ec2_transit_gateway_vpc_attachment" "zia_tgw_attach" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = local.zia_tgw_id
  vpc_id             = module.vpc.vpc_id

  tags = merge({ Name = "${local.vpc_name}-zia-tgw-attach" }, local.tags)
}

resource "aws_route" "on_prem_cidr" {
  count                  = length(module.vpc.private_route_table_ids)
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  transit_gateway_id     = local.main_tgw_id
  destination_cidr_block = local.onprem_cidr
}

resource "aws_route" "aws_vpc_cidr" {
  count                  = length(module.vpc.private_route_table_ids)
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  transit_gateway_id     = local.main_tgw_id
  destination_cidr_block = local.aws_vpc_cidr
}

resource "aws_route" "public_cidr" {
  count                  = length(module.vpc.private_route_table_ids)
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  transit_gateway_id     = local.zia_tgw_id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_flow_log" "flowlogs_s3" {
  log_destination      = local.vpc_flowlogs_s3
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id
  destination_options {
    file_format                = "parquet"
    hive_compatible_partitions = true
    # per_hour_partition = true
  }
  tags = merge({ Name = "${local.vpc_name}-flowlogs-to-s3" }, local.tags)
}

resource "aws_flow_log" "flowlogs_cw" {
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role.arn
  log_destination      = aws_cloudwatch_log_group.vpc.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id

  tags = merge({ Name = "${local.vpc_name}-flowlogs-to-cw" }, local.tags)
}

resource "aws_route53_resolver_rule_association" "njt" {
  resolver_rule_id = local.r53_resolver_rule_id
  vpc_id           = module.vpc.vpc_id
}

resource "aws_vpc_endpoint" "intf_endpoint" {
  for_each          = local.intf_endpoint
  vpc_id            = module.vpc.vpc_id
  service_name      = each.value
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.private_subnets

  security_group_ids = [aws_security_group.endpoint.id]

  private_dns_enabled = true
  tags                = merge({ Name = "${local.vpc_name}-${each.key}-endpoint" }, local.tags)
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  route_table_ids   = module.vpc.private_route_table_ids
  vpc_endpoint_type = "Gateway"
  tags              = merge({ Name = "${local.vpc_name}-s3" }, local.tags)
}

# resource "aws_eip" "one" {
#   domain = "vpc"
#   tags   = merge({ Name = "${var.project}-${var.region}a" }, local.tags)
# }

# resource "aws_eip" "two" {
#   domain = "vpc"
#   tags   = merge({ Name = "${var.project}-${var.region}b" }, local.tags)
# }