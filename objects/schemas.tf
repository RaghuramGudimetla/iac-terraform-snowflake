resource "snowflake_schema" "raw_schema" {
  database = upper("landing")
  name     = upper("raw")
  comment  = "Schema to land all the raw data"
  is_transient        = false
  is_managed          = false
  data_retention_days = 1
}