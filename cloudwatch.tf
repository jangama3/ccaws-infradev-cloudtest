/*
# Add user(Encrypt/Decrypt) permissions in KMS key policy for "logs.us-east-1.amazonaws.com"

{
  "Effect": "Allow",
  "Principal": {
      "Service": "logs.us-east-1.amazonaws.com"
  },
  "Action": [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
  ],
  "Resource": "*"
}
*/

resource "aws_cloudwatch_log_group" "vpc" {
  name              = "${local.vpc_name}-flowlogs"
  retention_in_days = 7
  kms_key_id        = data.aws_kms_alias.other.target_key_arn
  tags              = merge({ Name = "${local.vpc_name}-flowlogs" }, local.tags)
}