terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.67.0"
    }
  }
}

locals {
  s3_stage_url           = "s3://ap-southeast-2-886192468297-data-extraction/unloading"
  s3_storage_integration = "AWS_STORAGE_INTEGRATION"
}

resource "snowflake_file_format" "json_file_format" {
  name             = "JSON_FILE_FORMAT"
  binary_format    = "UTF-8"
  date_format      = "AUTO"
  time_format      = "AUTO"
  timestamp_format = "AUTO"
  compression      = "NONE"
  database         = "LANDING"
  schema           = "RAW"
  format_type      = "JSON"
  trim_space       = true
}

resource "snowflake_stage" "stage" {
  name                = upper("unloading_to_s3")
  url                 = local.s3_stage_url
  database            = "LANDING"
  schema              = "RAW"
  storage_integration = local.s3_storage_integration
  comment             = "Stage to unload data into ${local.s3_stage_url}"
}