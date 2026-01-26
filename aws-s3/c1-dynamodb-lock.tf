# INFO: Create a basic DynamoDB table

/*

resource "aws_dynamodb_table" "statelock" {
  name         = "prod-a1s3backend-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # NOTE: S = String, N = Number, B = Binary
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = local.common_tags

}

*/