module "ingestion_integrations" {
  source = "./ingestion"
  providers = {
    snowflake.accountadmin = snowflake.accountadmin
  }
  ingestion_details = {
    currency = {
      cloud_platform = "AWS"
      region         = "ap-southeast-2"
      bucket         = "ap-southeast-2-886192468297-data-extraction"
      aws_role_arn   = "arn:aws:iam::886192468297:role/snowflake_role"
    }
    exporting = {
      cloud_platform  = "GCP"
      region          = "australia-southeast1"
      bucket          = "raghuram-exec-snowflake-export"
      project_id      = "raghuram-exec"
      subscription_id = "raghuram-exec-subscription-snowflake-export"
    }
  }
}

locals {
  tables = {
    currency = {
      cloud_platform           = "AWS"
      fileformat               = "TYPE = JSON NULL_IF = []"
      prefix                   = "currency"
      bucket                   = "ap-southeast-2-886192468297-data-extraction"
      storage_integration      = "integration_currency"
      notification_integration = null
      aws_sns_topic_arn        = null
    }
    exporting = {
      cloud_platform           = "GCP"
      fileformat               = "TYPE = JSON NULL_IF = []"
      prefix                   = "exporting"
      bucket                   = "raghuram-exec-snowflake-export"
      storage_integration      = "integration_exporting"
      notification_integration = "gcp_integration_exporting"
      aws_sns_topic_arn        = null
    }
  }
}

module "raw_tables" {
  source                   = "./loading_data"
  for_each                 = local.tables
  name                     = upper(each.key)
  cloud_platform           = each.value.cloud_platform
  fileformat               = each.value.fileformat
  bucket                   = each.value.bucket
  prefix                   = each.value.prefix
  storage_integration      = each.value.storage_integration
  notification_integration = each.value.notification_integration
  aws_sns_topic_arn        = each.value.aws_sns_topic_arn
}
