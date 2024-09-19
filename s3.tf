resource "aws_s3_bucket" "services_env_bucket" {
  bucket = "services-env-variabsles" # Specify your bucket name
}

resource "aws_s3_bucket_versioning" "s3_env_variables" {
  bucket = aws_s3_bucket.services_env_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.services_env_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.staging_leadsigma_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "env_variables_objects_lock" {
  bucket = aws_s3_bucket.services_env_bucket.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 5
    }
  }
  depends_on = [aws_s3_bucket.services_env_bucket]
}

resource "aws_s3_bucket_lifecycle_configuration" "env_variables_lifecycle" {
  count  = var.lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.services_env_bucket.id

  rule {
    id     = var.s3_id
    status = "Enabled"

    dynamic "transition" {
      for_each = var.enable_transition ? [1] : []
      content {
        days          = var.s3_transition_days
        storage_class = var.s3_transition_storage_class
      }
    }
  }
}


resource "aws_s3_object" "leadsigma-service" {
  for_each = fileset("${path.module}/env_variables/", "*.env")
  bucket   = aws_s3_bucket.services_env_bucket.id
  key      = "services-variables/${each.value}"
  acl      = "private"
  content  = file("${path.module}/env_variables/${each.value}")
}
