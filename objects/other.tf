# Stage required
resource "snowflake_stage" "currency_stage" {
  name                = upper("currency_stage")
  url                 = "s3://ap-southeast-2-886192468297-data-extraction/currency/"
  database            = "LANDING"
  schema              = "RAW"
  storage_integration = "AWS_STORAGE_INTEGRATION"
  comment             = "Stage to locate currency data"
}


# External function to hit lambda API
resource "snowflake_external_function" "currency_exchange_function" {
  name     = upper("currency_exchange_function")
  database = "LANDING"
  schema   = "RAW"
  arg {
    name = upper("exchange_date")
    type = "VARCHAR"
  }
  arg {
    name = upper("exchange_currency")
    type = "VARCHAR"
  }
  return_type               = "number(38,2)"
  return_behavior           = "IMMUTABLE"
  api_integration           = "EXTERNAL_FUNCTION_API_INTEGRATION"
  url_of_proxy_and_resource = "https://dv1ogox5oi.execute-api.ap-southeast-2.amazonaws.com/test/action"
}