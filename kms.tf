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
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "Key policy for S3 object encryption",
    "Statement" : [
      {
        "Sid" : "Allow S3 to use the key",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringLike" : {
            "kms:EncryptionContext:aws:s3:bucket" : "arn:aws:s3:::*"
          }
        }
      },
      {
        "Sid" : "Allow IAM users and roles to use the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.aws_account_id}:root",
            "arn:aws:iam::${var.aws_account_id}:user/pravin",
          ]
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncryptFrom",
          "kms:ReEncryptTo",
          "kms:GenerateDataKey*"
        ],
        "Resource" : "*"
      }
    ]
  })
}
