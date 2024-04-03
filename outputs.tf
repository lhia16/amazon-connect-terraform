output "bucket_name" {
  description = "Name of datalake bucket"
  value       = module.datalake_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "ARN of datalake bucket"
  value       = module.datalake_bucket.s3_bucket_arn

}

output "database_name" {
  description = "Name of Glue catalog database "
  value       = aws_glue_catalog_database.datalake.name

}

output "datalake_arn" {
  description = "datalake ARN"
  value       = aws_glue_catalog_database.datalake.arn
}