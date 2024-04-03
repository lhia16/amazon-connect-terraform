resource "aws_glue_catalog_database" "datalake" {
  name = var.name_prefix
  create_table_default_permission {
    permissions = [
      "ALL",
    ]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_glue_catalog_table" "contact_trace_record_raw" {
  name          = "contact_trace_record_raw"
  database_name = aws_glue_catalog_database.datalake.name
  owner         = "hadoop"
  parameters = {
    "EXTERNAL"            = "TRUE"
    "parquet.compression" = "SNAPPY"

  }
  retention  = 0
  table_type = "EXTERNAL_TABLE"

  dynamic "partition_keys" {
    for_each = var.glue_partition_keys
    content {
      name = partition_keys.value
      type = "string"
    }
  }
  storage_descriptor {
    bucket_columns            = []
    compressed                = false
    input_format              = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    location                  = "s3://${module.datalake_bucket.s3_bucket_id}/contact-trace-records"
    number_of_buckets         = -1
    output_format             = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    parameters                = {}
    stored_as_sub_directories = false

    columns {
      name       = "awsaccountid"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "awscontacttracerecordformatversion"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "agent"
      parameters = {}
      type       = "struct<ARN:string,AfterContactWorkDuration:int,AfterContactWorkEndTimestamp:string,AfterContactWorkStartTimestamp:string,AgentInteractionDuration:int,ConnectedToAgentTimestamp:string,CustomerHoldDuration:int,HierarchyGroups:struct<Level1:struct<ARN:string,GroupName:string>,Level2:struct<ARN:string,GroupName:string>,Level3:struct<ARN:string,GroupName:string>,Level4:struct<ARN:string,GroupName:string>,Level5:struct<ARN:string,GroupName:string>>,LongestHoldDuration:int,NumberOfHolds:int,RoutingProfile:struct<ARN:string,Name:string>,Username:string>"
    }
    columns {
      name       = "agentconnectionattempts"
      parameters = {}
      type       = "int"
    }
    columns {
      name       = "attributes"
      parameters = {}
      type       = "map<string,string>"
    }
    columns {
      name       = "channel"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "connectedtosystemtimestamp"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "contactid"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "customerendpoint"
      parameters = {}
      type       = "struct<Address:string,Type:string>"
    }
    columns {
      name       = "disconnecttimestamp"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "disconnectreason"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "initialcontactid"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "initiationmethod"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "initiationtimestamp"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "instancearn"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "lastupdatetimestamp"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "mediastreams"
      parameters = {}
      type       = "array<struct<Type:string>>"
    }
    columns {
      name       = "nextcontactid"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "previouscontactid"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "queue"
      parameters = {}
      type       = "struct<ARN:string,DequeueTimestamp:string,Duration:int,EnqueueTimestamp:string,Name:string>"
    }
    columns {
      name       = "recording"
      parameters = {}
      type       = "struct<DeletionReason:string,Location:string,Status:string,Type:string>"
    }
    columns {
      name       = "recordings"
      parameters = {}
      type       = "array<struct<DeletionReason:string,FragmentStartNumber:string,FragmentStopNumber:string,Location:string,MediaStreamType:string,ParticipantType:string,StartTimestamp:string,Status:string,StopTimestamp:string,StorageType:string>>"
    }
    columns {
      name       = "systemendpoint"
      parameters = {}
      type       = "struct<Address:string,Type:string>"
    }
    columns {
      name       = "transfercompletedtimestamp"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "transferredtoendpoint"
      parameters = {}
      type       = "struct<Address:string,Type:string>"
    }

    ser_de_info {
      parameters = {
        "serialization.format" = "1"
      }
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

  }
}

resource "aws_glue_catalog_table" "agent_event_log_raw" {
  name          = "agent_event_log_raw"
  database_name = aws_glue_catalog_database.datalake.name
  owner         = "hadoop"
  parameters = {
    "EXTERNAL"            = "TRUE"
    "parquet.compression" = "SNAPPY"

  }
  retention  = 0
  table_type = "EXTERNAL_TABLE"
  dynamic "partition_keys" {
    for_each = var.glue_partition_keys
    content {
      name = partition_keys.value
      type = "string"
    }
  }
  storage_descriptor {
    bucket_columns            = []
    compressed                = false
    input_format              = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    location                  = "s3://${module.datalake_bucket.s3_bucket_id}/agent-event-log"
    number_of_buckets         = -1
    output_format             = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    parameters                = {}
    stored_as_sub_directories = false

    columns {
      name       = "awsaccountid"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "instancearn"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "agentarn"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "eventid"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "eventtype"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "eventtimestamp"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "version"
      parameters = {}
      type       = "string"
    }
    columns {
      name       = "currentagentsnapshot"
      parameters = {}
      type       = "struct<Configuration:struct<Username:string,FirstName:string,LastName:string,RoutingProfile:struct<ARN:string,Name:string,DefaultOutboundQueue:struct<ARN:string,Name:string>,InboundQueues:array<struct<ARN:string,Name:string>>>,AgentHierarchyGroups:struct<Level1:struct<ARN:string,Name:string>,Level2:struct<ARN:string,Name:string>,Level3:struct<ARN:string,Name:string>,Level4:struct<ARN:string,Name:string>,Level5:struct<ARN:string,Name:string>>>,AgentStatus:struct<ARN:string,Name:string,StartTimestamp:string>,Contacts:array<struct<ContactId:string,InitialContactId:string,Channel:string,InitiationMethod:string,State:string,StateStartTimestamp:string,ConnectedToAgentTimestamp:string,QueueTimestamp:string,Queue:struct<ARN:string,Name:string>>>>"
    }
    columns {
      name       = "previousagentsnapshot"
      parameters = {}
      type       = "struct<Configuration:struct<Username:string,FirstName:string,LastName:string,RoutingProfile:struct<ARN:string,Name:string,DefaultOutboundQueue:struct<ARN:string,Name:string>,InboundQueues:array<struct<ARN:string,Name:string>>>,AgentHierarchyGroups:struct<Level1:struct<ARN:string,Name:string>,Level2:struct<ARN:string,Name:string>,Level3:struct<ARN:string,Name:string>,Level4:struct<ARN:string,Name:string>,Level5:struct<ARN:string,Name:string>>>,AgentStatus:struct<ARN:string,Name:string,StartTimestamp:string>,Contacts:array<struct<ContactId:string,InitialContactId:string,Channel:string,InitiationMethod:string,State:string,StateStartTimestamp:string,ConnectedToAgentTimestamp:string,QueueTimestamp:string,Queue:struct<ARN:string,Name:string>>>>"
    }

    ser_de_info {
      parameters = {
        "serialization.format" = "1"
      }
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

  }
}
