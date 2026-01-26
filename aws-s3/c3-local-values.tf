# INFO: Local Values
# INFO: https://developer.hashicorp.com/terraform/language/block/locals
# INFO: slice Function used for AZ's: https://developer.hashicorp.com/terraform/language/functions/slice

//data "aws_availability_zones" "available" {}
locals {
  owners      = var.business_division
  environment = var.environment
  name        = "${var.business_division}-${var.environment}"

  //azs = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}