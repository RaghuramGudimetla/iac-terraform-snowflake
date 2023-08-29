terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.67.0"
      configuration_aliases = [
        snowflake.accountadmin
      ]
    }
  }
}

locals {

  ingestion_data = {
    for name, details in var.ingestion_details : name => {
      bucket                        = "${details.bucket}"
      cloud_platform                = "${details.cloud_platform}"
      storage_integration_name      = upper("integration_${name}")
      notification_integration_name = upper("${details.cloud_platform}_integration_${name}")
      subscription_name             = details.cloud_platform == "GCP" ? "projects/${details.project_id}/subscriptions/${details.subscription_id}" : null
      aws_role_arn                  = details.cloud_platform == "AWS" ? "${details.aws_role_arn}" : null
    }
  }

}

module "create_integration_objects" {
  source = "../ingestion_objects"
  providers = {
    snowflake.accountadmin = snowflake.accountadmin
  }
  for_each                      = local.ingestion_data
  bucket                        = each.value.bucket
  cloud_platform                = each.value.cloud_platform
  storage_integration_name      = each.value.storage_integration_name
  notification_integration_name = each.value.notification_integration_name
  subscription_name             = each.value.subscription_name
  aws_role_arn                  = each.value.aws_role_arn
}
