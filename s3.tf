resource "aws_s3_bucket" "services_env_bucket" {
  bucket = "services-env-variabsles" # Specify your bucket name
}

resource "aws_s3_bucket_versioning" "s3_env_variables" {
  bucket = aws_s3_bucket.services_env_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
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
