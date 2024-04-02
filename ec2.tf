# resource "aws_instance" "ec2-test" {
#   ami           = local.ec2-test.ami
#   key_name      = local.ec2-test.key_name
#   instance_type = local.ec2-test.inst_type
#   subnet_id     = module.vpc.private_subnets[0]
#   vpc_security_group_ids = [
#     aws_security_group.tdts.id,
#   ]
#   root_block_device {
#     delete_on_termination = local.ec2-test.root_device.delete_on_termination
#     encrypted             = local.ec2-test.root_device.encrypted
#     iops                  = local.ec2-test.root_device.iops
#     kms_key_id            = data.aws_kms_alias.ec2.target_key_arn
#     throughput            = local.ec2-test.root_device.throughput
#     volume_size           = local.ec2-test.root_device.volume_size
#     volume_type           = local.ec2-test.root_device.volume_type
#     tags                  = merge({ Name = local.ec2-test.name, DeployedBy = local.ec2-test.DeployedBy }, local.tags)
#   }
#   tags = merge({ Name = local.ec2-test.name, DeployedBy = local.ec2-test.DeployedBy }, local.tags)
# }

resource "aws_instance" "ec2-app" {
  ami           = local.ec2-app.ami
  instance_type = local.ec2-app.inst_type
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.tdts.id, aws_security_group.onprem.id, aws_security_group.swinds.id, aws_security_group.virtusa.id, aws_security_group.zscalar.id
  ]
  root_block_device {
    delete_on_termination = local.ec2-app.root_device.delete_on_termination
    encrypted             = local.ec2-app.root_device.encrypted
    iops                  = local.ec2-app.root_device.iops
    throughput            = local.ec2-app.root_device.throughput
    volume_size           = local.ec2-app.root_device.volume_size
    volume_type           = local.ec2-app.root_device.volume_type
    tags                  = merge({ Name = local.ec2-app.name, DeployedBy = local.ec2-app.DeployedBy }, local.tags)
  }
  tags = merge({ Name = local.ec2-app.name, DeployedBy = local.ec2-app.DeployedBy }, local.tags)
}

