# NOTE: S3 Backend related Outputs

output "bucket_id_backend" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn_backend" {
  description = "ARN of the S3 Bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name_backend" {
  description = "Bucket Domain Name of the S3 Bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name_backend" {
  description = "Regional Domain Name of the S3 Bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_region_backend" {
  description = "S3 Bucket Region"
  value       = aws_s3_bucket.this.region
}

# NOTE: S3 Artifacts related Outputs

output "bucket_id_artifacts" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn_artifacts" {
  description = "ARN of the S3 Bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_domain_name_artifacts" {
  description = "Bucket Domain Name of the S3 Bucket"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name_artifacts" {
  description = "Regional Domain Name of the S3 Bucket"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_region_artifacts" {
  description = "S3 Bucket Region"
  value       = aws_s3_bucket.this.region
}