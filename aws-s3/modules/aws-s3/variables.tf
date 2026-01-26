# Input variable definitions
variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket. Must be Unique across AWS."
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "business_division" {
  description = "Business Division"
  type        = string
  default     = "training"
}

variable "tags" {
  description = "Tages to set on the bucket"
  type        = map(string)
  default     = {}
}

# NOTE: Principals allowed to access this backend bucket (list of IAM principal ARNs)
variable "allowed_principals" {
  description = "List of IAM principal ARNs allowed to access the backend bucket"
  type        = list(string)
  # Make this required to enforce explicit principal configuration by callers
  validation {
    condition     = length(var.allowed_principals) > 0
    error_message = "allowed_principals must contain at least one IAM principal ARN"
  }
}

# Enforce server-side encryption for objects written to this bucket
variable "enforce_sse" {
  description = "Require server-side encryption when writing objects to the bucket"
  type        = bool
  default     = true
}

# SSE algorithm to require when `enforce_sse` is true (e.g. AES256 or aws:kms)
variable "sse_algorithm" {
  description = "Server-side encryption algorithm required for PutObject requests"
  type        = string
  default     = "AES256"
}