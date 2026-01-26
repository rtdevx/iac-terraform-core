# NOTE: S3 Backends Outputs

output "bucket_id_backend" {
  description = "Name (id) of the bucket"
  value       = module.s3_backends.bucket_id_backend
}

output "bucket_arn_backend" {
  description = "ARN of the S3 Bucket"
  value       = module.s3_backends.bucket_arn_backend
}

output "bucket_domain_name_backend" {
  description = "Bucket Domain Name of the S3 Bucket"
  value       = module.s3_backends.bucket_domain_name_backend
}

output "bucket_regional_domain_name_backend" {
  description = "Regional Domain Name of the S3 Bucket"
  value       = module.s3_backends.bucket_regional_domain_name_backend
}

output "bucket_region_backend" {
  description = "S3 Bucket Region"
  value       = module.s3_backends.bucket_region_backend
}

# NOTE: S3 Artifacts Outputs

output "bucket_id_artifacts" {
  description = "Name (id) of the bucket"
  value       = module.s3_artifacts.bucket_id_artifacts
}

output "bucket_arn_artifacts" {
  description = "ARN of the S3 Bucket"
  value       = module.s3_artifacts.bucket_arn_artifacts
}

output "bucket_domain_name_artifacts" {
  description = "Bucket Domain Name of the S3 Bucket"
  value       = module.s3_artifacts.bucket_domain_name_artifacts
}

output "bucket_regional_domain_name_artifacts" {
  description = "Regional Domain Name of the S3 Bucket"
  value       = module.s3_artifacts.bucket_regional_domain_name_artifacts
}

output "bucket_region_artifacts" {
  description = "S3 Bucket Region"
  value       = module.s3_artifacts.bucket_region_artifacts
}