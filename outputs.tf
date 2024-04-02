# output "kms_key_arn_s3"  { value = data.aws_kms_alias.s3.target_key_arn  }
# output "kms_key_arn_ec2" { value = data.aws_kms_alias.ec2.target_key_arn }
# output "kms_key_arn_rds" { value = data.aws_kms_alias.rds.target_key_arn }
# output "kms_key_arn_other" {value = data.aws_kms_alias.other.target_key_arn}


output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "public_subnet_id" {
#   value = module.vpc.public_subnets
# }

output "private_subnet_id" {
  value = module.vpc.private_subnets
}
output "database_subnet_id" {
  value = module.vpc.database_subnets
}

# output "ad_sg" {
#   value = aws_security_group.ad.id
# }
# output "virtusa_sg" {
#   value = aws_security_group.virtusa.id
# }
# output "sql_sg" {
#   value = aws_security_group.sql.id
# }
# output "zcalar_sg" {
#   value = aws_security_group.zscalar.id
# }
# output "swinds_sg" {
#   value = aws_security_group.swinds.id
# }
# output "tdts_sg" {
#   value = aws_security_group.tdts.id
# }
# output "onprem_sg" {
#   value = aws_security_group.onprem.id
# }
output "awsvatims01d" {
  value = aws_instance.ec2-app.id
}
# output "awsvahelpdb01p" {
#   value = aws_instance.ec2-app.id
# }

