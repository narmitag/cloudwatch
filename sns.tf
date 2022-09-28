#Ensure Cloudwatch has access to the KMS Key
data "aws_iam_policy_document" "ecs_alerts_key" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow cloudwatch use of the key"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com"
      ]
    }
  }
}

resource "aws_kms_key" "ecs_alerts_key" {
  description             = "Encryption key for test-sns-cw SNS"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy =  data.aws_iam_policy_document.ecs_alerts_key.json
}

resource "aws_kms_alias" "ecs_alerts_alias" {
  name          = "alias/test-sns-cw"
  target_key_id = aws_kms_key.ecs_alerts_key.id
}


resource "aws_sns_topic" "ecs_alerts" {
  name              = "test-sns-cw"
  kms_master_key_id = aws_kms_key.ecs_alerts_key.id
}