# INFO: Local Values
# INFO: https://developer.hashicorp.com/terraform/language/block/locals
# INFO: slice Function used for AZ's: https://developer.hashicorp.com/terraform/language/functions/slice

//data "aws_availability_zones" "available" {}
locals {
  owners = var.business_division

  common_tags = {
    owners = local.owners
  }

}