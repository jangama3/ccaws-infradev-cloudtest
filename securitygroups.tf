resource "aws_security_group" "endpoint" {
  description = "Allow VPC Endpoint traffic"
  vpc_id      = module.vpc.vpc_id
  name        = "${local.vpc_name}-endpoint-sg"
  # name_prefix = "${local.vpc_name}-rds-"

  ingress {
    description = "Allow VPC endpoint Port Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "${local.vpc_name}-endpoint-sg" }, local.tags)
}
# resource "aws_security_group" "sql" {
#   description = "Allow SQL  inbound traffic"
#   vpc_id      = module.vpc.vpc_id
#   name        = "${local.vpc_name}-sql-sg"
#   # name_prefix = "${local.vpc_name}-rds-"

#   ingress {
#     description = "Allow MSSQL Server Port Traffic"
#     from_port   = 1433
#     to_port     = 1433
#     protocol    = "tcp"
#     cidr_blocks = [local.onprem_cidr, local.vpc_cidr]
#   }
#   ingress {
#     description = "Allow MSSQL Server Port Traffic"
#     from_port   = 1434
#     to_port     = 1434
#     protocol    = "udp"
#     cidr_blocks = [local.onprem_cidr, local.private_subnets[0], local.private_subnets[1]]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = merge({ Name = "${local.vpc_name}-sql-sg" }, local.tags)
# }

resource "aws_security_group" "tdts" {
  description = "Allow TDTS inbound traffic"
  vpc_id      = module.vpc.vpc_id
  name        = "${local.vpc_name}-tdts-sg"

  ingress {
    description = "Allow SSH Port Traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.tdts_cidr]
  }
  ingress {
    description = "Allow MSSQL Server Port Traffic"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = [local.tdts_cidr]
  }
  ingress {
    description = "Allow RDP Port Traffic"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [local.tdts_cidr]
  }
  ingress {
    description = "Allow SMB Port Traffic"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [local.tdts_cidr]
  }
  ingress {
    description = "Allow ICMP Traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.tdts_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.tdts_cidr]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "${local.vpc_name}-tdts-sg" }, local.tags)
}

resource "aws_security_group" "onprem" {
  description = "Allow inbound traffic from on-prem"
  vpc_id      = module.vpc.vpc_id
  name        = "${local.vpc_name}-onprem-sg"


  ingress {
    description = "Allow RDP Port Traffic"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [local.onprem_cidr]
  }
  ingress {
    description = "Allow SMB Port Traffic"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = [local.onprem_cidr]
  }
  ingress {
    description = "Allow ICMP Traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.onprem_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "${local.vpc_name}-onprem-sg" }, local.tags)
}

resource "aws_security_group" "zscalar" {
  description = "Allow zScalar  inbound traffic"
  vpc_id      = module.vpc.vpc_id
  name        = "${local.vpc_name}-zscalar-sg"

  ingress {
    description = "Allow All zScalar Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.zscalar_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "${local.vpc_name}-zscalar-sg" }, local.tags)
}

resource "aws_security_group" "ad" {
  description = "Allow domain Join with AWS Domain Controllers"
  vpc_id      = module.vpc.vpc_id
  name        = "${local.vpc_name}-ad-sg"

  dynamic "ingress" {
    for_each = local.security_groups.ad
    content {
      description = ingress.key
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = local.ad_cidrs
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "${local.vpc_name}-ad-sg" }, local.tags)
}

resource "aws_security_group" "virtusa" {
  description = "Allow monitoring from LogicMonitor instances"
  vpc_id      = module.vpc.vpc_id
  name        = "${local.vpc_name}-Virtusa-LM"

  dynamic "ingress" {
    for_each = local.security_groups.virtusa
    content {
      description = ingress.key
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "${local.vpc_name}-Virtusa-LM" }, local.tags)
}

resource "aws_security_group" "swinds" {
  description = "Allow monitoring from AWS SolarWinds poller instances"
  vpc_id      = module.vpc.vpc_id
  name        = "${local.vpc_name}-swinds-sg"

  dynamic "ingress" {
    for_each = local.security_groups.swinds
    content {
      description = ingress.key
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = local.swinds_cidrs
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "${local.vpc_name}-swinds-sg" }, local.tags)
}


resource "aws_security_group" "bigfix" {
  description = "Allow monitoring and patching from Bigfix instances"
  vpc_id      = module.vpc.vpc_id
  name        = "${local.vpc_name}-bigfix-sg"

  dynamic "ingress" {
    for_each = local.security_groups.bigfix
    content {
      description = ingress.key
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = local.bigfix_cidrs
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge({ Name = "${local.vpc_name}-bigfix-sg" }, local.tags)
}

# resource "aws_security_group" "rubrik" {
#   description = "Allow Rubrik traffic to the agents"
#   vpc_id      = module.vpc.vpc_id
#   name        = "${local.vpc_name}-rubrik-sg"

#   dynamic "ingress" {
#     for_each = local.security_groups.rubrik
#     content {
#       description = ingress.key
#       from_port   = ingress.value.from_port
#       to_port     = ingress.value.to_port
#       protocol    = ingress.value.protocol
#       cidr_blocks = local.rubrik_cidrs
#     }
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = merge({ Name = "${local.vpc_name}-rubrik-sg" }, local.tags)
# }
