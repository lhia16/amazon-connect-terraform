locals {
  kinesis_streams = {
    "ctr_events"   = aws_kinesis_stream.contact_trace_record.arn
    "agent_events" = aws_kinesis_stream.agent_event.arn
  }
}

resource "aws_kinesis_stream" "contact_trace_record" {
  name            = "${var.name_prefix}-ContactTraceRecordStream"
  shard_count     = 1
  encryption_type = "KMS"
  kms_key_id      = "alias/aws/kinesis"
}

resource "aws_kinesis_stream" "agent_event" {
  name            = "${var.name_prefix}-AgentEventStream"
  shard_count     = 1
  encryption_type = "KMS"
  kms_key_id      = "alias/aws/kinesis"
}


resource "aws_kinesis_firehose_delivery_stream" "this" {
  for_each    = var.kinesis_firehose
  destination = "extended_s3"

  name = "${var.name_prefix}-${each.value.name}"

  extended_s3_configuration {
    bucket_arn          = module.datalake_bucket.s3_bucket_arn
    buffering_interval  = 60
    buffering_size      = 128
    compression_format  = "UNCOMPRESSED"
    error_output_prefix = "${each.value.extended_s3_prefix}-error/!{firehose:random-string}/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"
    kms_key_arn         = var.aws_kinesis_key_arn
    prefix              = "${each.value.extended_s3_prefix}/date=!{timestamp:yyyy}-!{timestamp:MM}-!{timestamp:dd}/"
    role_arn            = aws_iam_role.firehose.arn
    s3_backup_mode      = "Disabled"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "${var.name_prefix}-${each.value.log_group}"
      log_stream_name = "DestinationDelivery"
    }

    data_format_conversion_configuration {
      enabled = true

      input_format_configuration {
        deserializer {
          hive_json_ser_de {
            timestamp_formats = [
              "yyyy-MM-dd'T'HH:mm:ss'Z'",
            ]
          }
        }
      }

      output_format_configuration {
        serializer {

          parquet_ser_de {
            block_size_bytes              = 268435456
            compression                   = "SNAPPY"
            enable_dictionary_compression = false
            max_padding_bytes             = 0
            page_size_bytes               = 1048576
            writer_version                = "V1"
          }
        }
      }

      schema_configuration {
        catalog_id    = data.aws_caller_identity.current.account_id
        database_name = aws_glue_catalog_database.datalake.name
        region        = data.aws_region.current.name
        role_arn      = aws_iam_role.firehose.arn
        table_name    = each.value.catalog_table_name
      }
    }


    dynamic "processing_configuration" {
      for_each = each.value.processing_configuration ? [1] : []
      content {
        enabled = each.value.processing_configuration
        dynamic "processors" {
          for_each = each.value.lambda_processor ? [1] : []
          content {
            type = "Lambda"

            parameters {
              parameter_name  = "LambdaArn"
              parameter_value = var.processing_lambda
            }
            parameters {
              parameter_name  = "BufferSizeInMBs"
              parameter_value = "1"
            }
            parameters {
              parameter_name  = "BufferIntervalInSeconds"
              parameter_value = "65"
            }
          }
        }
      }
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = local.kinesis_streams[each.key]
    role_arn           = aws_iam_role.firehose.arn
  }
}

resource "aws_iam_role" "firehose" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "firehose.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  managed_policy_arns   = []
  max_session_duration  = 3600
  name                  = "${var.name_prefix}-FirehoseRole"
  path                  = "/"

  inline_policy {
    name = "${var.name_prefix}-Firehose"
    policy = jsonencode(
      {
        Statement = [
          {
            Action = [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey",
            ]
            Effect = "Allow"
            Resource = [
              var.aws_kinesis_key_arn
            ]
          },
          {
            Action = [
              "kinesis:DescribeStream",
              "kinesis:GetShardIterator",
              "kinesis:GetRecords",
            ]
            Effect = "Allow"
            Resource = [
              aws_kinesis_stream.contact_trace_record.arn,
              aws_kinesis_stream.agent_event.arn
            ]
          },
          {
            Action = [
              "lambda:InvokeFunction",
              "lambda:GetFunctionConfiguration",
            ]
            Effect = "Allow"
            Resource = [
              var.processing_lambda,
              "${var.processing_lambda}:$LATEST",
            ]
          },
          {
            Action = [
              "s3:GetBucketLocation",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:ListBucketMultipartUploads",
              "s3:PutObject",
              "s3:AbortMultipartUpload",
            ]
            Effect = "Allow"
            Resource = [
              module.datalake_bucket.s3_bucket_arn,
              "${module.datalake_bucket.s3_bucket_arn}/*",
            ]
          },
          {
            Action = [
              "glue:GetTable",
              "glue:GetTableVersion",
              "glue:GetTableVersions",
              "glue:GetPartitions",
            ]
            Effect = "Allow"
            Resource = [
              "*",
            ]
          },
        ]
        Version = "2012-10-17"
      }
    )
  }
}
