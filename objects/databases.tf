terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
      version = "0.67.0"
    }
  }
}

# Landing
resource "snowflake_database" "landing" {
  name                        = upper("landing")
  comment                     = "Database where all the raw data lands in raw format"
}