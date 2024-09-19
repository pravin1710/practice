resource "aws_kms_key" "staging_leadsigma_kms_key" {
  description              = "${var.app_name}-${var.app_environment}-key"
  customer_master_key_spec = var.key_spec
  is_enabled               = var.enabled
  enable_key_rotation      = var.rotation_enabled
  multi_region             = true

  tags = {
    Name = "staging-leadsigma_kms_key"
  }
}

resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.staging_leadsigma_kms_key.id
  name          = "alias/${var.app_name}-${var.app_environment}-key"
}

resource "aws_kms_key_policy" "key_policy" {
  key_id = aws_kms_key.staging_leadsigma_kms_key.id
  policy = jsonencode(

    {
      "Version" : "2012-10-17",
      "Id" : "Key policy created by CloudTrail",
      "Statement" : [
        {
          "Sid" : "Enable IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::${var.aws_account_id}:root",
              "arn:aws:iam::${var.aws_account_id}:user/kiran"
            ]
          },
          "Action" : "kms:*",
          "Resource" : "*"
        },
        {
          "Sid" : "Allow CloudTrail to encrypt logs",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudtrail.amazonaws.com"
          },
          "Action" : "kms:GenerateDataKey*",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "aws:SourceArn" : "arn:aws:cloudtrail:${var.aws_region}:${var.aws_account_id}:trail/stg-leadsigma"
            },
            "StringLike" : {
              "kms:EncryptionContext:aws:cloudtrail:arn" : "arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*"
            }
          }
        },
        {
          "Sid" : "Allow CloudTrail to describe key",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudtrail.amazonaws.com"
          },
          "Action" : "kms:DescribeKey",
          "Resource" : "*"
        },
        {
          "Sid" : "Allow principals in the account to decrypt log files",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : [
            "kms:Decrypt",
            "kms:ReEncryptFrom"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "kms:CallerAccount" : "${var.aws_account_id}"
            },
            "StringLike" : {
              "kms:EncryptionContext:aws:cloudtrail:arn" : "arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*"
            }
          }
        },
        {
          "Sid" : "Allow alias creation during setup",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : "kms:CreateAlias",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "kms:CallerAccount" : "${var.aws_account_id}",
              "kms:ViaService" : "ec2.${var.aws_region}.amazonaws.com"
            }
          }
        },
        {
          "Sid" : "Enable cross account log decryption",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "*"
          },
          "Action" : [
            "kms:Decrypt",
            "kms:ReEncryptFrom"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "kms:CallerAccount" : "${var.aws_account_id}"
            },
            "StringLike" : {
              "kms:EncryptionContext:aws:cloudtrail:arn" : "arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*"
            }
          }
        }
      ]
  })
}
