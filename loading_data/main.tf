terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.67.0"
    }
  }
}

locals {
  stage_url           = var.cloud_platform == "GCP" ? "gcs://${var.bucket}/${var.prefix}" : "s3://${var.bucket}/${var.prefix}"
  storage_integration = upper(var.storage_integration)
}

# Stage required
resource "snowflake_stage" "stage" {
  name                = var.name
  url                 = local.stage_url
  database            = "LANDING"
  schema              = "RAW"
  storage_integration = local.storage_integration
  file_format         = var.fileformat
  comment             = "Stage to locate to ${var.cloud_platform} data"
}

resource "snowflake_table" "table" {
  database        = "LANDING"
  schema          = "RAW"
  name            = var.name
  comment         = "A table to get ${var.name} data"
  cluster_by      = ["to_date(LOAD_TIME)"]
  change_tracking = false

  column {
    name     = upper("filename")
    type     = "VARCHAR(16777216)"
    nullable = false
  }

  column {
    name     = upper("json")
    type     = "VARIANT"
    nullable = true
  }

  column {
    name = "LOAD_TIME"
    type = "TIMESTAMP_NTZ(9)"
    default {
      expression = "CURRENT_TIMESTAMP()"
    }
  }
}

resource "snowflake_pipe" "pipe" {
  database          = "LANDING"
  schema            = "RAW"
  name              = var.name
  comment           = "A pipe to get data into ${var.name} table"
  copy_statement    = <<EOF
  COPY INTO LANDING.RAW.${var.name} (FILENAME, JSON) 
  FROM (SELECT METADATA$FILENAME, $1 FROM @LANDING.RAW.${var.name})
  EOF
  auto_ingest       = true
  integration       = var.notification_integration != null ? upper(var.notification_integration) : null
  aws_sns_topic_arn = var.aws_sns_topic_arn
  depends_on = [snowflake_table.table]
}
