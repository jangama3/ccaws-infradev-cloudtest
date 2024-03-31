data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "vpc_flow_logs_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
    # condition {
    #   test     = "StringEquals"
    #   variable = "aws:SourceAccount"
    #   values   = [data.aws_caller_identity.current.account_id]
    # }
    # condition {
    #   test     = "ArnLike"
    #   variable = "aws:SourceArn"
    #   values   = ["arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"]
    # }
  }
  # statement {
  #   effect = "Allow"
  #   actions = [
  #     "kms:Encrypt",
  #     "kms:Decrypt",
  #     "kms:ReEncrypt*",
  #     "kms:GenerateDataKey*",
  #     "kms:DescribeKey"
  #   ]
  #   resources = [data.aws_kms_alias.other.target_key_arn]
  # }
}

resource "aws_iam_policy" "vpc_flow_logs_policy" {
  name   = "${local.vpc_name}-flowlogs-policy"
  policy = data.aws_iam_policy_document.vpc_flow_logs_doc.json
  tags   = local.tags

}
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${local.vpc_name}-flowlogs-role"
  # assume_role_policy  = data.aws_iam_policy_document.preprod_assume_role_policy.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["vpc-flow-logs.amazonaws.com"]
        }
        Condition : {
          "StringEquals" : {
            "aws:SourceAccount" : data.aws_caller_identity.current.account_id
          },
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"
          }
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.vpc_flow_logs_policy.arn]
  tags                = local.tags
}


# data "aws_iam_policy_document" "opentxt_doc" {
#   statement {
#     effect    = "Allow"
#     actions   = [
#       "s3:PutObject",
#       "s3:GetObject"
#       ]
#     resources = ["${aws_s3_bucket.opentxt.arn}/*"]
#   }
# }

# resource "aws_iam_user_policy" "opentxt_policy" {
#   name   = "${local.name}-policy"
#   user   = aws_iam_user.opentxt.name
#   policy = data.aws_iam_policy_document.opentxt_doc.json
# }

