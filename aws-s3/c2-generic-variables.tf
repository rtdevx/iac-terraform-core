# Input variable definitions
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "business_division" {
  description = "Business Division"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID used to construct role ARNs"
  type        = string
  default     = "390157243794"
}

variable "tags" {
  description = "Tages to set on the bucket"
  type        = map(string)
  default     = {}
}

# NOTE: Bucket-related variables

variable "bucket_name_s3backend" {
  description = "Name prefix of the S3 backend bucket."
  type        = string
}

variable "bucket_name_artifacts" {
  description = "Name prefix of the S3 bucket."
  type        = string
}