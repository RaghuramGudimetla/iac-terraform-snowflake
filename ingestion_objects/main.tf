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
  storage_provider = var.cloud_platform == "GCP" ? "GCS" : "S3"
  bucket_url       = var.cloud_platform == "GCP" ? "gcs://${var.bucket}" : "s3://${var.bucket}"
  grant_roles      = ["TERRAFORM_ROLE"]
}

# Snowflake Related Resources
# Storage Integration
resource "snowflake_storage_integration" "storage_integration" {
  provider                  = snowflake.accountadmin
  name                      = var.storage_integration_name
  type                      = "EXTERNAL_STAGE"
  enabled                   = true
  comment                   = "Access to bucket ${local.bucket_url}"
  storage_allowed_locations = [local.bucket_url]
  storage_provider          = local.storage_provider
  storage_aws_role_arn      = local.storage_provider == "S3" ? var.aws_role_arn : null
}

resource "snowflake_integration_grant" "storage_grant" {
  provider          = snowflake.accountadmin
  integration_name  = snowflake_storage_integration.storage_integration.name
  privilege         = "USAGE"
  roles             = local.grant_roles
  with_grant_option = false
}

# Notification Integration
resource "snowflake_notification_integration" "notification_integration" {
  provider                     = snowflake.accountadmin
  count                        = var.cloud_platform == "GCP" ? 1 : 0
  name                         = var.notification_integration_name
  comment                      = "Notification for bucket ${local.bucket_url}"
  notification_provider        = "GCP_PUBSUB"
  enabled                      = true
  type                         = "QUEUE"
  direction                    = "INBOUND"
  gcp_pubsub_subscription_name = var.subscription_name
}

resource "snowflake_integration_grant" "notification_grant" {
  provider          = snowflake.accountadmin
  count             = var.cloud_platform == "GCP" ? 1 : 0
  integration_name  = snowflake_notification_integration.notification_integration[0].name
  privilege         = "USAGE"
  roles             = local.grant_roles
  with_grant_option = false
}
