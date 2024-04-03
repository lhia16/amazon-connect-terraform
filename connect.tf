resource "aws_connect_instance" "connect" {
  instance_alias                 = "${var.env}-${var.name_prefix}-${data.aws_region.current.name}"
  identity_management_type       = "SAML"
  inbound_calls_enabled          = true
  outbound_calls_enabled         = true
  contact_flow_logs_enabled      = true
}

resource "aws_connect_instance_storage_config" "ctr" {
  instance_id   = aws_connect_instance.connect.id
  resource_type = "CONTACT_TRACE_RECORDS"

  storage_config {
    kinesis_stream_config {
      stream_arn = aws_kinesis_stream.contact_trace_record.arn
    }
    storage_type = "KINESIS_STREAM"
  }
}

resource "aws_connect_instance_storage_config" "agent_events" {
  instance_id   = aws_connect_instance.connect.id
  resource_type = "AGENT_EVENTS"

  storage_config {
    kinesis_stream_config {
      stream_arn = aws_kinesis_stream.agent_event.arn
    }
    storage_type = "KINESIS_STREAM"
  }
}