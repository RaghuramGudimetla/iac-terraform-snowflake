resource "snowflake_database" "raw_landing" {
  name                        = "raw_landing"
  comment                     = "Database where all the raw data lands in raw format"
}