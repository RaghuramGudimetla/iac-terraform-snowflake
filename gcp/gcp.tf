terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.67.0"
    }
  }
}

# Stage required
resource "snowflake_stage" "gcs_stage" {
  name                = upper("gcs_stage")
  url                 = "gcs://raghuram-exec-snowflake-export/"
  database            = "LANDING"
  schema              = "RAW"
  storage_integration = "GCS_STORAGE_INTEGRATION"
  comment             = "Stage to locate to GCS data"
}

resource "snowflake_table" "fruits" {
  database        = "LANDING"
  schema          = "RAW"
  name            = upper("fruits")
  comment         = "A table for fruits"
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

resource "snowflake_pipe" "fruits_pipe" {
  database       = "LANDING"
  schema         = "RAW"
  name           = upper("fruits_pipe")
  comment        = "A pipe to get fruits data"
  copy_statement = "COPY INTO LANDING.RAW.FRUITS (FILENAME, JSON) FROM (SELECT METADATA$FILENAME, $1 FROM @LANDING.RAW.GCS_STAGE)"
  auto_ingest    = true
  integration    = "GCS_NOTIFICATION_INTEGRATION"
}
