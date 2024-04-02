variable "region" {
  type = string
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}



locals {
  name     = "${var.project}-${var.env}"
  vpc_name = "${var.project}-${var.env}-vpc"
  vpc_cidr = "172.21.66.0/25"
  #  database_subnets         = ["172.21.26.0/28", "172.21.26.16/28"]
  private_subnets          = ["172.21.66.32/27", "172.21.66.64/27"]
  public_subnets           = ["172.21.66.0/28", "172.21.66.16/28"]
  azs                      = ["${var.region}a", "${var.region}b"]
  main_tgw_id              = "tgw-04eceb9f8ce818fd4"
  zia_tgw_id               = "tgw-0a287acc261875302"
  dhcp_options_domain_name = "njt.gov"
  dhcp_options_ntp_servers = ["172.21.0.68", "172.21.0.124"] #Intentinally Not CIDR notation
  r53_resolver_rule_id     = "rslvr-rr-f947eb7edca248819"

  onprem_cidr           = "10.0.0.0/8"
  onprem_dmz_cidr       = ["198.177.0.0/22", "198.177.4.0/23"]
  aws_vpc_cidr          = "172.21.0.0/16"
  tdts_cidr             = "10.20.18.73/32"
  ad_cidrs              = ["172.21.0.0/24", "172.21.128.0/24"]
  virtusa_bastian       = ["172.21.44.69/32", "172.21.44.74/32", "172.21.44.106/32", "172.21.44.112/32"]
  virtusa_lm_collectors = ["172.21.44.74/32", "172.21.44.79/32"]
  zscalar_cidrs         = ["172.21.6.0/27", "172.21.134.0/27"]
  swinds_cidrs          = ["172.21.8.166/32", "172.21.8.220/32"]
  bigfix_cidrs          = ["10.20.18.119/32", "10.20.18.141/32", "172.21.8.186/32", "172.21.8.204/32"]
  rubrik_cidrs          = ["10.10.49.128/25", "10.29.32.128/25"]
  cloudflare_cidrs = [
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "108.162.192.0/18",
    "131.0.72.0/22",
    "141.101.64.0/18",
    "162.158.0.0/15",
    "172.64.0.0/13",
    "173.245.48.0/20",
    "188.114.96.0/20",
    "190.93.240.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17"
  ]
  vpc_flowlogs_s3 = "arn:aws:s3:::aws-controltower-vpc-flow-logs-148904271265"

  acm_cert = {
    "main" = "webtickets.stage.njtransit.com"
  }

  intf_endpoint = {
    # ecrapi      = "com.amazonaws.${var.region}.ecr.api"
    # ecrdkr      = "com.amazonaws.${var.region}.ecr.dkr"
    # logs        = "com.amazonaws.${var.region}.logs"
    # kms         = "com.amazonaws.${var.region}.kms"
    # ssm         = "com.amazonaws.${var.region}.ssm"
    # ssmmessages = "com.amazonaws.${var.region}.ssmmessages"
    # ec2         = "com.amazonaws.${var.region}.ec2"
    # ec2messages = "com.amazonaws.${var.region}.ec2messages"
    s3 = "com.amazonaws.${var.region}.s3"
  }
  sqlbucket = "${local.name}-sql-backups"

  tags = {
    Author       = "Raghu Tirumalasetty"
    DeployedBy   = "Raghu Tirumalasetty"
    IaC          = "Terraform"
    map-migrated = "d-server-02a7nflp9hl5gj"
    GithubRepo   = "ccaws-raildev-timsdev"
    GithubOrg    = "njtransit"
  }
  mssql = {
    identifier            = "${local.name}-db"
    engine                = "sqlserver-se"
    engine_version        = "15.00.4316.3.v1"
    instance_class        = "db.m6i.large"
    username              = "admin"
    password              = "12qw34er"
    parameter_group_name  = "default.mysql5.7"
    storage_type          = "gp3"
    allocated_storage     = 50
    max_allocated_storage = 500
    multi_az              = false
    publicly_accessible   = false
  }

  ec2-test = {
    name       = "${local.name}-test"
    ami        = "ami-05c13eab67c5d8861" # Amazon Linux 2023 AMI 2023.2.20231030.1 x86_64 HVM kernel-6.1
    key_name   = "tims-dev"
    inst_type  = "t3.micro"
    DeployedBy = "jonathan ang"
    root_device = {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 8
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
    }
  }
  ec2-app = {
    name       = "awsvatims02d"
    ami        = "ami-0fe630eb857a6ec83" #RHEL 9 Provided by Red Hat, Inc
    key_name   = "tims-dev"
    inst_type  = "t3.medium"
    DeployedBy = "Raghu Tirumalasetty"
    root_device = {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 60
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
    }
  }

  ec2-sql = {
    name      = "awsvahelpdb01p"
    ami       = "ami-051f7e7f6c2f40dc1"
    key_name  = "ecs-demo"
    inst_type = "m6i.large"
    # sg_group_ids = ["sg-0115d7aacb75bd41e", "sg-06029c258c001f10a", "sg-0e5770bb0dee8b404", "sg-0ee8b2b17f8251e6c"]
    DeployedBy = "Raghu Tirumalasetty"
    root_device = {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 50
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
    }
    # Since the AMI already has this device, Specifying explicitly is causing Terraform to destroy and recreate. 
    # Hence not specifying any attributes and Terraform will only capture
    # ebs1_device = {
    #   device_name           = "xvdb"
    #   delete_on_termination = true
    #   encrypted             = true
    #   volume_size           = 60
    #   volume_type           = "gp3"
    #   iops                  = 3000
    #   throughput            = 125
    # }
    ebs2_device = {
      device_name           = "xvdc"
      delete_on_termination = true
      encrypted             = true
      volume_size           = 60
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
    }
    ebs3_device = {
      device_name           = "xvdd"
      delete_on_termination = true
      encrypted             = true
      volume_size           = 20
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
    }
    ebs4_device = {
      device_name           = "xvde"
      delete_on_termination = true
      encrypted             = true
      volume_size           = 15
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
    }
    ebs5_device = {
      device_name           = "xvdf"
      delete_on_termination = true
      encrypted             = true
      volume_size           = 15
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
    }
  }
  security_groups = {
    ad = {
      kerberos = {
        from_port   = 88
        to_port     = 88
        protocol    = "tcp"
        cidr_blocks = local.ad_cidrs
      }
      rpc-tcp = {
        from_port   = 135
        to_port     = 135
        protocol    = "tcp"
        cidr_blocks = local.ad_cidrs
      }
      netbios = {
        from_port   = 139
        to_port     = 139
        protocol    = "tcp"
        cidr_blocks = local.ad_cidrs
      }
      ldap = {
        from_port   = 389
        to_port     = 389
        protocol    = "tcp"
        cidr_blocks = local.ad_cidrs
      }
      smb = {
        from_port   = 445
        to_port     = 445
        protocol    = "tcp"
        cidr_blocks = local.ad_cidrs
      }
      high-ports = {
        from_port   = 49152
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = local.ad_cidrs
      }
      global-catalog = {
        from_port   = 3268
        to_port     = 3269
        protocol    = "tcp"
        cidr_blocks = local.ad_cidrs
      }
      dns-tcp = {
        from_port   = 53
        to_port     = 53
        protocol    = "tcp"
        cidr_blocks = local.ad_cidrs
      }
      dns-udp = {
        from_port   = 53
        to_port     = 53
        protocol    = "udp"
        cidr_blocks = local.ad_cidrs
      }
      rpc-udp = {
        from_port   = 135
        to_port     = 135
        protocol    = "udp"
        cidr_blocks = local.ad_cidrs
      }
    }
    virtusa = {
      rdp = {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = local.virtusa_bastian
      }
      ssh = {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = local.virtusa_bastian
      }
      smb = {
        from_port   = 445
        to_port     = 445
        protocol    = "tcp"
        cidr_blocks = local.virtusa_lm_collectors
      }
      high-ports = {
        from_port   = 49152
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = local.virtusa_lm_collectors
      }
      rpc-tcp = {
        from_port   = 135
        to_port     = 135
        protocol    = "tcp"
        cidr_blocks = local.virtusa_lm_collectors
      }
      snmp = {
        from_port   = 161
        to_port     = 162
        protocol    = "udp"
        cidr_blocks = local.virtusa_lm_collectors
      }
      icmp = {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = distinct(concat(local.virtusa_lm_collectors, local.virtusa_bastian))
      }
    }

    swinds = {
      rpc = {
        from_port   = 135
        to_port     = 135
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      agent = {
        from_port   = 17778
        to_port     = 17790
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      ssh = {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      rdp = {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      wmi = {
        from_port   = 24158
        to_port     = 24158
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      https = {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      http = {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      smb = {
        from_port   = 445
        to_port     = 445
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      high-ports = {
        from_port   = 49152
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      winrm-http = {
        from_port   = 5985
        to_port     = 5985
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      winrm-https = {
        from_port   = 5986
        to_port     = 5986
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      sql = {
        from_port   = 1433
        to_port     = 1433
        protocol    = "tcp"
        cidr_blocks = local.swinds_cidrs
      }
      icmp = {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = local.swinds_cidrs
      }
    }
    bigfix = {
      patch_tcp = {
        from_port   = 52311
        to_port     = 52311
        protocol    = "tcp"
        cidr_blocks = local.bigfix_cidrs
      }
      patch_udp = {
        from_port   = 52311
        to_port     = 52311
        protocol    = "udp"
        cidr_blocks = local.bigfix_cidrs
      }
      rdp = {
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = "10.10.184.23/32"
      }
    }
    rubrik = {
      cluster = {
        from_port   = 12800
        to_port     = 12801
        protocol    = "tcp"
        cidr_blocks = local.rubrik_cidrs
      }
    }
    cloudflare = {
      https = {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = local.cloudflare_cidrs
      }
    }
  }
}
