variable "env" {
  type    = string
  default = ""
}

variable "name_prefix" {
  description = "The prefix for all resources within the module"
  type        = string
  default     = ""
}

variable "glue_partition_keys" {
  description = "Partition keys to use in the Glue catalog tables"
  type        = list(any)
  default     = ["date"]
}

variable "aws_kinesis_key_arn" {
  type    = string
  default = ""
}

variable "client_log_bucket" {
  type    = string
  default = ""
}

variable "archive_to_glacier" {
  type    = bool
  default = true
}

variable "archive_days" {
  type    = number
  default = 100
}

variable "delete_days" {
  type    = number
  default = 101
}

variable "kinesis_firehose" {
  type = map(object({
    name                     = string
    catalog_table_name       = string
    partition_key            = string
    processing_configuration = optional(bool, false)
    lambda_processor         = optional(bool, false)
    extended_s3_prefix       = string
    log_group                = string
  }))
  default = {
    ctr_events = {
      name               = "CTR"
      catalog_table_name = "contact_trace_record_raw"
      partition_key      = "CurrentAgentSnapshot.Configuration.AgentHierarchyGroups.Level1.Name"
      extended_s3_prefix = "contact-trace-records"
      log_group          = "CTRStreamLogGroup"
    }

    agent_events = {
      name               = "AgentEvent"
      catalog_table_name = "agent_event_log_raw"
      partition_key      = "{partition_key:.Attributes.sa_required_partition_key}"
      extended_s3_prefix = "agent-event-log"
      log_group          = "AgentEvent"
    }
  }
}

variable "processing_lambda" {
  description = "arn of of processing lambda"
  type        = string
  default     = ""
}
