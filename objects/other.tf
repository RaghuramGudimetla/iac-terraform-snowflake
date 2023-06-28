# Stage required
resource "snowflake_stage" "currency_stage" {
  name        = upper("currency_stage")
  url         = "s3://ap-southeast-2-886192468297-data-extraction/currency/"
  database    = "LANDING"
  schema      = "RAW"
  storage_integration = "AWS_STORAGE_INTEGRATION"
  comment = "Stage to locate currency data"
}