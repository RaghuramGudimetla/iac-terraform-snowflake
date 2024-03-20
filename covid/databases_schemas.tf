locals {

  schemas_definitions = flatten(
    [
      for db_name, db_details in var.databases : [
        for schema_name, schema_details in var.schemas : {
          database_name = upper(db_name)
          schema_name = upper(schema_name)
          comment = schema_details["comment"]
        }
      ]
    ]
  )

}

# Databases
resource "snowflake_database" "databases" {
  for_each = var.databases

  name                        = upper(each.key)
  comment                     = each.value["comment"]
  data_retention_time_in_days = 0

  provider = snowflake

}

# Schemas
resource "snowflake_schema" "schemas" {
  for_each = {
    for schema in local.schemas_definitions : "${schema.database_name}.${schema.schema_name}" => schema
  }
  database = each.value.database_name
  name     = each.value.schema_name
  comment =  each.value.comment
  provider = snowflake

  depends_on = [
    snowflake_database.databases
  ]

}