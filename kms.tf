data "aws_kms_alias" "s3" {
  name = "alias/NJT/S3"
}

data "aws_kms_alias" "ec2" {
  name = "alias/NJT/EC2"
}

data "aws_kms_alias" "rds" {
  name = "alias/NJT/RDS"
}

data "aws_kms_alias" "other" {
  name = "alias/NJT/OTHER"
}