terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      version = "0.67.0"
    }
  }
}

provider "snowflake" {
  account = var.account
  role = var.role
  username = var.user
}

provider "snowflake" {
  account = var.account
  role = "ACCOUNTADMIN"
  username = var.user
  alias = "accountadmin"
}

terraform {
    backend "s3" {
    bucket = "iac-terraform-instances"
    key    = "snowflake-infra"
    region = "ap-southeast-2"
  }
}

module "objects" {
  source = "./objects"
}

module "gcp" {
  source = "./gcp"
}