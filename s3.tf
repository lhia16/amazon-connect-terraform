module "datalake_bucket" {

  source = "terraform-aws-modules/s3-bucket/aws"


  bucket_prefix            = var.name_prefix
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  request_payer            = "BucketOwner"

  lifecycle_rule = [
    {
      enabled = var.archive_to_glacier ? false : true
      id      = "DeleteAfterTime"
      prefix  = "archive"
      tags    = {}

      expiration = {
        days                         = var.delete_days
        expired_object_delete_marker = false
      }
    },

    {

      enabled = var.archive_to_glacier ? true : false
      id      = "TransitionToGlacier"
      prefix  = "archive"

      expiration = {
        days                         = var.delete_days
        expired_object_delete_marker = false
      }

      transition = [

        {
          days          = var.archive_days
          storage_class = "GLACIER"
        }
      ]
    },
  ]

  logging = {
    target_bucket = var.client_log_bucket
    target_prefix = "${var.name_prefix}"
  }

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true

      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.aws_kinesis_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning = {
    enabled    = true
    mfa_delete = false
  }
}

resource "aws_s3_bucket_policy" "this" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action = "s3:*"
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
          Effect    = "Deny"
          Principal = "*"
          Resource = [
            "${module.datalake_bucket.s3_bucket_arn}/*",
            module.datalake_bucket.s3_bucket_arn
          ]
        },
      ]
      Version = "2008-10-17"
    }
  )
  bucket = module.datalake_bucket.s3_bucket_id
}

