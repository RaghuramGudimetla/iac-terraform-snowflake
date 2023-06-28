# Landing
resource "snowflake_database" "landing" {
  name                        = upper("landing")
  comment                     = "Database where all the raw data lands in raw format"
}