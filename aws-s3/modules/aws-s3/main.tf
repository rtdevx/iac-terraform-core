# INFO: S3 static website bucket

# INFO: Create S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  tags          = var.tags
  force_destroy = false
}

# INFO: Enable S3 bucket versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Disabled" # Currently not required.
  }
}

# INFO: Set aws_s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# INFO: Set Bucket policy
resource "aws_s3_bucket_policy" "this" {
  count  = length(var.allowed_principals) > 0 ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowListAndLocation"
        Effect    = "Allow"
        Principal = { AWS = var.allowed_principals }
        Action    = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource  = aws_s3_bucket.this.arn
      },
      {
        Sid       = "AllowGetObject"
        Effect    = "Allow"
        Principal = { AWS = var.allowed_principals }
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.this.arn}/*"
      },
      merge(
        {
          Sid       = "AllowPutObject"
          Effect    = "Allow"
          Principal = { AWS = var.allowed_principals }
          Action    = ["s3:PutObject"]
          Resource  = "${aws_s3_bucket.this.arn}/*"
        },
        var.enforce_sse ? { Condition = { StringEquals = { "s3:x-amz-server-side-encryption" = var.sse_algorithm } } } : {}
      )
    ]
  })
}