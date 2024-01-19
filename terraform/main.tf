################################################################################
# Provider configuration
################################################################################

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment      = var.env
      Name             = var.name
      TerraformCreated = true
      Owner            = "Emmanuel Torrado"
    }
  }
}


locals {
  common_tags = merge(
    {
      Environment      = var.env
      Name             = var.name
      TerraformCreated = true
      Owner            = "Emmanuel Torrado"
    },
    var.tags,
  )
}